import Foundation
import SwiftData

/// Protocol defining the cache management interface for sections and their details.
/// Conforming types should handle persistence and retrieval of cached data.
protocol CacheManaging: Actor {
    /// Cache a list of sections
    /// - Parameter sections: The sections to cache
    /// - Throws: Error if caching fails
    func cacheSections(_ sections: [Section]) throws
    
    /// Retrieve cached sections if available and not expired
    /// - Returns: Array of cached sections, or nil if cache is empty or expired
    func getCachedSections() -> [Section]?
    
    /// Cache detailed information for a specific section
    /// - Parameters:
    ///   - detail: The section details to cache
    ///   - sectionId: The ID of the section these details belong to
    /// - Throws: Error if caching fails
    func cacheSectionDetail(_ detail: SectionDetailed, for sectionId: String) throws
    
    /// Retrieve cached section details if available and not expired
    /// - Parameter sectionId: The ID of the section to retrieve details for
    /// - Returns: Cached section details, or nil if cache is empty or expired
    func getCachedSectionDetail(for sectionId: String) -> SectionDetailed?
    
    /// Clear all cached data
    /// - Throws: Error if clearing fails
    func clearAllCache() throws
}

/// Actor-based cache manager that persists data using SwiftData.
/// Implements cache expiration and provides offline support for the app.
@ModelActor
actor CacheManagingImpl: CacheManaging {
    // Cache expiration time (e.g., 24 hours)
    private let cacheExpirationInterval: TimeInterval = 24 * 60 * 60
    
    // MARK: - Sections Caching
    
    func cacheSections(_ sections: [Section]) throws {
        // Delete old cached sections
        try modelContext.delete(model: CachedSection.self)
        
        // Insert new sections
        for section in sections {
            modelContext.insert(CachedSection.from(section))
        }
        
        try modelContext.save()
    }
    
    func getCachedSections() -> [Section]? {
        let descriptor = FetchDescriptor<CachedSection>(
            sortBy: [SortDescriptor(\.sectionSort)]
        )
        
        guard let cachedSections = try? modelContext.fetch(descriptor),
              !cachedSections.isEmpty else {
            return nil
        }
        
        // Check if cache is still valid
        if let firstSection = cachedSections.first,
           Date().timeIntervalSince(firstSection.cachedAt) > cacheExpirationInterval {
            return nil // Cache expired
        }
        
        return cachedSections.map { $0.toSection() }
    }
    
    // MARK: - Section Details Caching
    
    func cacheSectionDetail(_ detail: SectionDetailed, for sectionId: String) throws {
        // Remove existing cached detail for this section
        let predicate = #Predicate<CachedSectionDetail> { cached in
            cached.sectionId == sectionId
        }
        
        let descriptor = FetchDescriptor<CachedSectionDetail>(predicate: predicate)
        if let existing = try? modelContext.fetch(descriptor).first {
            modelContext.delete(existing)
        }
        
        // Insert new detail
        modelContext.insert(CachedSectionDetail.from(detail, sectionId: sectionId))
        try modelContext.save()
    }
    
    func getCachedSectionDetail(for sectionId: String) -> SectionDetailed? {
        let predicate = #Predicate<CachedSectionDetail> { cached in
            cached.sectionId == sectionId
        }
        
        let descriptor = FetchDescriptor<CachedSectionDetail>(predicate: predicate)
        
        guard let cachedDetail = try? modelContext.fetch(descriptor).first else {
            return nil
        }
        
        // Check if cache is still valid
        if Date().timeIntervalSince(cachedDetail.cachedAt) > cacheExpirationInterval {
            return nil // Cache expired
        }
        
        return cachedDetail.toSectionDetailed()
    }
    
    // MARK: - Cache Management
    
    func clearAllCache() throws {
        try modelContext.delete(model: CachedSection.self)
        try modelContext.delete(model: CachedSectionDetail.self)
        try modelContext.save()
    }
}
