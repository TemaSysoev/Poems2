//
//  ContentView.swift
//  Shared
//
//  Created by Tema Sysoev on 04.06.2021.
//

import SwiftUI
import CoreData

struct WebPoem: Identifiable, Encodable{
    var id: String
    
    let author: String
    let title: String
    let text: String
    let language: String
    
    let source: String
    
}
enum LoadingStats{
    case loading
    case loaded
    case error
}
let defaults = UserDefaults.standard
func loadBookmarked() -> [String]{
    if defaults.object(forKey: "booked") != nil {
        return defaults.object(forKey: "booked")! as! [String]
    }else{
        return [""]
    }
    
}
func saveBookmarked(s: [String]){
    defaults.set(s, forKey: "booked")
}
struct PoemsListView: View {
    let source: String
    
    @State private var onlinePoems = [WebPoem]()
    
    @State private var bookmarkedPoems = [WebPoem]()
    @State private var state = LoadingStats.loading
    @State private var searchText = ""
    var searchResults: [WebPoem] {
        if searchText.isEmpty {
            return onlinePoems
        } else {
            if source == "online"{
                
                return onlinePoems
            } else {
                return onlinePoems.filter {($0.author.lowercased().contains(searchText.lowercased()) || $0.title.lowercased().contains(searchText.lowercased()) || $0.text.lowercased().contains(searchText.lowercased()))
                }
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
                .searchable(text: $searchText){
                    Text("Пушкин А.С.").searchCompletion("Пушкин А.С.")
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
                                    .foregroundStyle(Color.secondary)
                                
                                
                            }
                            
                        })
                        
                        
                        
                    }
                    
                    
                    
                }
                
                
                .searchable(text: $searchText){
                    Text("Пушкин А.С.").searchCompletion("Пушкин А.С.")
                }
                .onSubmit(of: .search) {
                    searchOnlinePoems(search: searchText)
                }
                .refreshable {
                    getPoems()
                    
                }
                
            case .error:
                
                VStack{
                    Image(systemName: "ladybug.fill")
                        .imageScale(.large)
                        .symbolRenderingMode(.multicolor)
                    Text("Something went wrong")
                        .foregroundColor(.secondary)
                }
                .searchable(text: $searchText){
                    Text("Пушкин А.С.").searchCompletion("Пушкин А.С.")
                }
                
                
            }
            
            
            
        }
        .task {
            switch source{
            case "local":
                getPoems()
            case "online":
                getOnlinePoems()
            default:
                getPoems()
                
            }
            
            
        }
#if os(iOS)
        .navigationBarTitle(source == "online" ? "Online":"My library", displayMode: .automatic)
#endif
#if os(macOS)
        .navigationTitle(source == "online" ? "Online":"My library")
