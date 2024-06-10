//
//  SemiCircularBlurView.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/10/24.
//

import Foundation
import UIKit

class SemiCircularBlurView: UIVisualEffectView {
    
    override init(effect: UIVisualEffect?) {
        super.init(effect: effect)
        setupMask()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupMask()
    }
    
    private func setupMask() {
        let maskLayer = CAShapeLayer()
        maskLayer.path = createSemiCircularPath().cgPath
        self.layer.mask = maskLayer
    }
    
    private func createSemiCircularPath() -> UIBezierPath {
        let width = self.bounds.width
        let height = self.bounds.height
        let radius = height / 2
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addArc(withCenter: CGPoint(x: width / 2, y: -radius), radius: radius, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
        path.addLine(to: CGPoint(x: width, y: 0))
        path.addLine(to: CGPoint(x: width, y: height))
        path.addLine(to: CGPoint(x: 0, y: height))
        path.close()
        
        return path
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupMask()
    }
}
