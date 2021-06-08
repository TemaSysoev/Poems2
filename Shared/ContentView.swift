//
//  ContentView.swift
//  Shared
//
//  Created by Tema Sysoev on 04.06.2021.
//

import SwiftUI
import CoreData

struct WebPoem{
    let author: String
    let title: String
    let text: String
    let language: String
}
struct ListOfPoems: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Poem.title, ascending: true)],
        animation: .default)
    private var poems: FetchedResults<Poem>
    @State private var onlinePoems = WebPoemsHelper().getPoemsFromJson(site: "https://www.poemist.com/api/v1/randompoems")
    @State private var offline = false
    var body: some View {
       //var onlinePoems = Poem()
        
        NavigationView{
      
        List {
           
            ForEach(0..<onlinePoems.count) { index in
                NavigationLink(
                    destination: PoemView(language: onlinePoems[index].language, author: onlinePoems[index].author, title: onlinePoems[index].title, inputText: onlinePoems[index].text, complete: false),
                    label: {
                    VStack{
                        Text(onlinePoems[index].title)
                        Text(onlinePoems[index].author)
                    }
                        
                    })
                
            }
           
            .onDelete(perform: deleteItems)
            
        }
        .listStyle(SidebarListStyle())
            PoemView(language: "", author: "", title: "", inputText: "", complete: false)
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
        
        .onAppear(perform: {
           
            onlinePoems = WebPoemsHelper().getPoemsFromJson(site: "https://www.poemist.com/api/v1/randompoems")
            onlinePoems += WebPoemsHelper().getPoemsFromJson(site: "https://github.com/TemaSysoev/Poems2/blob/main/Shared/data.json")
            
        })
        .toolbar {
            #if os(iOS)
            EditButton()
            #endif

            Button(action: addItem) {
                Label("Add Item", systemImage: "plus")
            }
            if offline{
                Text("Offline")
            }
            Button(action: {
                let urlString = "https://www.poemist.com/api/v1/randompoems"

                    if let url = URL(string: urlString) {
                        if let data = try? Data(contentsOf: url) {
                            
                            onlinePoems = WebPoemsHelper().parse(json: data)
                            offline = false
                        }else{
                            offline = true
                            print("data error")
                        }
                    }else{
                        offline = true
                        print("url error")
                    }
                }, label: {
                    
                Text("Update")
            })
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Poem(context: viewContext)
            newItem.title = "No title"
            newItem.text = ""
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { poems[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ListOfPoems().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
