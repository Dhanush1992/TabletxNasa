//
//  NasaImageDetailViewModel.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/9/24.
//

import Foundation
import UIKit

protocol NASAImageDetailViewModelProtocol {
    var title: String { get }
    var description: String { get }
    var photographer: String { get }
    var location: String { get }
    var imageURL: URL? { get }
    
    func loadImage(for url: URL,forKey key: String, completion: @escaping @Sendable (UIImage?) -> Void) async
}

class NASAImageDetailViewModel: NASAImageDetailViewModelProtocol {
    private let image: NASAImage
    private let imageCache: ImageCacheProtocol
    
    init(image: NASAImage, imageCache: ImageCacheProtocol = ImageCache.shared) {
        self.image = image
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
    
    func loadImage(for url: URL, forKey key: String, completion: @escaping @Sendable (UIImage?) -> Void) async {
        if let cachedImage = await ImageCache.shared.getImage(forKey: key) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
        } else {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let downloadedImage = UIImage(data: data) {
                    await ImageCache.shared.setImage(downloadedImage, forKey: key)
                    DispatchQueue.main.async {
                        completion(downloadedImage)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } catch {
                print("Failed to load image: \(error)")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
