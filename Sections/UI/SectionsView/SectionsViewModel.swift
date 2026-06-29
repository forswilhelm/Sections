import Foundation
import Combine

@MainActor
class SectionsViewModel: ObservableObject {
    enum ViewState: Equatable {
        case loading
        case loaded([Section])
        case error(String)
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
