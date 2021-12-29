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
    @AppStorage("userAccentColor") private var userAccentColor = "pattern6Color"
    
    var body: some Scene {
       
        WindowGroup {
            ColumnsView()
               
                
                //.environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
       
    }
}
