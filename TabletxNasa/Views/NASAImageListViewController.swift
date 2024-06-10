//
//  ViewController.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import UIKit
import Combine

class NASAImageListViewController: UIViewController, YearRangePickerViewDelegate {
    private var viewModel: NASAImageViewModelProtocol
    private var collectionView: UICollectionView
    private var searchBar: UISearchBar
    private var dataSource: UICollectionViewDiffableDataSource<Section, NASAImage>
    private let refreshControl = UIRefreshControl()
    private let rocketAnimationView = RocketAnimationView(frame: CGRect(x: 0, y: 0, width: 50, height: 100))
    private var currentQuery: String = ""
    private var cancellables = Set<AnyCancellable>()
    private var yearRangePickerView: YearRangePickerView
    private var yearLabel: UILabel
    private var itemsPerRowSlider: UISlider
    private var itemsPerRowLabel: UILabel
    private var filterButton: UIBarButtonItem
    private var loadMoreButton: UIButton
    
    private var isSearchBarPinnedToTop = false
    private var searchBarTopConstraint: NSLayoutConstraint!
    private var searchBarCenterYConstraint: NSLayoutConstraint!
    private var collectionViewTopConstraint: NSLayoutConstraint!
    private var yearLabelTopConstraint: NSLayoutConstraint!
    private var yearRangePickerHeightConstraint: NSLayoutConstraint!
    private var loadMoreButtonBottomConstraint: NSLayoutConstraint!
    private var sliderTopConstraint: NSLayoutConstraint!
    
    private let startYearDefault = 1920
    private let endYearDefault = Calendar.current.component(.year, from: Date())
    private var startYear: Int
    private var endYear: Int
    private var itemsPerRow = UserDefaults.standard.integer(forKey: "itemsPerRow") == 0 ? 2 : UserDefaults.standard.integer(forKey: "itemsPerRow")
    
    enum Section {
        case main
    }
    
