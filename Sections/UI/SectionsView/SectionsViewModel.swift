import Foundation
import Combine

@MainActor
class SectionsViewModel: ObservableObject {
    enum ViewState {
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
        
        do {
            viewState = .loaded(try await service.getSections())
        } catch let error as SectionsServiceError {
            viewState = .error(error.localizedDescription)
        } catch {
            viewState = .error("An unexpected error occurred")
        }
    }
    
    func selectSection(_ section: Section) {
        selectedSection = section
    }
    
    func makeDetailViewModel(for section: Section) -> SectionDetailViewModel {
        SectionDetailViewModel(section: section, service: service)
    }
}
