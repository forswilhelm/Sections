import Foundation

/// Mock cache manager for testing purposes.
/// This allows you to test service behavior without needing a real database.
actor MockCacheManager: CacheManaging {
    // Storage for mock data
    private var cachedSections: [Section]?
    private var cachedDetails: [String: SectionDetailed] = [:]
    
    // Control flags for testing different scenarios
    var shouldReturnCachedSections = true
    var shouldReturnCachedDetails = true
    var shouldThrowOnCache = false
    
    // MARK: - CacheManaging Protocol
    
    func cacheSections(_ sections: [Section]) throws {
        if shouldThrowOnCache {
            throw MockCacheError.cachingFailed
        }
        cachedSections = sections
    }
    
    func getCachedSections() -> [Section]? {
        guard shouldReturnCachedSections else { return nil }
        return cachedSections
    }
    
    func cacheSectionDetail(_ detail: SectionDetailed) throws {
        if shouldThrowOnCache {
            throw MockCacheError.cachingFailed
        }
        cachedDetails[detail.sectionId] = detail
    }
    
    func getCachedSectionDetail(for sectionId: String) -> SectionDetailed? {
        guard shouldReturnCachedDetails else { return nil }
        return cachedDetails[sectionId]
    }
    
    func clearAllCache() throws {
        if shouldThrowOnCache {
            throw MockCacheError.cachingFailed
        }
        cachedSections = nil
        cachedDetails.removeAll()
    }
    
    // MARK: - Test Helpers
    
    /// Pre-populate the mock cache with test data
    func preloadSections(_ sections: [Section]) {
        cachedSections = sections
    }
    
    /// Pre-populate the mock cache with test section details
    func preloadSectionDetail(_ detail: SectionDetailed, for sectionId: String) {
        cachedDetails[sectionId] = detail
    }
    
    /// Reset all mock data and flags
    func reset() {
        cachedSections = nil
        cachedDetails.removeAll()
        shouldReturnCachedSections = true
        shouldReturnCachedDetails = true
        shouldThrowOnCache = false
    }
}

enum MockCacheError: Error {
    case cachingFailed
}
