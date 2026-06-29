import SwiftUI

struct SectionDetailView: View {
    let color: Color
    @ObservedObject var viewModel: SectionDetailViewModel
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [color.opacity(0.3), color.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            switch viewModel.viewState {
            case .loading:
                loadingView
            case .loaded(let details):
                detailsView(details: details)
            case .error(let message):
                errorView(message: message)
            }
        }
        .navigationTitle(viewModel.section.title)
        .navigationBarTitleDisplayMode(.large)
        .task {
            await viewModel.loadDetails()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(color)
            Text("Loading details...")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Details View
    
    private func detailsView(details: SectionDetailed) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header card
                VStack(alignment: .leading, spacing: 12) {
                    Text(details.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(color.gradient.opacity(0.3))
                )
                
                // Description section
                VStack(alignment: .leading, spacing: 12) {
                    Label("Description", systemImage: "text.alignleft")
                        .font(.headline)
                        .foregroundStyle(color)
                    
                    Text(details.description)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.background)
                        .shadow(color: .black.opacity(0.1), radius: 8, y: 2)
                )
                
                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Error View
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundStyle(color)
            
            Text("Failed to load details")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button {
                Task {
                    await viewModel.loadDetails()
                }
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(color)
        }
        .padding()
    }
}

// MARK: - Preview

#Preview {
    let api = ApiImpl()
    let cacheManager = MockCacheManager()
    let service = SectionsServiceImpl(api: api, cacheManager: cacheManager)
    let section = Section(
        id: "1",
        title: "Serier",
        href: "https://content.viaplay.com/ios-se/serier",
        type: "vod",
        sectionSort: 1,
        name: "series",
        templated: true
    )
    let viewModel = SectionDetailViewModel(section: section, service: service)
    
    NavigationStack {
        SectionDetailView(
            color: .blue,
            viewModel: viewModel
        )
    }
}
