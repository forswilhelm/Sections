import Foundation

protocol SectionsService {
    func getSections() async throws -> [Section]
    func getSectionDetails(for section: Section) async throws -> SectionDetailed
}

class SectionsServiceImpl: SectionsService {
    private let api: Api
    
    init(api: Api) {
        self.api = api
    }
    
    func getSections() async throws -> [Section] {
        do {
            let sections = try await api.getSections()
            return sections
        } catch let error as ApiError {
            // Handle API-specific errors
            throw SectionsServiceError.apiError(error)
        } catch {
            // Handle any other errors
            throw SectionsServiceError.unknownError(error)
        }
    }
    
    func getSectionDetails(for section: Section) async throws -> SectionDetailed {
        do {
            let details = try await api.getSectionDetails(from: section.cleanHref)
            return details
        } catch let error as ApiError {
            // Handle API-specific errors
            throw SectionsServiceError.apiError(error)
        } catch {
            // Handle any other errors
            throw SectionsServiceError.unknownError(error)
        }
    }
}