#endif
        
        .toolbar {
            
            
        }
        
    }
    
    func getPoems(){
        //state = LoadingStats.loading
        
        let bookmarked = loadBookmarked()
        
        async{
            for index in 0..<bookmarked.count{
                do {
                    state = LoadingStats.loading
                    
                    var loadedPoems = [WebPoem]()
                    print(bookmarked[index])
                    let url = URL(string: "https://poetrydb.org/title/\(bookmarked[index])")
                    let (data, _) = try await URLSession.shared.data(from: url!)
                    
                    
                    let poems = try JSONDecoder().decode([PoetryDB].self, from: data)
                    
                    guard poems.count > 0 else {
                        throw gettingPoemsError.emptyPoemsList
                    }
                    
                    
                    var text = ""
                    for line in poems[index].lines{
                        text += line + "\n"
                    }
                    
                    let poem = WebPoem(id: poems[0].title, author: poems[0].author, title: poems[0].title, text: text, language: "English", source: "poerty")
                    
                    loadedPoems.append(poem)
                    
                    
                    
                    onlinePoems += loadedPoems
                    
                    
                    state = LoadingStats.loaded
                    
                } catch {
                    print("error Local")
                    state = LoadingStats.error
                }
            }
        }
        
    }
    func getOnlinePoems(){
        
        async{
            
            do {
                state = LoadingStats.loading
                
                var loadedPoems = [WebPoem]()
                let url = URL(string: "https://poetrydb.org/random/30")
                let (data, _) = try await URLSession.shared.data(from: url!)
                
                
                let poems = try JSONDecoder().decode([PoetryDB].self, from: data)
                
                guard poems.count > 0 else {
                    throw gettingPoemsError.emptyPoemsList
                }
                
                for index in 0..<poems.count{
                    var text = ""
                    for line in poems[index].lines{
                        text += line + "\n"
                    }
                    
                    let poem = WebPoem(id: poems[index].title, author: poems[index].author, title: poems[index].title, text: text, language: "English", source: "poerty")
                    
                    loadedPoems.append(poem)
                    
                    
                }
                onlinePoems += loadedPoems
                
                
                state = LoadingStats.loaded
                
            } catch {
                print("error")
                state = LoadingStats.error
            }
        }
    }
    
    func searchOnlinePoems(search: String){
        onlinePoems = [WebPoem]()
        async{
            state = LoadingStats.error
            do {
                state = LoadingStats.loading
                
                var loadedPoems = [WebPoem]()
                let url = URL(string: "https://poetrydb.org/author/\(search)")
                let (data, _) = try await URLSession.shared.data(from: url!)
                
                
                let poems = try JSONDecoder().decode([PoetryDB].self, from: data)
                
                guard poems.count > 0 else {
                    throw gettingPoemsError.emptyPoemsList
                }
                
                for index in 0..<poems.count{
                    var text = ""
                    for line in poems[index].lines{
                        text += line + "\n"
                    }
                    
                    let poem = WebPoem(id: poems[index].title, author: poems[index].author, title: poems[index].title, text: text, language: "English", source: "poerty")
                    
                    loadedPoems.append(poem)
                    
                    
                }
                onlinePoems += loadedPoems
                
                
                state = LoadingStats.loaded
                
            } catch {
                print("author error")
                
            }
            do {
                state = LoadingStats.loading
                
                var loadedPoems = [WebPoem]()
                let url = URL(string: "https://poetrydb.org/title/\(search)")
                let (data, _) = try await URLSession.shared.data(from: url!)
                
                
                let poems = try JSONDecoder().decode([PoetryDB].self, from: data)
                
                guard poems.count > 0 else {
                    throw gettingPoemsError.emptyPoemsList
                }
                
                for index in 0..<poems.count{
                    var text = ""
                    for line in poems[index].lines{
                        text += line + "\n"
                    }
                    
                    let poem = WebPoem(id: poems[index].title, author: poems[index].author, title: poems[index].title, text: text, language: "English", source: "poerty")
                    
                    loadedPoems.append(poem)
                    
                    
                }
                onlinePoems += loadedPoems
                
                
                state = LoadingStats.loaded
                
            } catch {
                print("title error")
                
            }
            do {
                state = LoadingStats.loading
                
                var loadedPoems = [WebPoem]()
                let url = URL(string: "https://poetrydb.org/lines/\(search)")
                let (data, _) = try await URLSession.shared.data(from: url!)
                
                
                let poems = try JSONDecoder().decode([PoetryDB].self, from: data)
                
                guard poems.count > 0 else {
                    throw gettingPoemsError.emptyPoemsList
                }
                
                for index in 0..<poems.count{
                    var text = ""
                    for line in poems[index].lines{
                        text += line + "\n"
                    }
                    
                    let poem = WebPoem(id: poems[index].title, author: poems[index].author, title: poems[index].title, text: text, language: "English", source: "poerty")
                    
                    loadedPoems.append(poem)
                    
                    
                }
                onlinePoems += loadedPoems
                
                
                state = LoadingStats.loaded
                
            } catch {
                print("lines error")
                
            }
        }
    }
    func readLocalFile(forName name: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name,
                                                 ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                print(bundlePath)
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
    }
     */
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
