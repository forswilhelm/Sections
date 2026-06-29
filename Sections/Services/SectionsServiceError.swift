import Foundation

enum SectionsServiceError: LocalizedError {
    case apiError(ApiError)
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .apiError(let apiError):
            return apiError.errorDescription
        case .unknownError(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
}
