//
//  NasaImageDetailViewModel.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/9/24.
//

import Foundation
import UIKit

protocol NASAImageDetailViewModelProtocol: Sendable {
    var title: String { get }
    var description: String { get }
    var photographer: String { get }
    var location: String { get }
    var imageURL: URL? { get }
    
    func loadImage(for url: URL, forKey key: String, completion: @escaping @Sendable (Result<UIImage, Error>) -> Void) async
}


class NASAImageDetailViewModel: NASAImageDetailViewModelProtocol, @unchecked Sendable {
    private let image: NASAImage
    private let networkService: NetworkServiceProtocol
    private let imageCache: ImageCacheProtocol
    
    init(image: NASAImage, networkService: NetworkServiceProtocol = NetworkService.shared, imageCache: ImageCacheProtocol = ImageCache.shared) {
        self.image = image
        self.networkService = networkService
        self.imageCache = imageCache
    }
    
    var title: String {
        return image.title
    }
    
    var description: String {
        return image.description ?? "N/A"
    }
    
    var photographer: String {
        return image.photographer ?? "Unknown"
    }
    
    var location: String {
        return image.location ?? "Unknown"
    }
    
    var imageURL: URL? {
        return URL(string: image.url)
    }
    
    func loadImage(for url: URL, forKey key: String, completion: @escaping @Sendable (Result<UIImage, Error>) -> Void) async {
        if let cachedImage = await imageCache.getImage(forKey: key) {
            DispatchQueue.main.async {
                completion(.success(cachedImage))
            }
        } else {
            let result = await networkService.fetchImageData(from: url)
            switch result {
            case .success(let data):
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
            case .failure(let error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
