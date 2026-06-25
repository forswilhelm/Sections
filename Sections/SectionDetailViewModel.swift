import Foundation
import Combine

@MainActor
class SectionDetailViewModel: ObservableObject {
    @Published var viewState: ViewState = .loading
    
    private let section: Section
    private let service: SectionsService
    
    enum ViewState {
        case loading
        case loaded(SectionDetailed)
        case error(String)
    }
    
    init(section: Section, service: SectionsService) {
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
