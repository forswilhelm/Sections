//
//  SectionsApp.swift
//  Sections
//
//  Created by Wilhelm Shakely Fors on 2026-06-25.
//

import SwiftUI
import SwiftData

@main
struct SectionsApp: App {
    // SwiftData model container
    let modelContainer: ModelContainer
    
    // Dependency injection setup
    private let api: Api = ApiImpl()
    private var service: SectionsService
    
    init() {
        do {
            // Initialize SwiftData container with the models
            modelContainer = try ModelContainer(
                for: CachedSection.self, CachedSectionDetail.self
            )
            
            // Initialize cache manager with ModelContext
            let cacheManager = CacheManagingImpl(modelContainer: modelContainer)
            
            // Initialize service with cache support
            service = SectionsServiceImpl(api: api, cacheManager: cacheManager)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            SectionsView(viewModel: SectionsViewModel(service: service))
        }
        .modelContainer(modelContainer)
    }
}
