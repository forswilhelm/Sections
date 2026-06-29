import Foundation
import Combine

@MainActor
class SectionsViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case loaded([Section])
        case error(String)
        
        // Computed properties for convenience
        var sections: [Section]? {
            if case .loaded(let sections) = self {
                return sections
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
    
    @Published var viewState: ViewState = .loading
    @Published var selectedSection: Section?
    
    private let service: SectionsService
    
    init(service: SectionsService) {
        self.service = service
    }
    
    func loadSections() async {
        viewState = .loading
        
        let result = await service.getSections()
        
        switch result {
        case .success(let sections):
            viewState = .loaded(sections)
        case .failure(let error):
            viewState = .error(error.localizedDescription)
        }
    }
    
    func selectSection(_ section: Section) {
        selectedSection = section
    }
    
    func makeDetailViewModel(for section: Section) -> SectionDetailViewModel {
        SectionDetailViewModel(section: section, service: service)
    }
}
