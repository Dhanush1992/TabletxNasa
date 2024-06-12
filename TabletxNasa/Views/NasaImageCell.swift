//
//  NasaImageCell.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import UIKit

class NASAImageCell: UICollectionViewCell {
    static let reuseIdentifier = "NASAImageCell"
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        configureRoundedCorners()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).with(priority: .defaultLow)
        ])
    }
    
    private func configureRoundedCorners() {
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1.0
    }
    
    func configure(with image: NASAImage, showTitle: Bool) {
        imageView.image = nil // Placeholder image or color can be set here
        titleLabel.text = showTitle ? image.title : ""
        titleLabel.isHidden = !showTitle
    }
    
    func updateImage(_ image: UIImage) {
        imageView.image = image
    }
}

extension NSLayoutConstraint {
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}

