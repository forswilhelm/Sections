import Foundation

struct Section: Decodable {
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
        href.replacingOccurrences(of: #"\{[^}]*\}"#, with: "", options: .regularExpression)
    }
}

struct SectionDetailed: Decodable {
    let title: String
    let description: String
}
