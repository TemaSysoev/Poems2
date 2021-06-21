//
//  NavigationView.swift
//  Poems2
//
//  Created by Tema Sysoev on 08.06.2021.
//

import SwiftUI

struct TripleColumnsView: View {
    @State private var searchText = ""
    var body: some View {
        NavigationView{
      
        List {
            NavigationLink(
                destination: {PoemsListView(source: "local")
                #if os(iOS)
                .navigationBarTitle("Local", displayMode: .automatic)
                #endif
                #if os(macOS)
                .navigationTitle("My library")
                #endif
            },
                label: {
                VStack{
                    Label("My library", systemImage: "book")
                }
                    
                })
            NavigationLink(
                destination: {PoemsListView(source: "online")
                    #if os(iOS)
                    .navigationBarTitle("Online", displayMode: .automatic)
                    #endif
                    #if os(macOS)
                    .navigationTitle("Online")
                    #endif
            },
                label: {
                VStack{
                    
                    Label("Online", systemImage: "globe")
                   
                }
                    
                })
       
            NavigationLink(
                destination: Text("Settings"),
                label: {
                VStack{
                    
                    Label("Settings", systemImage: "gear")
                   
                }
                    
                })
        }
       
        #if os(iOS)
        .navigationBarTitle("Poems 2", displayMode: .automatic)
        #endif
        #if os(macOS)
        .navigationTitle("Poems")
        #endif
        .listStyle(.sidebar)
            PoemsListView(source: "Local")
            PoemView(language: "", author: "", title: "", inputText: "", complete: false)
            
        }
        .navigationViewStyle(.columns)

        
    }
}

struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        TripleColumnsView()
    }
}
