//
//  MockServices.swift
//  TabletxNasaTests
//
//  Created by Dhanush Thotadur Divakara on 6/13/24.
//

import Foundation
import Combine
import UIKit
@testable import TabletxNasa

// Mock Network Service
class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: String?
    var shouldReturnInvalidImage = false
    var shouldReturnNetworkError = false
    var shouldReturnDecodingError = false
    var shouldReturnTimeoutError = false

    func fetchImages(searchQuery: String, page: Int, startYear: Int, endYear: Int) async -> Result<[NASAImage], Error> {
        if shouldReturnNetworkError {
            return .failure(URLError(.notConnectedToInternet))
        }
        if shouldReturnTimeoutError {
            return .failure(URLError(.timedOut))
        }
        if shouldReturnDecodingError {
            return .failure(APIError.decodingFailed)
        }
        if let response = mockResponse, response == "{ \"invalid\": \"response\" }" {
            return .failure(APIError.decodingFailed)
        }

        let data = Data(mockResponse?.utf8 ?? """
        {
            "collection": {
                "version": "1.0",
                "href": "http://images-api.nasa.gov/search?q=Earth&media_type=image&page=1&year_start=1920&year_end=2024",
                "items": [
                    {
                        "href": "https://images-assets.nasa.gov/image/PIA00342/collection.json",
                        "data": [
                            {
                                "center": "JPL",
                                "title": "The Earth & Moon",
                                "nasa_id": "PIA00342",
                                "date_created": "1998-06-04T18:10:28Z",
                                "keywords": ["Earth", "Galileo"],
                                "media_type": "image",
                                "description_508": "During its flight, NASA’s Galileo spacecraft returned images of the Earth and Moon. Separate images of the Earth and Moon were combined to generate this view.",
                                "secondary_creator": "NASA/JPL/USGS",
                                "description": "During its flight, NASA’s Galileo spacecraft returned images of the Earth and Moon. Separate images of the Earth and Moon were combined to generate this view. http://photojournal.jpl.nasa.gov/catalog/PIA00342"
                            }
                        ],
                        "links": [
                            {
                                "href": "https://images-assets.nasa.gov/image/PIA00342/PIA00342~thumb.jpg",
                                "rel": "preview",
                                "render": "image"
                            }
                        ]
                    },
                    {
                        "href": "https://images-assets.nasa.gov/image/PIA00122/collection.json",
                        "data": [
                            {
                                "center": "JPL",
                                "title": "Earth - India and Australia",
                                "nasa_id": "PIA00122",
                                "date_created": "1996-02-08T10:48:12Z",
                                "keywords": ["Earth", "Galileo"],
                                "media_type": "image",
                                "description_508": "This color image of the Earth was obtained by NASA’s Galileo spacecraft on Dec. 11, 1990, when the spacecraft was about 1.5 million miles from the Earth.",
                                "secondary_creator": "NASA/JPL",
                                "description": "This color image of the Earth was obtained by NASA’s Galileo spacecraft on Dec. 11, 1990, when the spacecraft was about 1.5 million miles from the Earth. http://photojournal.jpl.nasa.gov/catalog/PIA00122"
                            }
                        ],
                        "links": [
                            {
                                "href": "https://images-assets.nasa.gov/image/PIA00122/PIA00122~thumb.jpg",
                                "rel": "preview",
                                "render": "image"
                            }
                        ]
                    }
                ]
            }
        }
        """.utf8)

        do {
            let response = try JSONDecoder().decode(NASAImageSearchResponse.self, from: data)
            let images: [NASAImage] = response.collection.items.compactMap { item in
                guard let data = item.data.first, let link = item.links.first else {
                    return NASAImage(
                        title: "",
                        description: "",
                        photographer: "",
                        location: "",
                        url: ""
                    )
                }
                return NASAImage(
                    title: data.title,
                    description: data.description,
                    photographer: data.photographer,
                    location: data.location,
                    url: link.href
                )
            }
            return .success(images)
        } catch {
            return .failure(APIError.decodingFailed)
        }
    }
    
    func fetchImageData(from url: URL) async -> Result<Data, Error> {
        if url.absoluteString == "invalid-url" {
            return .failure(URLError(.unsupportedURL))
        }
        if shouldReturnNetworkError {
            return .failure(URLError(.notConnectedToInternet))
        }
        
        if shouldReturnInvalidImage {
            return .success(Data()) // Return invalid image data
        }
        
        let imageData = UIImage(systemName: "photo")!.pngData()!
        return .success(imageData)
    }
}


// Mock Image Cache
class MockImageCache: ImageCacheProtocol {
    private var cache = [String: UIImage]()

    func getImage(forKey key: String) async -> UIImage? {
        return cache[key]
    }

    func setImage(_ image: UIImage, forKey key: String) async {
        cache[key] = image
    }
}
