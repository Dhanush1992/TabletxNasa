//
//  RocketAnimationView.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import Foundation
import UIKit

class RocketAnimationView: UIView {
    private let rocketImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "space"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(rocketImageView)
        rocketImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rocketImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            rocketImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            rocketImageView.widthAnchor.constraint(equalToConstant: 50),
            rocketImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func startAnimation() {
        let rocketTakeOff = CABasicAnimation(keyPath: "position.y")
        rocketTakeOff.fromValue = rocketImageView.layer.position.y
        rocketTakeOff.toValue = rocketImageView.layer.position.y - 300
        rocketTakeOff.duration = 2.0
        rocketTakeOff.timingFunction = CAMediaTimingFunction(name: .easeIn)
        rocketImageView.layer.add(rocketTakeOff, forKey: "rocketTakeOff")
    }
    
    func resetAnimation() {
        rocketImageView.layer.removeAllAnimations()
        rocketImageView.layer.position.y = bounds.height - 50
    }
}
