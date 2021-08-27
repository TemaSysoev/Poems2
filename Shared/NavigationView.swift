//
//  NavigationView.swift
//  Poems2
//
//  Created by Tema Sysoev on 08.06.2021.
//

import SwiftUI

struct ColumnsView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var searchText = ""
    
    @State public var onlinePoems = [WebPoem]()
    @State public var bookmarkedPoems = [WebPoem]()
    
    @State private var state = LoadingStats.loading
    private let view = ["Discover", "Bookmarks"]
    @State private var currentView = "Discover"
    @State private var showingMenu = false
    @State private var mainColor = Colors().pattern1Color
    
    @AppStorage("fontSize") private var fontSize = 18
    @AppStorage("fontName") private var fontName = "System"
    @AppStorage("linesOnPage") private var linesOnPage = 3
    @AppStorage("backgroundImageName") private var backgroundImageName = "pattern1"
    @State var categories = ["Bookmarks", "Random"]
    
    var fonts = ["System", "Helvetica Neue", "Athelas", "Charter", "Georgia", "Iowan", "Palatino", "New York", "Seravek", "Times New Roman"]
    var fontSizes = [12, 18, 24]
    var backgroundImages = ["pattern1", "pattern2", "pattern3", "pattern4", "pattern5"]
    
    
    var searchResults: [WebPoem] {
        if searchText.isEmpty {
            return onlinePoems
        } else {
            
            return onlinePoems.filter {($0.author.lowercased().contains(searchText.lowercased()) || $0.title.lowercased().contains(searchText.lowercased()) || $0.text.lowercased().contains(searchText.lowercased()))
                
            }
        }
    }
    var body: some View {
        NavigationView {
            
            VStack {

                List{
                    VStack(alignment: .center){
                        Picker(selection: $currentView, label: Text("")) {
                            ForEach(view, id: \.self) {
                                Text($0)
                            }
                            
                        }
                        .pickerStyle(.segmented)
                        if searchText != ""{
                            Button(role: .destructive, action:{
                                searchText = ""
                                searchOnlinePoems(search: searchText)
                            }, label:{
                                Text("Clear search")
                            })
                            
                        }
                    }
                    switch currentView{
                        
                    case "Discover":
                        if searchText == ""{
                            Section(header: Text("Featured")){
                                Button(action: {
                                    searchText = "Shakespeare"
                                    searchOnlinePoems(search: searchText)
                                }, label:{
                                    
                                    Label("William Shakespeare", systemImage: "person.crop.circle")
                                    
                                    
                                })
                                    .buttonStyle(.borderless)
                                Button(action: {
                                    searchText = "Dickinson"
                                    searchOnlinePoems(search: searchText)
                                }, label:{
                                    
                                    Label("Emily Dickinson", systemImage: "person.crop.circle")
                                    
                                    
                                })
                                    .buttonStyle(.borderless)
                            }
                        }
                        Section(header: Text("Discover")){
                            ForEach(searchResults) { poem in
                                NavigationLink(destination:
                                                PoemView(language: poem.language, author: poem.author, title: poem.text, inputText: poem.text, complete: false, fontSize: fontSize, fontName: fontName, linesOnPage: linesOnPage, backgroundImageName: backgroundImageName)
                                               #if os(iOS)
                                                .navigationBarTitle(Text("\(poem.title)"))
                                                .navigationBarTitleDisplayMode(.inline)
                                               #else
                                                .navigationTitle("\(poem.title)")
                                                .navigationSubtitle("\(poem.author)")
                                               #endif
                                                .toolbar{
                                    ToolbarItem(){
                                        Button(action:{
                                            saveBookmarked(poem.text)
                                            getBookmarkedPoems()
                                            print(loadBookmarked())
                                        }, label:{
                                            Label("Bookmark", systemImage: "bookmark")
                                            
                                        })
                                    }
                                    ToolbarItem(placement: .primaryAction){
                                        
                                        Button(action:{
                                            showingMenu = true
                                        }, label: {
                                            Image(systemName:"eyeglasses")
                                            
                                            
                                        })
                                        
                                            .popover(isPresented: $showingMenu) {
                                                VStack{
                                                    Text("Reading")
                                                        .bold()
                                                    
                                                    HStack{
#if os(iOS)
                                                        Text("Font:")
                                                        
                                                        
                                                        Spacer()
#endif
                                                        
                                                        Picker(selection: $fontName, label: Text("Typeface")) {
                                                            ForEach(fonts, id: \.self) {
                                                                Text($0)
                                                                    .font($0 == "System" ? .system(size: 14, design: .serif):.custom($0, size: 14))
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                        
                                                        .pickerStyle(.menu)
                                                        
                                                        Divider()
                                                        Picker(selection: $fontSize, label: Text("Size")) {
                                                            ForEach(fontSizes, id: \.self) { size in
                                                                Text("\(size)")
                                                                
                                                            }
                                                            
                                                            
                                                        }
                                                        .pickerStyle(.menu)
                                                        
                                                    }
                                                    .frame(height: 20)
                                                    
                                                    Divider()
                                                    Text("Background")
                                                        .bold()
                                                    ScrollView(.vertical){
                                                        VStack(){
                                                            ForEach(backgroundImages, id: \.self) { name in
                                                                Button(action:{backgroundImageName = name
                                                                    mainColor = Color("\(name)Color")
                                                                }, label:{HStack{
                                                                    Image("\(name)")
                                                                        .resizable()
                                                                        .aspectRatio(contentMode: .fill)
                                                                        .frame(height: 90, alignment: .center)
                                                                        .cornerRadius(5.0)
                                                                    
                                                                    
                                                                }})
                                                                    .buttonStyle(.borderless)
                                                                    .contrast(colorScheme == .dark ? -1.0 : 1.0)
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                    
                                                }.padding()
                                                    .frame(minWidth: 300)
                                            }
                                    }
                                }
                                               
                                               , label: {
                                    
                                    
                                    VStack(alignment: .leading){
                                        
                                        Text(poem.title)
                                            .bold()
                                            .multilineTextAlignment(.leading)
                                        
                                        Text(poem.author)
                                            .font(.footnote)
                                            .multilineTextAlignment(.leading)
                                        
                                        
                                    }
                                    
                                    
                                    
                                    
                                })
                                    .task{
                                        if poem == searchResults.last{
                                            getOnlinePoems()
                                        }
                                    }
                                
                                
                            }
                        }
                    case "Bookmarks":
                        Section(header: Text("Bookmarks")){
                            
                            ForEach(bookmarkedPoems) { poem in
                                
                                NavigationLink(destination: PoemView(language: poem.language, author: poem.author, title: poem.text, inputText: poem.text, complete: false, fontSize: fontSize, fontName: fontName, linesOnPage: linesOnPage, backgroundImageName: backgroundImageName)
                                               #if os(iOS)
                                                .navigationBarTitleDisplayMode(.large)
                                               #endif
                                                .toolbar{
                                    ToolbarItem(){
                                        Button(action:{
                                            for index in 0..<bookmarkedPoems.count{
                                                if poem.title == bookmarkedPoems[index].title{
                                                    bookmarkedPoems.remove(at: index)
                                                    break
                                                }
                                            }
                                            defaults.set(bookmarkedPoems, forKey: "booked")
                                            
                                        }, label:{
                                            Label("Bookmark", systemImage: "bookmark.slash")
                                            
                                        })
                                    }
                                    ToolbarItem(placement: .primaryAction){
                                        
                                        Button(action:{
                                            showingMenu = true
                                        }, label: {
                                            Image(systemName:"eyeglasses")
                                            
                                            
                                        })
                                        
                                            .popover(isPresented: $showingMenu) {
                                                VStack{
                                                    Text("Reading")
                                                        .bold()
                                                    
                                                    HStack{
#if os(iOS)
                                                        Text("Font:")
                                                        
                                                        
                                                        Spacer()
#endif
                                                        
                                                        Picker(selection: $fontName, label: Text("Typeface")) {
                                                            ForEach(fonts, id: \.self) {
                                                                Text($0)
                                                                    .font($0 == "System" ? .system(size: 14, design: .serif):.custom($0, size: 14))
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                        
                                                        .pickerStyle(.menu)
                                                        
                                                        Divider()
                                                        Picker(selection: $fontSize, label: Text("Size")) {
                                                            ForEach(fontSizes, id: \.self) { size in
                                                                Text("\(size)")
                                                                
                                                            }
                                                            
                                                            
                                                        }
                                                        .pickerStyle(.menu)
                                                        
                                                    }
                                                    .frame(height: 20)
                                                    
                                                    Divider()
                                                    Text("Background")
                                                        .bold()
                                                    ScrollView(.vertical){
                                                        VStack(){
                                                            ForEach(backgroundImages, id: \.self) { name in
                                                                Button(action:{backgroundImageName = name
                                                                    mainColor = Color("\(name)Color")
                                                                }, label:{HStack{
                                                                    Image("\(name)")
                                                                        .resizable()
                                                                        .aspectRatio(contentMode: .fill)
                                                                        .frame(height: 90, alignment: .center)
                                                                        .cornerRadius(5.0)
                                                                    
                                                                    
                                                                }})
                                                                    .buttonStyle(.borderless)
                                                                    .contrast(colorScheme == .dark ? -1.0 : 1.0)
                                                                
                                                            }
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                    
                                                }.padding()
                                                    .frame(minWidth: 300)
                                            }
                                    }
                                }, label: {
                                    
                                    
                                    VStack(alignment: .leading){
                                        
                                        Text(poem.title)
                                            .bold()
                                            .multilineTextAlignment(.leading)
                                        //.foregroundColor(Color.primary)
                                        Text(poem.author)
                                            .font(.footnote)
                                            .multilineTextAlignment(.leading)
                                        //.foregroundStyle(Color.secondary)
                                        
                                    }
                                    
                                })
                                
                            }
                        }
                    default:
                        Text("Error")
                    }
                    
                    if state == .loading{
                        ForEach(0..<10){ _ in
                            VStack(alignment: .leading){
                                
                                Text("Loading title")
                                    .bold()
                                    .multilineTextAlignment(.leading)
                                //.foregroundColor(Color.primary)
                                Text("Loading author")
                                    .font(.footnote)
                                    .multilineTextAlignment(.leading)
                                //.foregroundStyle(Color.secondary)
                                
                            }
                            .animation(.spring(), value: 1)
                            .redacted(reason: .placeholder)
                        }
                        HStack{
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                    
                    if state == .error{
                        Image(systemName: "bolt.horizontal.circle")
                    }
                }
#if os(macOS)
.frame(minWidth: 200)
#endif
                
#if os(iOS)
                .navigationBarTitle(Text("Poems"))
#else
                .navigationTitle("Poems")
#endif
                .listStyle(.sidebar)
                
                // .listRowSeparator(.hidden)
                .searchable(text: $searchText){
                   
                }
                .onSubmit(of: .search) {
                    let searchTextForURL = searchText.replacingOccurrences(of: " ", with: "%20")
                    searchOnlinePoems(search: searchTextForURL)
                }
                
                if state == .notFound{
                    HStack{
                        Spacer()
                        
                        VStack{
                            Image(systemName: "text.badge.xmark")
                                .renderingMode(.original)
                                .imageScale(.large)
                                .padding()
                            Text("Such empty here")
                                .font(.footnote)
                            
                        }
                        Spacer()
                    }
                    
                }
                
                
                
                
                
            }
            
            
            .onChange(of: fontSize){value in
                switch fontSize{
                case 12: linesOnPage = 3
                case 18: linesOnPage = 2
                case 24: linesOnPage = 1
                default: linesOnPage = 2
                }
            }
            ZStack(alignment: .center){
                Image(backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.bottom)
                    .contrast(colorScheme == .dark ? -1.0 : 1.0)
                VStack{
                    
                    
                    
                    VStack{
                        
                        Text("""
                 When daisies pied and violets blue
                 And lady-smocks all silver-white
                 And cuckoo-buds of yellow hue
                 Do paint the meadows with delight
                 """)
                        
                            .multilineTextAlignment(.center)
                            .font(fontName == "System" ? .system(size: CGFloat(fontSize), design: .serif):.custom(fontName, size: CGFloat(fontSize)))
                        
                        
                            .padding()
                            .foregroundColor(Color.primary)
                        Text("""
                     The cuckoo then, on every tree,
                     Mocks married men; for thus sings he:
                                                                         “Cuckoo;
                     Cuckoo, cuckoo!” O, word of fear,
                     Unpleasing to a married ear!
                     """)
                            .multilineTextAlignment(.center)
                            .font(fontName == "System" ? .system(size: CGFloat(fontSize), design: .serif):.custom(fontName, size: CGFloat(fontSize)))
                        
                        
                            .padding()
                            .foregroundColor(Color.primary)
                        Text("""
                     When shepherds pipe on oaten straws,
                           And merry larks are ploughmen's clocks,
                     When turtles tread, and rooks, and daws,
                           And maidens bleach their summer smocks,
                     """)
                            .multilineTextAlignment(.center)
                            .font(fontName == "System" ? .system(size: CGFloat(fontSize), design: .serif):.custom(fontName, size: CGFloat(fontSize)))
                        
                        
                            .padding()
                            .foregroundColor(Color.primary)
                        
                    }
                    .redacted(reason: .placeholder)
                    .frame(minWidth: 300, idealWidth: 330, maxWidth: 400, minHeight: 500, idealHeight: 560, maxHeight: 560, alignment: .center)
                    .background(Color("BackgroundColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .padding()
                    .shadow(color: Color.black.opacity(0.2), radius: 3.0, x: 0, y: 2)
                    HStack{
#if os(iOS)
                        Button(action: {
                            
                            
                        }, label: {
                            Image(systemName: "mic.fill")
                            
                            
                        })
                            .padding()
                            .tint(Color.accentColor)
                        
                        
                        
                        
#endif
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "chevron.left")
                            
                        })
                            .buttonStyle(.borderless)
                            .disabled(true)
                            .padding(7)
                        Text("Page 1 of 3")
                        
                        Button(action: {
                            
                        }, label: {
                            Image(systemName: "chevron.right")
                            
                        })
                            .buttonStyle(.borderless)
                            .disabled(true)
                            .padding(7)
                    }
                    .redacted(reason: .placeholder)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding()
                    Spacer()
                }
                
                
            }
            
            
        }
        
        .accentColor(mainColor)
        .navigationViewStyle(.columns)
        .task{
            async{
                getOnlinePoems()
                getBookmarkedPoems()
            }
            state = .loaded
            
        }
        
    }
    func getOnlinePoems(){
        
        async{
            
            do {
                state = LoadingStats.loading
                
                
                let url = URL(string: "https://poetrydb.org/random/10")
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
                    
                    onlinePoems.append(poem)
                    
                    state = LoadingStats.loading
                }
                state = LoadingStats.loaded
                
                
            } catch {
                print("error")
                state = LoadingStats.error
            }
        }
        
    }
    
    func getBookmarkedPoems(){
        
        async{
            
            do {
                state = LoadingStats.loading
                bookmarkedPoems = [WebPoem]()
                var loadedPoems = [WebPoem]()
                var bookmarkedPoemsLines = loadBookmarked()
                
                for index in 0..<bookmarkedPoemsLines.count{
                    state = LoadingStats.loading
                    
                    let url = URL(string: "https://poetrydb.org/lines/\(bookmarkedPoemsLines[index])")
                    
                    let (data, _) = try await URLSession.shared.data(from: url!)
                    
                    let poems = try JSONDecoder().decode([PoetryDB].self, from: data)
                    
                    print(poems.count)
                    guard poems.count > 0 else {
                        throw gettingPoemsError.emptyPoemsList
                        
                    }
                    
                    for i in 0..<poems.count{
                        var text = ""
                        for line in poems[i].lines{
                            text += line + "\n"
                        }
                        
                        let poem = WebPoem(id: poems[i].title, author: poems[i].author, title: poems[i].title, text: text, language: "English", source: "poerty")
                        var firstLine = bookmarkedPoemsLines[index].replacingOccurrences(of: "%20", with: " ")
                        print(firstLine)
                        if poems[i].lines[0].contains(firstLine) || firstLine.contains(poems[i].lines[0]){
                            loadedPoems.append(poem)
                        }
                        state = LoadingStats.loading
                        
                    }
                    
                    bookmarkedPoems.append(loadedPoems[0])
                    
                    state = LoadingStats.loaded
                    loadedPoems = [WebPoem]()
                }
                
            } catch {
                print("error")
                state = LoadingStats.error
            }
        }
    }
    
    func searchOnlinePoems(search: String){
        if search != ""{
            onlinePoems = [WebPoem]()
            async{
                
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
                        state = LoadingStats.loading
                        
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
                
                if searchResults.isEmpty {
                    state = .notFound
                }else{
                    print(searchResults)
                }
            }
        }else{
            onlinePoems = [WebPoem]()
            getOnlinePoems()
            state = .loaded
        }
    }
    
}



struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ColumnsView()
    }
}
