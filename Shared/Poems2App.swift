//
//  Poems2App.swift
//  Shared
//
//  Created by Tema Sysoev on 04.06.2021.
//

import SwiftUI

@main
struct Poems2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
