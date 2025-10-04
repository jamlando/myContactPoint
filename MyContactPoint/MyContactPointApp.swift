//
//  MyContactPointApp.swift
//  MyContactPoint
//
//  Created by Taylor Larson on 9/19/25.
//

import SwiftUI

@main
struct MyContactPointApp: App {
    @StateObject private var authService = AuthService()
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isAuthenticated {
                    ContentView()
                        .environmentObject(authService)
                } else {
                    AuthenticationView()
                        .environmentObject(authService)
                }
            }
            .onAppear {
                // Check authentication status on app launch
                Task {
                    await authService.checkCurrentSession()
                }
            }
        }
    }
}
