//
//  SettingsView.swift
//  Poems2
//
//  Created by Tema Sysoev on 08.07.2021.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("language") private var language = "English"
    @SceneStorage("suggestionStyleDEV") private var suggestionStyleDEV = 0
    @AppStorage("subscribed") private var subscribed = false
    var body: some View {
       
        List(){
            Picker("Language", selection: $language) {
                ForEach(["English", "Russian"], id: \.self) { l in
                    Text(LocalizedStringKey(l))
                }
            }
            .pickerStyle(.menu)
            
            Section(header: Text("Test")){
                Button(action: {
                    subscribed.toggle()
                }, label: {
                    if subscribed {
                        Label("Free functionality", systemImage: "hammer")
                    } else {
                        Label("Unlock full version", systemImage: "hammer")
                    }
                    
                })
                    .tint(Color.red)
                Picker("Search suggestion style", selection: $suggestionStyleDEV) {
                    ForEach([0, 1, 2], id: \.self) { l in
                        Text("\(l)")
                    }
                }
                
            }
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
