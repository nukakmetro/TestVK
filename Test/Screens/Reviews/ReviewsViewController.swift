import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        viewModel.getReviews()
    }

}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        reviewsView.tableView.refreshControl = UIRefreshControl()
        reviewsView.tableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        return reviewsView
    }

    func setupViewModel() {
        viewModel.onStateChange = { [weak reviewsView] _ in
            reviewsView?.loadingView?.removeFromSuperview()
            reviewsView?.loadingView = nil
            reviewsView?.tableView.refreshControl?.endRefreshing()
            reviewsView?.tableView.reloadData()
        }
    }

    /// Метод обработки refreshControl TableView
    @objc private func didPullToRefresh() {
        viewModel.refreshReviews()
    }
}
