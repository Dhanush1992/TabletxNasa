//
//  NASAImageDetailViewModelTests.swift
//  TabletxNasaTests
//
//  Created by Dhanush Thotadur Divakara on 6/13/24.
//

import XCTest
import Combine
@testable import TabletxNasa

final class NASAImageDetailViewModelTests: XCTestCase {
    var viewModel: NASAImageDetailViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }
    
    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }
    
    func testLoadImageSuccess() async {
        let expectation = XCTestExpectation(description: "Load image successfully")
        
        let mockImage = NASAImage(title: "Test Image", description: "A test image", photographer: "Test Photographer", location: "Test Location", url: "https://example.com/test.jpg")
        let mockNetworkService = MockNetworkService()
        let mockImageCache = MockImageCache()
        viewModel = NASAImageDetailViewModel(image: mockImage, networkService: mockNetworkService, imageCache: mockImageCache)
        
        let url = URL(string: mockImage.url)!
        
        await viewModel.loadImage(for: url, forKey: url.absoluteString) { result in
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
    
    func testLoadImageFromCacheSuccess() async {
        let expectation = XCTestExpectation(description: "Load image from cache successfully")
        
        let mockImage = NASAImage(title: "Test Image", description: "A test image", photographer: "Test Photographer", location: "Test Location", url: "https://example.com/test.jpg")
        let mockNetworkService = MockNetworkService()
        let mockImageCache = MockImageCache()
        let testImage = UIImage(systemName: "photo")!
        
        await mockImageCache.setImage(testImage, forKey: mockImage.url)
        viewModel = NASAImageDetailViewModel(image: mockImage, networkService: mockNetworkService, imageCache: mockImageCache)
        
        let url = URL(string: mockImage.url)!
        
        await viewModel.loadImage(for: url, forKey: url.absoluteString) { result in
            switch result {
            case .success(let image):
                XCTAssertEqual(image, testImage)
                expectation.fulfill()
            case .failure:
                XCTFail("Image load from cache failed")
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testLoadImageInvalidURL() async {
        let expectation = XCTestExpectation(description: "Fail to load image due to invalid URL")
        
        let mockImage = NASAImage(title: "Test Image", description: "A test image", photographer: "Test Photographer", location: "Test Location", url: "invalid-url")
        let mockNetworkService = MockNetworkService()
        let mockImageCache = MockImageCache()
        viewModel = NASAImageDetailViewModel(image: mockImage, networkService: mockNetworkService, imageCache: mockImageCache)
        
        let url = URL(string: mockImage.url)!
        
        await viewModel.loadImage(for: url, forKey: url.absoluteString) { result in
            switch result {
            case .success:
                XCTFail("Image load should have failed")
            case .failure(let error):
                XCTAssertEqual((error as? URLError)?.code, .unsupportedURL)
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testLoadImageDecodingFailed() async {
        let expectation = XCTestExpectation(description: "Fail to load image due to decoding error")
        
        let mockImage = NASAImage(title: "Test Image", description: "A test image", photographer: "Test Photographer", location: "Test Location", url: "https://example.com/test.jpg")
        let mockNetworkService = MockNetworkService()
        mockNetworkService.shouldReturnInvalidImage = true // Simulate invalid image data
        let mockImageCache = MockImageCache()
        viewModel = NASAImageDetailViewModel(image: mockImage, networkService: mockNetworkService, imageCache: mockImageCache)
        
        let url = URL(string: mockImage.url)!
        
        await viewModel.loadImage(for: url, forKey: url.absoluteString) { result in
            switch result {
            case .success:
                XCTFail("Image load should have failed")
            case .failure(let error):
                XCTAssertEqual(error as? APIError, APIError.decodingFailed)
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
    
    func testLoadImageNetworkError() async {
        let expectation = XCTestExpectation(description: "Fail to load image due to network error")
        
        let mockImage = NASAImage(title: "Test Image", description: "A test image", photographer: "Test Photographer", location: "Test Location", url: "https://example.com/test.jpg")
        let mockNetworkService = MockNetworkService()
        mockNetworkService.shouldReturnNetworkError = true // Simulate network error
        let mockImageCache = MockImageCache()
        viewModel = NASAImageDetailViewModel(image: mockImage, networkService: mockNetworkService, imageCache: mockImageCache)
        
        let url = URL(string: mockImage.url)!
        
        await viewModel.loadImage(for: url, forKey: url.absoluteString) { result in
            switch result {
            case .success:
                XCTFail("Image load should have failed")
            case .failure(let error):
                XCTAssertEqual((error as? URLError)?.code, .notConnectedToInternet)
                expectation.fulfill()
            }
        }
        
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}
