//
//  SectionsApp.swift
//  Sections
//
//  Created by Wilhelm Shakely Fors on 2026-06-25.
//

import SwiftUI

@main
struct SectionsApp: App {
    // Dependency injection setup
    private let api: Api = ApiImpl()
    private var service: SectionsService {
        SectionsServiceImpl(api: api)
    }
    
    var body: some Scene {
        WindowGroup {
            SectionsView(viewModel: SectionsViewModel(service: service))
        }
    }
}
