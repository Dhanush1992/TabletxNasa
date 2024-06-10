//
//  Models.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import Foundation

struct NASAImage: Codable, Hashable {
    let title: String
    let description: String?
    let photographer: String?
    let location: String?
    let url: String
    
    
    // Implementing Equatable and Hashable
    static func == (lhs: NASAImage, rhs: NASAImage) -> Bool {
        return lhs.url == rhs.url
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
    }
}

struct NASAImageSearchResponse: Codable {
    let collection: NASAImageCollection
}

struct NASAImageCollection: Codable {
    let items: [NASAImageItem]
}

struct NASAImageItem: Codable {
    let data: [NASAImageData]
    let links: [NASAImageLink]
}

struct NASAImageData: Codable {
    let title: String
    let description: String?
    let photographer: String?
    let location: String?
}

struct NASAImageLink: Codable {
    let href: String
}
