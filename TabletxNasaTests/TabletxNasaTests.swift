//
//  TabletxNasaTests.swift
//  TabletxNasaTests
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import XCTest
import Combine
@testable import TabletxNasa

class NASAImageViewModelTests: XCTestCase {
    var viewModel: NASAImageViewModel!
    var mockNetworkService: MockNetworkService!
    var mockImageCache: MockImageCache!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        mockImageCache = MockImageCache()
        viewModel = NASAImageViewModel(networkService: mockNetworkService, imageCache: mockImageCache)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        mockImageCache = nil
        cancellables = nil
        super.tearDown()
    }

    // Add tests for search success based on mock data that seems real, 
    func testSearchImages_failure() async {
        let expectation = XCTestExpectation(description: "Error handled")
        mockNetworkService.error = URLError(.badServerResponse)
        
        viewModel.onFetchError = { error in
            XCTAssertEqual((error as? URLError)?.code, URLError.Code.badServerResponse)
            expectation.fulfill()
        }
        
        await viewModel.searchImages(query: "Earth", startYear: 1920, endYear: 2024)
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testLoadMoreImages_success() async {
        let initialImages = [NASAImage(title: "Initial Image", description: "An initial image", photographer: "Tester", location: "Test Location", url: "http://example.com/image1.jpg")]
        let moreImages = [NASAImage(title: "More Image", description: "A more image", photographer: "Tester", location: "Test Location", url: "http://example.com/image2.jpg")]
        
        mockNetworkService.images = initialImages

        await viewModel.searchImages(query: "test", startYear: 2000, endYear: 2020)
        
        // Assert initial state
        XCTAssertEqual(viewModel.images.count, initialImages.count)
        
        mockNetworkService.images = moreImages
        
        await viewModel.loadMoreImages(startYear: 2000, endYear: 2020)
        
        // Assert final state
        XCTAssertEqual(viewModel.images.count, initialImages.count + moreImages.count)
    }

    func testLoadMoreImages_failure() async {
        let initialImages = [NASAImage(title: "Initial Image", description: "An initial image", photographer: "Tester", location: "Test Location", url: "http://example.com/image1.jpg")]
        mockNetworkService.images = initialImages

        await viewModel.searchImages(query: "test", startYear: 2000, endYear: 2020)
        
        mockNetworkService.error = URLError(.timedOut)
        
        let expectation = XCTestExpectation(description: "Error handled on load more")
        viewModel.onFetchError = { error in
            XCTAssertEqual((error as? URLError)?.code, URLError.Code.timedOut)
            expectation.fulfill()
        }
        
        await viewModel.loadMoreImages(startYear: 2000, endYear: 2020)
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func testLoadImage_fromCache() async {
        let cachedImage = UIImage(systemName: "photo")!
        mockImageCache.cachedImage = cachedImage
        mockImageCache.cachedImages["http://example.com/image.jpg"] = cachedImage
        
        let expectation = XCTestExpectation(description: "Image loaded from cache")
        await viewModel.loadImage(for: URL(string: "http://example.com/image.jpg")!, forKey: "http://example.com/image.jpg") { image in
            XCTAssertEqual(image, cachedImage)
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}

class MockImageCache: ImageCacheProtocol {
    var cachedImage: UIImage?
    var cachedImages: [String: UIImage] = [:]

    func setImage(_ image: UIImage, forKey key: String) async {
        cachedImages[key] = image
    }

    func getImage(forKey key: String) async -> UIImage? {
        return cachedImages[key]
    }
}


class MockNetworkService: NetworkServiceProtocol {
    var images: [NASAImage]?
    var error: Error?
    var imageData: Data?

    func fetchImages(searchQuery: String, page: Int, startYear: Int, endYear: Int) async throws -> [NASAImage] {
        if let error = error {
            throw error
        }
        
        if let images = images {
            return images
        }
        
        // Sample mock data based on the provided JSON response
        let mockResponse = """
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
        """
        let data = Data(mockResponse.utf8)
        let decodedResponse = try JSONDecoder().decode(NASAImageSearchResponse.self, from: data)
        return decodedResponse.collection.items.map { item in
            let imageData = item.data.first!
            return NASAImage(
                title: imageData.title,
                description: imageData.description,
                photographer: imageData.photographer,
                location: nil,
                url: item.links.first?.href ?? ""
            )
        }
    }

    func fetchImageData(from url: URL) async throws -> (Data, URLResponse) {
        if let error = error {
            throw error
        }
        let data = imageData ?? Data()
        let response = URLResponse(url: url, mimeType: "image/png", expectedContentLength: data.count, textEncodingName: nil)
        return (data, response)
    }
}

