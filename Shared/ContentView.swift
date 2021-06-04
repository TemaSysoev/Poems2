//
//  ContentView.swift
//  Shared
//
//  Created by Tema Sysoev on 04.06.2021.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Poem.title, ascending: true)],
        animation: .default)
    private var poems: FetchedResults<Poem>
   
    var body: some View {
        var onlinePoems = Poem()
        List {
            
            ForEach(poems) { poem in
                Text(poem.title ?? "No title")
            }
           
            .onDelete(perform: deleteItems)
            
        }
        .onAppear(perform: {
            WebPoemsHelper().getJsonFile(link: "https://github.com/TemaSysoev/Poems2/blob/main/Shared/data.json"){ (result) in
                switch result {
                case .success(let data):
                    onlinePoems = WebPoemsHelper().parseJsonFile(data: data)
                    print(onlinePoems.title)
                case .failure(let error):
                    print(error)
                }
            }
        })
        .toolbar {
            #if os(iOS)
            EditButton()
            #endif

            Button(action: addItem) {
                Label("Add Item", systemImage: "plus")
            }
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
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
