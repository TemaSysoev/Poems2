//
//  NavigationView.swift
//  Poems2
//
//  Created by Tema Sysoev on 08.06.2021.
//

import SwiftUI

struct TripleColumnsView: View {
    var body: some View {
        NavigationView{
      
        List {
            NavigationLink(
                destination: PoemsListView(source: "Local"),
                label: {
                VStack{
                    Label("My library", systemImage: "book")
                }
                    
                })
            Section(header: Text("Online")){
           
                NavigationLink(
                    destination: PoemsListView(source: "Poemist"),
                    label: {
                    VStack{
                        
                        Label("Poemist", systemImage: "globe")
                       
                    }
                        
                    })
                NavigationLink(
                    destination: PoemsListView(source: "Poetry"),
                    label: {
                    VStack{
                        
                        Label("Poetry", systemImage: "globe")
                       
                    }
                        
                    })
            
            
            }
        }
        #if os(iOS)
        .navigationBarTitle("Poems 2", displayMode: .automatic)
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
