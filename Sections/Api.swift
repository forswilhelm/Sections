import Foundation

protocol Api {
    func getSections() async throws -> [Section]
    func getSectionDetails(from url: String) async throws -> SectionDetailed
}

enum ApiError: Error {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
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

class ApiImpl: Api {
    private let endpoint = "https://content.viaplay.com/ios-se"
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func getSections() async throws -> [Section] {
        guard let url = URL(string: endpoint) else {
            throw ApiError.invalidURL
        }
        
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
        guard let requestUrl = URL(string: url) else {
            throw ApiError.invalidURL
        }
        
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
}

