import Foundation

protocol Api: Sendable {
    func getSections() async throws -> [Section]
    func getSectionDetails(from url: String) async throws -> SectionDetailed
}

enum ApiError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case insecureURL
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .invalidResponse:
            return "Received an invalid response from the server"
        case .httpError(let statusCode):
            return "Server returned HTTP status code: \(statusCode)"
        case .insecureURL:
            return "Only HTTPS URLs are allowed for security"
        }
    }
}

struct ApiResponse: Decodable {
    let links: Links
    
    enum CodingKeys: String, CodingKey {
        case links = "_links"
    }
    
    struct Links: Decodable {
        let sections: [Section]
        
        enum CodingKeys: String, CodingKey {
            case sections = "viaplay:sections"
        }
    }
}

final class ApiImpl: Api {
    private let endpoint = "https://content.viaplay.com/ios-se"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func getSections() async throws -> [Section] {
        let url = try validateSecureURL(endpoint)
        
        let (data, response) = try await urlSession.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ApiError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(ApiResponse.self, from: data)
        
        return apiResponse.links.sections
    }
    
    func getSectionDetails(from url: String) async throws -> SectionDetailed {
        let requestUrl = try validateSecureURL(url)
        
        let (data, response) = try await urlSession.data(from: requestUrl)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ApiError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw ApiError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        let sectionDetails = try decoder.decode(SectionDetailed.self, from: data)
        
        return sectionDetails
    }
    
    /// Validates that the URL is secure (HTTPS only)
    private func validateSecureURL(_ urlString: String) throws -> URL {
        guard let url = URL(string: urlString) else {
            throw ApiError.invalidURL
        }
        
        guard let scheme = url.scheme?.lowercased() else {
            throw ApiError.invalidURL
        }
        
        // Enforce HTTPS for security
        guard scheme == "https" else {
            throw ApiError.insecureURL
        }
        
        return url
    }
}

