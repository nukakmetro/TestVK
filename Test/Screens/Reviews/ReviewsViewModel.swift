import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {

    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?

    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let decoder: JSONDecoder
    private let imageLoader = ImageLoader()

    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }

}

// MARK: - Internal

extension ReviewsViewModel {

    typealias State = ReviewsViewModelState

    /// Метод получения отзывов.
    func getReviews() {
        guard
            state.shouldLoad
        else {
            if state.footer == nil {
                state.footer = ReviewFooterCellConfig(reviewCount: state.items.count)
            }
            return
        }
        state.shouldLoad = false

        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            
            reviewsProvider.getReviews(offset: state.offset, completion: {  [weak self] result in
                self?.gotReviews(result)
            })
        }
    }

    /// Метод обновления отзывов
    func refreshReviews() {

        DispatchQueue.global().async { [weak self] in
            guard let self else { return }

            reviewsProvider.getReviews(offset: state.offset, completion: {  [weak self] result in
                guard let self else { return }

                state.offset = 0
                state.items.removeAll()
                state.footer = nil
                state.shouldLoad = true

                gotReviews(result)
            })
        }
    }
}

// MARK: - Private

private extension ReviewsViewModel {

    /// Метод обработки получения отзывов.
    func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try decoder.decode(Reviews.self, from: data)
            state.items += reviews.items.map(makeReviewItem)
            state.offset += state.limit
            state.shouldLoad = state.offset < reviews.count
        } catch {
            state.shouldLoad = true
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            onStateChange?(state)
        }
    }

    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }

    /// Метод, вызывается после успешной загрузки изображения пользователя
    /// Обновляет ячейку с полученым изображением
    func processedImageLoaded(with id: UUID, image: UIImage) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.avatarImage = image
        state.items[index] = item
        onStateChange?(state)
    }
}

// MARK: - Items

private extension ReviewsViewModel {

    typealias ReviewItem = ReviewCellConfig

    func makeReviewItem(_ review: Review) -> ReviewItem {
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let id = UUID()
        let item = ReviewItem(
            id: id,
            reviewText: reviewText,
            created: created,
            onTapShowMore: { [weak self] id in
                self?.showMoreReview(with: id)
            },
            avatarImage: UIImage(named: "l5w5aIHioYc"),
            userFullName: "\(review.first_name) \(review.last_name)",
            ratingImage: ratingRenderer.ratingImage(review.rating),
            images: []
        )
        if
            let userImageUrlString = review.avatar_url,
            let url = URL(string: userImageUrlString)
        {
            updateAvatarImage(with: id, url: url)
        }

        return item
    }

    func updateAvatarImage(with id: UUID, url: URL) {
        imageLoader.asyncFetchImage(url: url) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let image):
                processedImageLoaded(with: id, image: image)
            case .failure:
                break
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !state.shouldLoad {
            return state.items.count + 1
        }
        return state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if !state.shouldLoad && indexPath.row == state.items.count {

            if let footer = state.footer {
                let cell = tableView.dequeueReusableCell(withIdentifier: footer.reuseId, for: indexPath)
                footer.update(cell: cell)
                return cell
            }
            return UITableViewCell()
        }
        let config = state.items[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }

}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !state.shouldLoad && indexPath.row == state.items.count {
            if let footer = state.footer {
                return footer.height(with: tableView.bounds.size)
            }
            return 30
        }
        return state.items[indexPath.row].height(with: tableView.bounds.size)
    }

    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }

    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }

}
