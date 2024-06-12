//
//  NasaImageDetailViewController.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import UIKit

class NASAImageDetailViewController: UIViewController {
    var viewModel: NASAImageDetailViewModelProtocol!
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionTextView = UITextView()
    private let photographerLabel = UILabel()
    private let locationLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupScrollView()
        setupContentView()
        setupImageView()
        setupTitleLabel()
        setupDescriptionTextView()
        setupPhotographerLabel()
        setupLocationLabel()
        setupActivityIndicator()
        setupConstraints()
        configureView()
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupContentView() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
    }
    
    private func setupTitleLabel() {
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    private func setupDescriptionTextView() {
        descriptionTextView.font = UIFont.preferredFont(forTextStyle: .body)
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionTextView)
    }
    
    private func setupPhotographerLabel() {
        photographerLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        photographerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photographerLabel)
    }
    
    private func setupLocationLabel() {
        locationLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        locationLabel.numberOfLines = 0
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(locationLabel)
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.75),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            photographerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            photographerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photographerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            locationLabel.topAnchor.constraint(equalTo: photographerLabel.bottomAnchor, constant: 8),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionTextView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureView() {
        titleLabel.text = viewModel.title
        descriptionTextView.text = viewModel.description
        photographerLabel.text = "Photographer: \(viewModel.photographer)"
        locationLabel.text = "Location: \(viewModel.location)"
        
        if let url = viewModel.imageURL {
            activityIndicator.startAnimating()
            Task { [weak self] in
                guard let self = self else { return }
                await self.viewModel.loadImage(for: url, forKey: url.absoluteString) { result in
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        switch result {
                        case .success(let image):
                            self.imageView.image = image
                        case .failure(let error):
                            print("Failed to load image: \(error)")
                            self.imageView.image = UIImage(systemName: "photo")
                        }
                    }
                }
            }
        } else {
            imageView.image = UIImage(systemName: "photo")
        }
    }
}
