//
//  ImageCache.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import UIKit

protocol ImageCacheProtocol: Sendable {
    func setImage(_ image: UIImage, forKey key: String) async
    func getImage(forKey key: String) async -> UIImage?
}

actor ImageCache: ImageCacheProtocol {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, CacheItem>()
    private let cacheLifetime: TimeInterval = 24 * 60 * 60 // 24 hours
    
    private init() {
        // Register for memory warning notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveMemoryWarningNotification),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        let cacheItem = CacheItem(image: image, expirationDate: Date().addingTimeInterval(cacheLifetime))
        cache.setObject(cacheItem, forKey: key as NSString)
    }
    
    func getImage(forKey key: String) -> UIImage? {
        guard let cacheItem = cache.object(forKey: key as NSString) else { return nil }
        if Date() < cacheItem.expirationDate {
            return cacheItem.image
        } else {
            cache.removeObject(forKey: key as NSString)
            return nil
        }
    }
    
    @objc private func didReceiveMemoryWarningNotification() async {
        cache.removeAllObjects()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private class CacheItem {
    let image: UIImage
    let expirationDate: Date
    
    init(image: UIImage, expirationDate: Date) {
        self.image = image
        self.expirationDate = expirationDate
    }
}
