import Foundation
import Combine

@MainActor
class SectionDetailViewModel: ObservableObject, Identifiable {
    @Published var viewState: ViewState = .loading
    
    let id: String
    let section: Section
    private let service: SectionsService
    
    enum ViewState {
        case loading
        case loaded(SectionDetailed)
        case error(String)
    }
    
    init(section: Section, service: SectionsService) {
        self.id = section.id
        self.section = section
        self.service = service
    }
    
    func loadDetails() async {
        viewState = .loading
        
        do {
            let details = try await service.getSectionDetails(for: section)
            viewState = .loaded(details)
        } catch let error as SectionsServiceError {
            viewState = .error(error.localizedDescription)
        } catch {
            viewState = .error("An unexpected error occurred")
        }
    }
}

// MARK: - Hashable

extension SectionDetailViewModel: Hashable {
    static func == (lhs: SectionDetailViewModel, rhs: SectionDetailViewModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
