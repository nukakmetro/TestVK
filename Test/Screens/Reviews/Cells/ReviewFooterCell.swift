//
//  ReviewFooterCell.swift
//  Test
//
//  Created by surexnx on 28.02.2025.
//

import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewFooterCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewFooterCellConfig.self)

    let reviewCount: Int

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewFooterCellLayout()

}

// MARK: - TableCellConfig

extension ReviewFooterCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewFooterCell else { return }

        cell.reviewCountLabel.text = ("\(reviewCount) \(ReviewFooterCellConfig.reviewCountDesription)")
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewFooterCellConfig {

    /// Дополнение к кол-во отзывов
    static let reviewCountDesription = "Отзывов"
}

// MARK: - Cell

final class ReviewFooterCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let reviewCountLabel = UILabel()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        reviewCountLabel.frame = layout.reviewCountLabelFrame

    }

}

// MARK: - Private

private extension ReviewFooterCell {

    func setupCell() {
        contentView.addSubview(reviewCountLabel)
        reviewCountLabel.font = .reviewCount
        reviewCountLabel.textColor = .reviewCount
    }
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewFooterCellLayout {
    
    // MARK: - Фреймы

    private(set) var reviewCountLabelFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {

        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.reviewCount]
        let text = ("\(config.reviewCount) \(ReviewFooterCellConfig.reviewCountDesription)")
        let textSize = text.size(withAttributes: attributes)

        reviewCountLabelFrame = CGRect(
            origin: CGPoint(x: (maxWidth - textSize.width) / 2, y: insets.top),
            size: CGSize(width: textSize.width, height: textSize.height + insets.bottom)
        )

        return reviewCountLabelFrame.maxY
    }
}

// MARK: - Typealias

fileprivate typealias Config = ReviewFooterCellConfig
fileprivate typealias Layout = ReviewFooterCellLayout
