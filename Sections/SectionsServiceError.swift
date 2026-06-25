import Foundation

enum SectionsServiceError: Error {
    case apiError(ApiError)
    case unknownError(Error)
    
    var localizedDescription: String {
        switch self {
        case .apiError(let apiError):
            switch apiError {
            case .invalidURL:
                return "The URL is invalid"
            case .invalidResponse:
                return "Received an invalid response from the server"
            case .httpError(let statusCode):
                return "HTTP error with status code: \(statusCode)"
            }
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
