import UIKit

final class ReviewsView: UIView {

    lazy var tableView = UITableView()

    var loadingView: LoadingIndicatorView?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()

        let loadingIndicator = LoadingIndicatorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.loadingView = loadingIndicator
        loadingIndicator.center = self.center
        addSubview(loadingIndicator)
        loadingIndicator.startAnimating()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        loadingView?.center = self.center
        tableView.frame = bounds.inset(by: safeAreaInsets)
    }

}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.register(ReviewFooterCell.self, forCellReuseIdentifier: ReviewFooterCellConfig.reuseId)

       
    }
}
