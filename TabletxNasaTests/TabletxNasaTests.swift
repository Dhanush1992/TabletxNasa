//
//  TabletxNasaTests.swift
//  TabletxNasaTests
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import XCTest
import Combine
@testable import TabletxNasa

final class NASAImageViewModelTests: XCTestCase {
    var viewModel: NASAImageViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        let mockNetworkService = MockNetworkService()
        let mockImageCache = MockImageCache()
        viewModel = NASAImageViewModel(networkService: mockNetworkService, imageCache: mockImageCache)
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    func testSearchImagesSuccess() async {
        let expectation = XCTestExpectation(description: "Fetch images successfully")

        viewModel.onImagesUpdated = {
            expectation.fulfill()
        }

        await viewModel.searchImages(query: "Earth", startYear: 1920, endYear: 2024)

        await fulfillment(of: [expectation], timeout: 5.0)

        XCTAssertEqual(viewModel.images.count, 2)
        XCTAssertEqual(viewModel.images[0].title, "The Earth & Moon")
        XCTAssertEqual(viewModel.images[1].title, "Earth - India and Australia")
    }

    func testSearchImagesFailure() async {
        let expectation = XCTestExpectation(description: "Fail to fetch images")

        // Modify mock response to trigger a decoding error
        let mockNetworkService = MockNetworkService()
        mockNetworkService.mockResponse = "{ \"invalid\": \"response\" }"
        viewModel = NASAImageViewModel(networkService: mockNetworkService, imageCache: MockImageCache())

        viewModel.onFetchError = { error in
            XCTAssertEqual(error as? APIError, APIError.decodingFailed)
            expectation.fulfill()
        }

        await viewModel.searchImages(query: "Earth", startYear: 1920, endYear: 2024)

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testLoadMoreImagesSuccess() async {
        await viewModel.searchImages(query: "Earth", startYear: 1920, endYear: 2024)

        XCTAssertEqual(viewModel.images.count, 2)

        await viewModel.loadMoreImages(startYear: 1920, endYear: 2024)

        XCTAssertEqual(viewModel.images.count, 4)
    }

    func testLoadImageSuccess() async {
        let expectation = XCTestExpectation(description: "Load image successfully")

        let url = URL(string: "https://images-assets.nasa.gov/image/PIA00342/PIA00342~thumb.jpg")!
        await viewModel.loadImage(for: url, forKey: "PIA00342") { result in
            switch result {
            case .success(let image):
                XCTAssertNotNil(image)
                expectation.fulfill()
            case .failure:
                XCTFail("Image load failed")
            }
        }

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testLoadImageFailure() async {
        let expectation = XCTestExpectation(description: "Fail to load image")

        // Mock an invalid URL to trigger a failure
        let url = URL(string: "https://invalid-url")!
        await viewModel.loadImage(for: url, forKey: "InvalidKey") { result in
            switch result {
            case .success:
                XCTFail("Image load should have failed")
            case .failure:
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: 5.0)
    }
}

class MockImageCache: ImageCacheProtocol {
    private var cache = [String: UIImage]()

    func getImage(forKey key: String) async -> UIImage? {
        return cache[key]
    }

    func setImage(_ image: UIImage, forKey key: String) async {
        cache[key] = image
    }
}

class MockNetworkService: NetworkServiceProtocol {
    var mockResponse: String?

    func fetchImages(searchQuery: String, page: Int, startYear: Int, endYear: Int) async -> Result<[NASAImage], Error> {
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
}
