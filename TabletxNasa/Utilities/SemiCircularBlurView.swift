//
//  SemiCircularBlurView.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/10/24.
//

import UIKit

class SemiCircularBlurView: UIVisualEffectView {

    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
        self.layer.masksToBounds = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyMask()
    }

    private func applyMask() {
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath()

        let radius = self.bounds.width / 4
        let center = CGPoint(x: self.bounds.width / 2, y: self.bounds.height)

        path.addArc(withCenter: center, radius: radius, startAngle: CGFloat.pi, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height))
        path.addLine(to: CGPoint(x: 0, y: self.bounds.height))
        path.close()

        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
}

