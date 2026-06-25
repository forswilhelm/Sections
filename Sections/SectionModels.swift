import Foundation

struct Section: Decodable {
    let id: String
    let title: String
    let href: String
    let type: String
    let sectionSort: Int
    let name: String
    let templated: Bool
}
