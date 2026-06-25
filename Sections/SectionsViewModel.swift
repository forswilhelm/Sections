import Foundation
import Combine

@MainActor
class SectionsViewModel: ObservableObject {
    @Published var sections: [Section] = []
    @Published var viewState: ViewState = .loading
    
    private let service: SectionsService
    
    enum ViewState {
        case loading
        case loaded
        case error(String)
    }
    
    init(service: SectionsService) {
        self.service = service
    }
    
    func loadSections() async {
        viewState = .loading
        
        do {
            sections = try await service.getSections()
            viewState = .loaded
        } catch let error as SectionsServiceError {
            viewState = .error(error.localizedDescription)
        } catch {
            viewState = .error("An unexpected error occurred")
        }
    }
}
