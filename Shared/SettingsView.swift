//
//  SettingsView.swift
//  Poems2
//
//  Created by Tema Sysoev on 08.07.2021.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        List(){
        Section (header: Text("Reading")){
                Menu("Font style") {
                    Text("System")
                    Text("Rounded")
                    Text("Monoscope")
                }
            
                
            }
            
        }
        .navigationTitle("Settings")
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
