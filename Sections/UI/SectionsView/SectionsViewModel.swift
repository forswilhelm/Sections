import Foundation
import Combine
import SwiftUI

@MainActor
class SectionsViewModel: ObservableObject {
    enum ViewState {
        case loading
        case loaded([Section])
        case error(String)
    }
    
    struct SectionSelection: Identifiable, Hashable {
        let id = UUID()
        let viewModel: SectionDetailViewModel
        let color: Color
        
        static func == (lhs: SectionSelection, rhs: SectionSelection) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    @Published var viewState: ViewState = .loading
    @Published var selectedSection: SectionSelection?
    
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
    
    func selectSection(_ section: Section, color: Color) {
        let detailViewModel = SectionDetailViewModel(section: section, service: service)
        selectedSection = SectionSelection(viewModel: detailViewModel, color: color)
    }
}
