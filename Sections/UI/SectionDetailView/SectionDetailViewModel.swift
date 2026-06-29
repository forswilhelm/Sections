import Foundation
import Combine

@MainActor
class SectionDetailViewModel: ObservableObject, Identifiable {
    @Published var viewState: ViewState = .loading
    
    let id: String
    let section: Section
    private let service: SectionsService
    
    enum ViewState: Equatable {
        case loading
        case loaded(SectionDetailed)
        case error(String)
        
        // Computed properties for convenience
        var detail: SectionDetailed? {
            if case .loaded(let detail) = self {
                return detail
            }
            return nil
        }
        
        var isLoading: Bool {
            if case .loading = self { return true }
            return false
        }
        
        var errorMessage: String? {
            if case .error(let message) = self {
                return message
            }
            return nil
        }
    }
    
    init(section: Section, service: SectionsService) {
        self.id = section.id
        self.section = section
        self.service = service
    }
    
    func loadDetails() async {
        viewState = .loading
        
        let result = await service.getSectionDetails(for: section)
        
        switch result {
        case .success(let details):
            viewState = .loaded(details)
        case .failure(let error):
            viewState = .error(error.localizedDescription)
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
