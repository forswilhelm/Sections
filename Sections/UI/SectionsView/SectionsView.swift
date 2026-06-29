import SwiftUI

struct SectionsView: View {
    @StateObject private var viewModel: SectionsViewModel
    
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    private let sectionColors: [Color] = [
        .blue, .purple, .green, .orange, .red, .pink, .teal, .indigo
    ]
    
    init(viewModel: SectionsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                switch viewModel.viewState {
                case .loading:
                    loadingView
                case .loaded(let sections):
                    sectionsGridView(sections: sections)
                case .error(let message):
                    errorView(message: message)
                }
            }
            .navigationTitle("Sections")
            .navigationDestination(item: $viewModel.selectedSection) { section in
                SectionDetailView(
                    color: colorForSection(section),
                    viewModel: viewModel.makeDetailViewModel(for: section)
                )
            }
            .task {
                await viewModel.loadSections()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func colorForSection(_ section: Section) -> Color {
        guard case .loaded(let sections) = viewModel.viewState,
              let index = sections.firstIndex(where: { $0.id == section.id }) else {
            return .blue
        }
        return sectionColors[index % sectionColors.count]
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading sections...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Sections Grid View
    
    private func sectionsGridView(sections: [Section]) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                    SectionCard(
                        section: section,
                        color: sectionColors[index % sectionColors.count],
                        onTap: {
                            viewModel.selectSection(section)
                        }
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.red)
            
            Text("Failed to get sections")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    await viewModel.loadSections()
                }
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    let api = ApiImpl()
    let cacheManager = MockCacheManager()
    let service = SectionsServiceImpl(api: api, cacheManager: cacheManager)
    let viewModel = SectionsViewModel(service: service)
    
    SectionsView(viewModel: viewModel)
}
