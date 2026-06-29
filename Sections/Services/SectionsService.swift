import Foundation
import SwiftData

protocol SectionsService {
    func getSections() async throws -> [Section]
    func getSectionDetails(for section: Section) async throws -> SectionDetailed
}

class SectionsServiceImpl: SectionsService {
    private let api: Api
    private let cacheManager: any CacheManaging
    
    /// Initialize with dependencies for better testability
    /// - Parameters:
    ///   - api: The API layer for network requests
    ///   - cacheManager: The cache manager for offline support (can be mocked for testing)
    init(api: Api, cacheManager: any CacheManaging) {
        self.api = api
        self.cacheManager = cacheManager
    }
    
    func getSections() async throws -> [Section] {
        // Try to fetch from network first
        do {
            let sections = try await api.getSections()
            
            // Cache the successful response
            try? await cacheManager.cacheSections(sections)
            
            return sections
        } catch let error as ApiError {
            // If network fails, try to return cached data
            if let cachedSections = await cacheManager.getCachedSections() {
                return cachedSections
            }
            
            // No cache available, throw the original error
            throw SectionsServiceError.apiError(error)
        } catch {
            // If network fails, try to return cached data
            if let cachedSections = await cacheManager.getCachedSections() {
                return cachedSections
            }
            
            throw SectionsServiceError.unknownError(error)
        }
    }
    
    func getSectionDetails(for section: Section) async throws -> SectionDetailed {
        // Try to fetch from network first
        do {
            let details = try await api.getSectionDetails(from: section.cleanHref)
            
            // Cache the successful response
            try? await cacheManager.cacheSectionDetail(details, for: section.id)
            
            return details
        } catch let error as ApiError {
            // If network fails, try to return cached data
            if let cachedDetail = await cacheManager.getCachedSectionDetail(for: section.id) {
                return cachedDetail
            }
            
            // No cache available, throw the original error
            throw SectionsServiceError.apiError(error)
        } catch {
            // If network fails, try to return cached data
            if let cachedDetail = await cacheManager.getCachedSectionDetail(for: section.id) {
                return cachedDetail
            }
            
            throw SectionsServiceError.unknownError(error)
        }
    }
}

