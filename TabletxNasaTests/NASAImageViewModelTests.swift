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
    
    func testNetworkError() async {
        let expectation = XCTestExpectation(description: "Fail due to network error")
        
        // Modify mock network service to simulate a network error
        let mockNetworkService = MockNetworkService()
        mockNetworkService.shouldReturnNetworkError = true
        viewModel = NASAImageViewModel(networkService: mockNetworkService, imageCache: MockImageCache())
        
        viewModel.onFetchError = { error in
            XCTAssertEqual(error as? URLError, URLError(.notConnectedToInternet))
            expectation.fulfill()
        }
        
        await viewModel.searchImages(query: "Earth", startYear: 1920, endYear: 2024)
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testEmptyResponse() async {
        let expectation = XCTestExpectation(description: "Handle empty response")

        // Modify mock network service to simulate an empty response
        let mockNetworkService = MockNetworkService()
        mockNetworkService.mockResponse = """
        {
            "collection": {
                "version": "1.0",
                "href": "http://images-api.nasa.gov/search?q=Earth&media_type=image&page=1&year_start=1920&year_end=2024",
                "items": []
            }
        }
        """
        viewModel = NASAImageViewModel(networkService: mockNetworkService, imageCache: MockImageCache())

        viewModel.onImagesUpdated = {
            XCTAssertEqual(self.viewModel.images.count, 0)
            expectation.fulfill()
        }

        await viewModel.searchImages(query: "Earth", startYear: 1920, endYear: 2024)

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testTimeoutError() async {
        let expectation = XCTestExpectation(description: "Fail due to timeout")
        
        // Modify mock network service to simulate a timeout
        let mockNetworkService = MockNetworkService()
        mockNetworkService.shouldReturnTimeoutError = true
        viewModel = NASAImageViewModel(networkService: mockNetworkService, imageCache: MockImageCache())
        
        viewModel.onFetchError = { error in
            XCTAssertEqual(error as? URLError, URLError(.timedOut))
            expectation.fulfill()
        }
        
        await viewModel.searchImages(query: "Earth", startYear: 1920, endYear: 2024)
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    func testPartialDataHandling() async {
        let expectation = XCTestExpectation(description: "Handle partial data")
        
        // Modify mock network service to simulate a response with partial data
        let mockNetworkService = MockNetworkService()
        mockNetworkService.mockResponse = """
            {
                "collection": {
                    "version": "1.0",
                    "href": "http://images-api.nasa.gov/search?q=Earth&media_type=image&page=1&year_start=1920&year_end=2024",
                    "items": [
                        {
                            "href": "https://images-assets.nasa.gov/image/PIA00342/collection.json",
                            "data": [
                                {
                                    "title": "The Earth & Moon"
                                }
                            ],
                            "links": [
                                {
                                    "href": "https://images-assets.nasa.gov/image/PIA00342/PIA00342~thumb.jpg"
                                }
                            ]
                        }
                    ]
                }
            }
            """
        viewModel = NASAImageViewModel(networkService: mockNetworkService, imageCache: MockImageCache())
        
        viewModel.onImagesUpdated = {
            if self.viewModel.images.count == 1 {
                XCTAssertEqual(self.viewModel.images[0].title, "The Earth & Moon")
                XCTAssertEqual(self.viewModel.images[0].url, "https://images-assets.nasa.gov/image/PIA00342/PIA00342~thumb.jpg")
                expectation.fulfill()
            }
        }
        
        await viewModel.searchImages(query: "Earth", startYear: 1920, endYear: 2024)
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}
