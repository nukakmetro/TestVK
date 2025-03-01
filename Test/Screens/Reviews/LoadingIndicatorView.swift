//
//  GradientLoadingView.swift
//  Test
//
//  Created by surexnx on 01.03.2025.
//

import UIKit

class LoadingIndicatorView: UIView {

    private let circleLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // Настройка слоя для круга
        let circularPath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.midX, y: bounds.midY),
            radius: min(bounds.width, bounds.height) / 2 - 10,
            startAngle: -CGFloat.pi / 2,
            endAngle: 2 * CGFloat.pi - CGFloat.pi / 2,
            clockwise: true
        )

        circleLayer.path = circularPath.cgPath
        circleLayer.strokeColor = UIColor.blue.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 5
        circleLayer.strokeEnd = 0
        circleLayer.lineCap = .round

        layer.addSublayer(circleLayer)
    }

    func startAnimating() {
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.toValue = 1
        strokeEndAnimation.duration = 2
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        let strokeStartAnimation = CABasicAnimation(keyPath: "strokeStart")
        strokeStartAnimation.toValue = 1
        strokeStartAnimation.duration = 2
        strokeStartAnimation.beginTime = 1 // Задержка перед началом анимации
        strokeStartAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        // Группа анимаций
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 2
        animationGroup.repeatCount = .infinity
        animationGroup.animations = [strokeEndAnimation, strokeStartAnimation]

        circleLayer.add(animationGroup, forKey: "loading")
    }

    func stopAnimating() {
        circleLayer.removeAllAnimations()
    }
}