    init(viewModel: NASAImageViewModelProtocol = NASAImageViewModel()) {
        self.viewModel = viewModel
        self.startYear = startYearDefault
        self.endYear = endYearDefault
        self.searchBar = UISearchBar()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        self.dataSource = UICollectionViewDiffableDataSource<Section, NASAImage>(collectionView: collectionView) { _, _, _ in nil }
        self.yearRangePickerView = YearRangePickerView()
        self.yearLabel = UILabel()
        self.itemsPerRowSlider = UISlider()
        self.itemsPerRowLabel = UILabel()
        self.filterButton = UIBarButtonItem()
        self.loadMoreButton = UIButton(type: .system)
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupSearchBar()
        setupYearRangePickerView()
        setupSlider()
        setupCollectionView()
        setupDataSource()
        setupRefreshControl()
        setupLoadMoreButton()
        bindViewModel()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "NASA Images"
        filterButton = UIBarButtonItem(image: UIImage(systemName: "line.horizontal.3.decrease.circle"), style: .plain, target: self, action: #selector(toggleFilterAndSettings))
        filterButton.tintColor = .black
        navigationItem.rightBarButtonItem = filterButton
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.tintColor = .black
            navigationBar.barTintColor = .white
            navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
        }
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search NASA Images"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        searchBarTopConstraint = searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100)
        searchBarCenterYConstraint = searchBar.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        NSLayoutConstraint.activate([
            searchBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchBar.widthAnchor.constraint(equalToConstant: 300),
            searchBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        activateSearchBarConstraints(pinToTop: false)
    }
    
    private func activateSearchBarConstraints(pinToTop: Bool) {
        searchBarTopConstraint.isActive = pinToTop
        searchBarCenterYConstraint.isActive = !pinToTop
    }
    
    private func setupYearRangePickerView() {
        yearRangePickerView.delegate = self
        yearRangePickerView.setInitialYears(startYear: startYearDefault, endYear: endYearDefault) // Set default years
        yearRangePickerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(yearRangePickerView)
        
        yearLabel.translatesAutoresizingMaskIntoConstraints = false
        yearLabel.text = "YEAR PUBLISHED:"
        view.addSubview(yearLabel)
        
        yearRangePickerHeightConstraint = yearRangePickerView.heightAnchor.constraint(equalToConstant: 100)
        yearRangePickerHeightConstraint.isActive = true
        
        yearLabelTopConstraint = yearLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            yearLabelTopConstraint,
            yearLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            yearRangePickerView.topAnchor.constraint(equalTo: yearLabel.bottomAnchor, constant: 16),
            yearRangePickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            yearRangePickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        yearRangePickerView.isHidden = true
        yearLabel.isHidden = true
    }
    
    private func setupSlider() {
        itemsPerRowLabel.text = "Items per row: \(itemsPerRow)"
        itemsPerRowLabel.translatesAutoresizingMaskIntoConstraints = false
        
        itemsPerRowSlider.minimumValue = 1
        itemsPerRowSlider.maximumValue = 5
        itemsPerRowSlider.value = Float(itemsPerRow)
        itemsPerRowSlider.addTarget(self, action: #selector(itemsPerRowSliderChanged(_:)), for: .valueChanged)
        itemsPerRowSlider.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(itemsPerRowLabel)
        view.addSubview(itemsPerRowSlider)
        
        NSLayoutConstraint.activate([
            itemsPerRowLabel.topAnchor.constraint(equalTo: yearRangePickerView.bottomAnchor, constant: 16),
            itemsPerRowLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            itemsPerRowSlider.topAnchor.constraint(equalTo: itemsPerRowLabel.bottomAnchor, constant: 8),
            itemsPerRowSlider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            itemsPerRowSlider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        itemsPerRowSlider.isHidden = true
        itemsPerRowLabel.isHidden = true
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        configureCollectionViewLayout(layout: layout)
        
        collectionView.setCollectionViewLayout(layout, animated: false)
        collectionView.register(NASAImageCell.self, forCellWithReuseIdentifier: NASAImageCell.reuseIdentifier)
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = true
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -3)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        collectionViewTopConstraint = collectionView.topAnchor.constraint(equalTo: yearRangePickerView.isHidden ? searchBar.bottomAnchor : itemsPerRowSlider.bottomAnchor, constant: 16)
        
        NSLayoutConstraint.activate([
            collectionViewTopConstraint,
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, NASAImage>(collectionView: collectionView) { (collectionView, indexPath, image) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NASAImageCell.reuseIdentifier, for: indexPath) as? NASAImageCell else {
                return nil
            }

            // Configure cell with data
            let showTitle = self.itemsPerRow <= 2
            cell.configure(with: image, showTitle: showTitle)
            
            // Load image asynchronously
            Task {
                if let url = URL(string: image.url) {
                    await self.viewModel.loadImage(for: url, forKey: image.url) { loadedImage in
                        DispatchQueue.main.async {
                            cell.updateImage(loadedImage ?? UIImage(systemName: "photo")!)
                        }
                    }
                }
            }
            return cell
        }
    }
    
    private func bindViewModel() {
        viewModel.onImagesUpdated = { [weak self] in
            self?.updateCollectionView()
        }
        viewModel.onFetchError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showErrorAlert(error: error)
            }
        }
        
        // Combine observers
        guard let viewModel = viewModel as? NASAImageViewModel else { return }
        let imagesPublisher = viewModel.$filteredImages
        imagesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateCollectionView()
            }
            .store(in: &cancellables)
    }
    
    private func setupRefreshControl() {
        refreshControl.tintColor = .clear // Hide the default spinner
        refreshControl.addSubview(rocketAnimationView)
        rocketAnimationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            rocketAnimationView.centerXAnchor.constraint(equalTo: refreshControl.centerXAnchor),
            rocketAnimationView.centerYAnchor.constraint(equalTo: refreshControl.centerYAnchor),
            rocketAnimationView.widthAnchor.constraint(equalToConstant: 50),
            rocketAnimationView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    private func setupLoadMoreButton() {
        loadMoreButton.setTitle("Load More", for: .normal)
        loadMoreButton.setTitleColor(.white, for: .normal)
        loadMoreButton.backgroundColor = .black
        loadMoreButton.layer.cornerRadius = 25
        loadMoreButton.layer.masksToBounds = true
        loadMoreButton.addTarget(self, action: #selector(loadMoreImages), for: .touchUpInside)
        loadMoreButton.translatesAutoresizingMaskIntoConstraints = false
        loadMoreButton.isHidden = true
        
        view.addSubview(loadMoreButton)
        
        loadMoreButtonBottomConstraint = loadMoreButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        
        NSLayoutConstraint.activate([
            loadMoreButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadMoreButton.widthAnchor.constraint(equalToConstant: 150),
            loadMoreButton.heightAnchor.constraint(equalToConstant: 50),
            loadMoreButtonBottomConstraint
        ])
    }
    
    @objc private func refreshData() {
        Task {
            rocketAnimationView.resetAnimation() // Reset animation before starting a new one
            await viewModel.searchImages(query: currentQuery, startYear: startYear, endYear: endYear)
            refreshControl.endRefreshing()
            rocketAnimationView.startAnimation()
            loadMoreButton.isHidden = true // Ensure Load More button is hidden at the start
        }
    }
    
    @objc private func loadMoreImages() {
        Task {
            await viewModel.loadMoreImages(startYear: startYear, endYear: endYear)
            loadMoreButton.isHidden = true
        }
    }
    
    private func updateCollectionView() {
        DispatchQueue.main.async {
            var snapshot = NSDiffableDataSourceSnapshot<Section, NASAImage>()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.viewModel.filteredImages)
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    private func animateSearchBar(toTop: Bool) {
        searchBarTopConstraint.isActive = false
        searchBarCenterYConstraint.isActive = false
        
        if toTop {
            searchBarTopConstraint.constant = 0
            searchBarTopConstraint.isActive = true
        } else {
            searchBarCenterYConstraint.isActive = true
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc private func itemsPerRowSliderChanged(_ sender: UISlider) {
        itemsPerRow = Int(sender.value)
        itemsPerRowLabel.text = "Items per row: \(itemsPerRow)"
        let layout = UICollectionViewFlowLayout()
        configureCollectionViewLayout(layout: layout)
        collectionView.setCollectionViewLayout(layout, animated: false)
        updateCollectionView()
        UserDefaults.standard.set(itemsPerRow, forKey: "itemsPerRow")
    }
    
    private func configureCollectionViewLayout(layout: UICollectionViewFlowLayout) {
        let spacing: CGFloat = 8
        let totalSpacing = spacing * CGFloat(itemsPerRow + 1)
        let itemWidth = (view.frame.width - totalSpacing) / CGFloat(itemsPerRow)
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + (itemsPerRow > 2 ? 0 : 40)) // Adjust height as needed
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
    }
    
    @MainActor
    func didSelectYearRange(startYear: Int, endYear: Int) {
        self.startYear = startYear
        self.endYear = endYear
        filterButton.tintColor = .black // Highlight the filter button when values are selected
        Task {
            await viewModel.searchImages(query: currentQuery, startYear: startYear, endYear: endYear)
        }
    }
    
    @objc private func toggleFilterAndSettings() {
        let isHidden = !yearRangePickerView.isHidden
        yearRangePickerView.isHidden = isHidden
        yearLabel.isHidden = isHidden
        itemsPerRowLabel.isHidden = isHidden
        itemsPerRowSlider.isHidden = isHidden
        
        if isHidden {
            filterButton.tintColor = .none // Reset the filter button tint when hidden
            collectionViewTopConstraint.constant = 16 // Adjust collection view top constraint
        } else {
            filterButton.tintColor = .black // Highlight the filter button when visible
            collectionViewTopConstraint.constant = yearLabel.frame.height + yearRangePickerView.frame.height + itemsPerRowLabel.frame.height + itemsPerRowSlider.frame.height + 64 // Adjust collection view top constraint
        }
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showErrorAlert(error: Error) {
        let message: String
        switch error {
        case APIError.invalidURL:
            message = "The URL is invalid. Please try again."
        case APIError.invalidResponse:
            message = "The server response is invalid. Please try again."
        case APIError.decodingFailed:
            message = "Failed to decode the server response. Please try again."
        case APIError.statusCode(let statusCode):
            switch statusCode {
            case 400:
                message = "Bad request. Please check your input."
            case 401:
                message = "Unauthorized. Please check your credentials."
            case 403:
                message = "Forbidden. You don't have permission to access this resource."
            case 404:
                message = "Not found. The requested resource could not be found."
            case 500:
                message = "Server error. Please try again later."
            default:
                message = "An unexpected error occurred. Please try again."
            }
        default:
            message = "An unexpected error occurred. Please try again."
        }
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}

extension NASAImageListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else { return }
        currentQuery = query // Store the current query
        Task {
            if (!isSearchBarPinnedToTop) {
                animateSearchBar(toTop: true)
                isSearchBarPinnedToTop = true
            }
            await viewModel.searchImages(query: query, startYear: startYear, endYear: endYear)
        }
        searchBar.resignFirstResponder() // Dismiss the keyboard
    }
}

extension NASAImageListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = NASAImageDetailViewController()
        detailVC.viewModel = NASAImageDetailViewModel(image: viewModel.image(at: indexPath.item))
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if contentOffsetY > contentHeight - frameHeight * 1.5 {
            loadMoreButton.isHidden = false
        } else {
            loadMoreButton.isHidden = true
        }
    }
}
