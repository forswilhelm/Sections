import Foundation
import SwiftData
import os

/// Service responsible for fetching and managing section data.
/// Implements offline-first strategy with automatic caching.
protocol SectionsService: Sendable {
    /// Fetches all available sections from the API.
    /// Falls back to cached data if network request fails.
    /// - Returns: Result containing either sections array or error
    func getSections() async -> Result<[Section], SectionsServiceError>
    
    /// Fetches detailed information for a specific section.
    /// - Parameter section: The section to fetch details for
    /// - Returns: Result containing either section details or error
    func getSectionDetails(for section: Section) async -> Result<SectionDetailed, SectionsServiceError>
}

final class SectionsServiceImpl: SectionsService {
    private let api: Api
    private let cacheManager: any CacheManaging
    private let logger = Logger(subsystem: "com.sections.app", category: "service")
    
    /// Initialize with dependencies for better testability
    /// - Parameters:
    ///   - api: The API layer for network requests
    ///   - cacheManager: The cache manager for offline support (can be mocked for testing)
    init(api: Api, cacheManager: any CacheManaging) {
        self.api = api
        self.cacheManager = cacheManager
    }
    
    func getSections() async -> Result<[Section], SectionsServiceError> {
        // Try to fetch from network first
        do {
            let sections = try await api.getSections()
            
            // Cache the successful response
            do {
                try await cacheManager.cacheSections(sections)
            } catch {
                logger.warning("Failed to cache sections: \(error.localizedDescription)")
            }
            
            return .success(sections)
        } catch let error as ApiError {
            // If network fails, try to return cached data
            if let cachedSections = await cacheManager.getCachedSections() {
                logger.info("Network failed, returning cached sections")
                return .success(cachedSections)
            }
            
            // No cache available, return the error
            return .failure(.apiError(error))
        } catch {
            // If network fails, try to return cached data
            if let cachedSections = await cacheManager.getCachedSections() {
                logger.info("Network failed, returning cached sections")
                return .success(cachedSections)
            }
            
            return .failure(.unknownError(error))
        }
    }
    
    func getSectionDetails(for section: Section) async -> Result<SectionDetailed, SectionsServiceError> {
        // Try to fetch from network first
        do {
            let details = try await api.getSectionDetails(from: section.cleanHref)
            
            // Cache the successful response
            do {
                try await cacheManager.cacheSectionDetail(details)
            } catch {
                logger.warning("Failed to cache section detail: \(error.localizedDescription)")
            }
            
            return .success(details)
        } catch let error as ApiError {
            // If network fails, try to return cached data
            if let cachedDetail = await cacheManager.getCachedSectionDetail(for: section.id) {
                logger.info("Network failed, returning cached section detail")
                return .success(cachedDetail)
            }
            
            // No cache available, return the error
            return .failure(.apiError(error))
        } catch {
            // If network fails, try to return cached data
            if let cachedDetail = await cacheManager.getCachedSectionDetail(for: section.id) {
                logger.info("Network failed, returning cached section detail")
                return .success(cachedDetail)
            }
            
            return .failure(.unknownError(error))
        }
    }
}

