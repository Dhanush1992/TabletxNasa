//
//  NetworkService.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchImages(searchQuery: String, page: Int, startYear: Int, endYear: Int) async -> Result<[NASAImage], Error>
    func fetchImageData(from url: URL) async -> Result<Data, Error>
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    init() {}
    
    func fetchImages(searchQuery: String, page: Int, startYear: Int, endYear: Int) async -> Result<[NASAImage], Error> {
        let urlString = "https://images-api.nasa.gov/search?q=\(searchQuery)&media_type=image&page=\(page)&year_start=\(startYear)&year_end=\(endYear)"
        guard let url = URL(string: urlString) else {
            return .failure(APIError.invalidURL)
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(APIError.invalidResponse)
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard let response = try? JSONDecoder().decode(NASAImageSearchResponse.self, from: data) else {
                    return .failure(APIError.decodingFailed)
                }
                let images: [NASAImage] = response.collection.items.compactMap { item in
                    guard let data = item.data.first, let link = item.links.first else {
                        return nil
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
            case 400, 401, 403, 404, 500:
                return .failure(APIError.statusCode(httpResponse.statusCode))
            default:
                return .failure(APIError.statusCode(httpResponse.statusCode))
            }
        } catch {
            return .failure(error)
        }
    }
    
    func fetchImageData(from url: URL) async -> Result<Data, Error> {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return .failure(APIError.invalidResponse)
            }
            
            return .success(data)
        } catch {
            return .failure(error)
        }
    }
}

