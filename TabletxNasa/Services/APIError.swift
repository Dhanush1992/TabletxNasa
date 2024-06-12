//
//  APIError.swift
//  TabletxNasa
//
//  Created by Dhanush Thotadur Divakara on 6/8/24.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case requestFailed
    case invalidResponse
    case noData
    case decodingFailed
    case statusCode(Int)
    case custom(String)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .requestFailed:
            return "The network request failed."
        case .invalidResponse:
            return "The response is invalid."
        case .noData:
            return "No data was received."
        case .decodingFailed:
            return "Failed to decode the data."
        case .statusCode(let code):
            return "Received HTTP status code \(code)."
        case .custom(let message):
            return message
        }
    }
}

extension APIError: Equatable {
    static func ==(lhs: APIError, rhs: APIError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL):
            return true
        case (.invalidResponse, .invalidResponse):
            return true
        case (.decodingFailed, .decodingFailed):
            return true
        case let (.statusCode(lhsCode), .statusCode(rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}

