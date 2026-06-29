import Foundation
import SwiftData

// MARK: - Domain Models (API Response)

struct Section: Decodable, Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let href: String
    let type: String
    let sectionSort: Int
    let name: String
    let templated: Bool
    
    /// Returns the href with URI template placeholders removed
    var cleanHref: String {
        // Remove URI template syntax like {param} or {?param}
        href.replacing(/\{[^}]*\}/, with: "")
    }
}

struct SectionDetailed: Decodable, Sendable {
    let title: String
    let description: String
}

// MARK: - SwiftData Models (Cached Data)

/// SwiftData model for caching Section data.
/// Must be a class because SwiftData uses reference semantics to track changes
/// and manage the object graph in the persistent store.
@Model
final class CachedSection {
    @Attribute(.unique) var id: String
    var title: String
    var href: String
    var type: String
    var sectionSort: Int
    var name: String
    var templated: Bool
    var cachedAt: Date
    
    init(
        id: String,
        title: String,
        href: String,
        type: String,
        sectionSort: Int,
        name: String,
        templated: Bool,
        cachedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.href = href
        self.type = type
        self.sectionSort = sectionSort
        self.name = name
        self.templated = templated
        self.cachedAt = cachedAt
    }
    
    /// Convert to the domain model
    func toSection() -> Section {
        Section(
            id: id,
            title: title,
            href: href,
            type: type,
            sectionSort: sectionSort,
            name: name,
            templated: templated
        )
    }
    
    /// Create from the domain model
    static func from(_ section: Section) -> CachedSection {
        CachedSection(
            id: section.id,
            title: section.title,
            href: section.href,
            type: section.type,
            sectionSort: section.sectionSort,
            name: section.name,
            templated: section.templated
        )
    }
}

/// SwiftData model for caching SectionDetailed data.
/// Must be a class because SwiftData uses reference semantics to track changes
/// and manage the object graph in the persistent store.
@Model
final class CachedSectionDetail {
    @Attribute(.unique) var sectionId: String
    var title: String
    var descriptionText: String
    var cachedAt: Date
    
    init(sectionId: String, title: String, descriptionText: String, cachedAt: Date = Date()) {
        self.sectionId = sectionId
        self.title = title
        self.descriptionText = descriptionText
        self.cachedAt = cachedAt
    }
    
    /// Convert to the domain model
    func toSectionDetailed() -> SectionDetailed {
        SectionDetailed(title: title, description: descriptionText)
    }
    
    /// Create from the domain model
    static func from(_ detail: SectionDetailed, sectionId: String) -> CachedSectionDetail {
        CachedSectionDetail(
            sectionId: sectionId,
            title: detail.title,
            descriptionText: detail.description
        )
    }
}
