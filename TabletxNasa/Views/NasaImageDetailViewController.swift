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
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
    }
    
    private func setupDescriptionTextView() {
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.isEditable = false
        descriptionTextView.isScrollEnabled = true
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(descriptionTextView)
    }
    
    private func setupPhotographerLabel() {
        photographerLabel.font = UIFont.systemFont(ofSize: 16)
        photographerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(photographerLabel)
    }
    
    private func setupLocationLabel() {
        locationLabel.font = UIFont.systemFont(ofSize: 16)
        locationLabel.numberOfLines = 0
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(locationLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 0.75),
            
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            photographerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            photographerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            photographerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            locationLabel.topAnchor.constraint(equalTo: photographerLabel.bottomAnchor, constant: 16),
            locationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            locationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            descriptionTextView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 200),
            descriptionTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16)
        ])
    }
    
    private func configureView() {
        titleLabel.text = viewModel.title
        descriptionTextView.text = viewModel.description
        photographerLabel.text = "Photographer: \(viewModel.photographer)"
        locationLabel.text = "Location: \(viewModel.location)"
        
        Task {
            if let url = viewModel.imageURL {
                await viewModel.loadImage(for: url, forKey: url.absoluteString) { [weak self] loadedImage in
                    DispatchQueue.main.async {
                        self?.imageView.image = loadedImage
                    }
                }
            }
        }
    }
}
