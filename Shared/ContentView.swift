//
//  ContentView.swift
//  Shared
//
//  Created by Tema Sysoev on 04.06.2021.
//

import SwiftUI
import CoreData

struct WebPoem: Identifiable{
    var id: String
    
    let author: String
    let title: String
    let text: String
    let language: String
    
}
enum LoadingStats{
    case loading
    case loaded
    case error
}
struct PoemsListView: View {
    let source: String
    
    @State private var onlinePoems = [WebPoem]()
    @State private var state = LoadingStats.loading
    @State private var searchText = ""
    var searchResults: [WebPoem] {
            if searchText.isEmpty {
                return onlinePoems
            } else {
                return onlinePoems.filter { $0.author.lowercased().contains(searchText.lowercased()) || $0.title.lowercased().contains(searchText.lowercased()) || $0.text.lowercased().contains(searchText.lowercased())
                }
            }
        }
    var body: some View {
        ZStack{
        switch state {
        case .loading:
            VStack{
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            Text("Loading")
            }
            .task {
                getPoems()
            }
        case .loaded:
            List {
                
                ForEach(searchResults) { poem in
                    
                    NavigationLink(
                        destination: PoemView(language: poem.language, author: poem.author, title: poem.title, inputText: poem.text, complete: false)
                       
                        ,
                        label: {
                        VStack(alignment: .leading){
                            
                            Text(poem.title)
                                .bold()
                            Text(poem.author)
                                .font(.footnote)
                        }
                        
                    })
                
                
                    
                }
                
               // .onDelete(perform: deleteItems)
                
            }
            
            .searchable(text: $searchText){
                Text("Пушкин А.С.").searchCompletion("Пушкин А.С.")
            }
            .refreshable {
               getPoems()
            }
            
        case .error:
            Button(action: {
                getPoems()
            }, label: {
                Text("Retry")
            })
            
        }
            
        
        
        }
        
        
        .toolbar {
           
            /*
#if os(iOS)
            EditButton()
#endif
            
            Button(action: addItem) {
                Label("Add Item", systemImage: "plus")
            }
            if offline{
                Text("Offline")
            }*/
            
        }
        
    }
    
    func getPoems(){
        state = LoadingStats.loading
        switch source{
        case "Poemist":
            
            async{
         
                do {
                    for _ in 0..<2{
                    var loadedPoems = [WebPoem]()
                    let url = URL(string: "https://www.poemist.com/api/v1/randompoems")
                    let (data, _) = try await URLSession.shared.data(from: url!)
                 
                    
                    let poems = try JSONDecoder().decode([PoemistPoems].self, from: data)
                   
                    guard poems.count > 0 else {
                        throw gettingPoemsError.emptyPoemsList
                    }
                    for index in 0..<poems.count{
                        let poem = WebPoem(id: poems[index].title, author: poems[index].poet.name, title: poems[index].title, text: poems[index].content, language: "English")
                        
                        loadedPoems.append(poem)
                        
                        
                    }
                        onlinePoems += loadedPoems
                    }
                    
                    state = LoadingStats.loaded
                  
                } catch {
                    print("error")
                    state = LoadingStats.error
                }
            }
        case "Local":
            
            async{
         
                do {
                    var loadedPoems = [WebPoem]()
                  
                    
                    let data = readLocalFile(forName: "data")
                
                   
                    let poems = try JSONDecoder().decode([LocalPoems].self, from: data!)
                   
                    guard poems.count > 0 else {
                        print("decoding error")
                        throw gettingPoemsError.emptyPoemsList
                    }
                    for index in 0..<poems.count{
                        let poem = WebPoem(id: poems[index].title, author: poems[index].author, title: poems[index].title, text: poems[index].text, language: "Russian")
                        
                        loadedPoems.append(poem)
                        
                        
                    
                    }
                    onlinePoems += loadedPoems
                    state = LoadingStats.loaded
                  
                } catch {
                    print("error Local")
                    state = LoadingStats.error
                }
            }
        case "Poetry":
            async{
         
                do {
                    for _ in 0..<2{
                    var loadedPoems = [WebPoem]()
                    let url = URL(string: "https://www.stands4.com/services/v2/poetry.php?uid=1001&tokenid=tk324324&term=grass&format=json")
                    let (data, _) = try await URLSession.shared.data(from: url!)
                 
                    
                    let poems = try JSONDecoder().decode([PoetryPoems].self, from: data)
                   
                    guard poems.count > 0 else {
                        throw gettingPoemsError.emptyPoemsList
                    }
                    for index in 0..<poems.count{
                        let poem = WebPoem(id: poems[index].results.result.title, author: poems[index].results.result.poet, title: poems[index].results.result.title, text: poems[index].results.result.text, language: "English")
                        
                        loadedPoems.append(poem)
                        
                        
                    }
                        onlinePoems += loadedPoems
                    }
                    
                    state = LoadingStats.loaded
                  
                } catch {
                    print("error")
                    state = LoadingStats.error
                }
            }
        default:
            
            async{
         
                do {
                    var loadedPoems = [WebPoem]()
                  
                    
                    let data = readLocalFile(forName: "data")
                
                   
                    let poems = try JSONDecoder().decode([LocalPoems].self, from: data!)
                   
                    guard poems.count > 0 else {
                        print("decoding error")
                        throw gettingPoemsError.emptyPoemsList
                    }
                    for index in 0..<poems.count{
                        let poem = WebPoem(id: poems[index].title, author: poems[index].author, title: poems[index].title, text: poems[index].text, language: "Russian")
                        
                        loadedPoems.append(poem)
                        
                        
                    
                    }
                    onlinePoems = loadedPoems
                    state = LoadingStats.loaded
                  
                } catch {
                    print("error Local")
                    state = LoadingStats.error
                }
            }
        }
    }
    func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
                let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    /*
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
    }*/
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        PoemsListView(source: "Local").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
