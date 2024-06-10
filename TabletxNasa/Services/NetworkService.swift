//
//  NetworkService.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import Foundation

protocol NetworkServiceProtocol {
    func fetchImages(searchQuery: String, page: Int, startYear: Int, endYear: Int) async throws -> [NASAImage]
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    init() {}
    
    func fetchImages(searchQuery: String, page: Int, startYear: Int, endYear: Int) async throws -> [NASAImage] {
        let urlString = "https://images-api.nasa.gov/search?q=\(searchQuery)&media_type=image&page=\(page)&year_start=\(startYear)&year_end=\(endYear)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200:
            guard let response = try? JSONDecoder().decode(NASAImageSearchResponse.self, from: data) else {
                throw APIError.decodingFailed
            }
            return response.collection.items.compactMap { item in
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
        case 400, 401, 403, 404, 500:
            throw APIError.statusCode(httpResponse.statusCode)
        default:
            throw APIError.statusCode(httpResponse.statusCode)
        }
    }
}
