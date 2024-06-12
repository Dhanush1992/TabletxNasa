//
//  NasaImageViewModel.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import Foundation
import Combine
import UIKit

protocol NASAImageViewModelProtocol {
    var images: [NASAImage] { get }
    var filteredImages: [NASAImage] { get }
    var onImagesUpdated: (() -> Void)? { get set }
    var onFetchError: ((Error) -> Void)? { get set }
    var shouldShowDefaultView: ((Bool) -> Void)? { get set }
    
    func searchImages(query: String, startYear: Int, endYear: Int) async
    func loadMoreImages(startYear: Int, endYear: Int) async
    func image(at index: Int) -> NASAImage
    func loadImage(for url: URL, forKey key: String, completion: @escaping @Sendable (Result<UIImage, Error>) -> Void) async
}

class NASAImageViewModel: NASAImageViewModelProtocol {
    private let networkService: NetworkServiceProtocol
    private let imageCache: ImageCacheProtocol
    
    @Published private(set) var images: [NASAImage] = []
    @Published private(set) var filteredImages: [NASAImage] = []
    private var currentPage = 1
    private var isFetching = false
    private var currentQuery = ""
    
    var onImagesUpdated: (() -> Void)?
    var onFetchError: ((Error) -> Void)?
    var shouldShowDefaultView: ((Bool) -> Void)?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared, imageCache: ImageCacheProtocol = ImageCache.shared) {
        self.networkService = networkService
        self.imageCache = imageCache
        
        setupBindings()
    }
    
    private func setupBindings() {
        $images
            .sink { [weak self] images in
                self?.filteredImages = images
                self?.onImagesUpdated?()
            }
            .store(in: &cancellables)
    }
    
    func searchImages(query: String, startYear: Int, endYear: Int) async {
        guard !isFetching else { return }
        isFetching = true
        currentQuery = query
        currentPage = 1
        images.removeAll()
        
        let result = await networkService.fetchImages(searchQuery: query, page: currentPage, startYear: startYear, endYear: endYear)
        
        switch result {
        case .success(let fetchedImages):
            updateImages(fetchedImages)
        case .failure(let error):
            handleFetchError(error)
        }
        
        isFetching = false
    }
    
    func loadMoreImages(startYear: Int, endYear: Int) async {
        guard !isFetching else { return }
        isFetching = true
        currentPage += 1
        
        let result = await networkService.fetchImages(searchQuery: currentQuery, page: currentPage, startYear: startYear, endYear: endYear)
        
        switch result {
        case .success(let fetchedImages):
            updateImages(fetchedImages)
        case .failure(let error):
            handleFetchError(error)
        }
        
        isFetching = false
    }
    
    private func updateImages(_ fetchedImages: [NASAImage]) {
        self.images.append(contentsOf: fetchedImages)
        self.filteredImages = self.images
        shouldShowDefaultView?(self.filteredImages.isEmpty)
        onImagesUpdated?()
    }
    
    func handleFetchError(_ error: Error) {
        onFetchError?(error)
    }
    
    func image(at index: Int) -> NASAImage {
        return filteredImages[index]
    }
    
    var imageCount: Int {
        return filteredImages.count
    }
    
    func loadImage(for url: URL, forKey key: String, completion: @escaping @Sendable (Result<UIImage, Error>) -> Void) async {
        if let cachedImage = await imageCache.getImage(forKey: key) {
            DispatchQueue.main.async {
                completion(.success(cachedImage))
            }
        } else {
            await downloadAndCacheImage(for: url, with: key, completion: completion)
        }
    }
    
    private func downloadAndCacheImage(for url: URL, with key: String, completion: @escaping @Sendable (Result<UIImage, Error>) -> Void) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let downloadedImage = UIImage(data: data) {
                await imageCache.setImage(downloadedImage, forKey: key)
                DispatchQueue.main.async {
                    completion(.success(downloadedImage))
                }
            } else {
                DispatchQueue.main.async {
                    completion(.failure(APIError.decodingFailed))
                }
            }
        } catch {
            print("Failed to load image: \(error)")
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }
}
