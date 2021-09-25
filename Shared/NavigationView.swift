//
//  NavigationView.swift
//  Poems2
//
//  Created by Tema Sysoev on 08.06.2021.
//

import SwiftUI

struct ColumnsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var store: Store = Store()
    @State private var searchText = ""
    
    @State public var onlinePoems = [WebPoem]()
    @State public var bookmarkedPoems = [WebPoem]()
    
    @State private var state = LoadingStats.loading
   
    @State private var showingMenu = false
    @State private var showingLearnView = false
   
    @State private var mainColor = Colors().pattern1Color
    
    @AppStorage("fontSize") private var fontSize = 18
    @AppStorage("fontName") private var fontName = "System"
    @AppStorage("linesOnPage") private var linesOnPage = 3
    @AppStorage("userAccentColor") private var userAccentColor = "pattern5Color"
    @AppStorage("JSONLibrary") private var JSONLibrary = """

"""
    @AppStorage("subscribed") private var subscribed = false
  
    var fonts = ["System", "Helvetica Neue", "Athelas", "Charter", "Georgia", "Iowan", "Palatino", "New York", "Seravek", "Times New Roman"]
    var fontSizes = [12, 18, 24]
    var colors = ["pattern1Color", "pattern2Color", "pattern3Color", "pattern4Color", "pattern5Color", "pattern6Color"]
   
  
    
    @State private var showingAddNewPoemView = false
    @State private var showingSubscribeView = false
    @State private var newTitle = ""
    @State private var newAuthor = ""
    @State private var newText = """
"""
    
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
                    if searchText != ""{
                        Button(role: .destructive, action:{
                            searchText = ""
                            searchOnlinePoems(search: searchText)
                        }, label:{
                            Text("Clear search")
                        })
                        
                    }
                    
                    Section(header: Text("My library")){
                        if !subscribed {
                            Button(action:{
                                showingSubscribeView = true
                            }, label:{
                                Text("Create my library")
                            })
                                .sheet(isPresented: $showingSubscribeView){
                                    SubscribeView(userAccentColor: userAccentColor)
                                }
                        } else {
                        ForEach(bookmarkedPoems) { poem in
                            
                            NavigationLink(destination: PoemView(language: poem.language, author: poem.author, title: poem.title, inputText: poem.text, complete: false, fontSize: fontSize, fontName: fontName, linesOnPage: linesOnPage, customAccentColor: userAccentColor)
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
                                        if bookmarkedPoems.contains(poem){
                                        for index in 0..<bookmarkedPoems.count{
                                            if poem.title == bookmarkedPoems[index].title{
                                                bookmarkedPoems.remove(at: index)
                                                break
                                            }
                                        }
                                        
                                        
                                        do {
                                            let jsonData = try JSONEncoder().encode(bookmarkedPoems)
                                            let jsonString = String(data: jsonData, encoding: .utf8)!
                                            
                                            
                                            
                                            JSONLibrary = jsonString
                                        } catch {
                                            print(error)
                                            
                                        }
                                        }else {
                                            bookmarkedPoems.append(poem)
                                            
                                            do {
                                                let jsonData = try JSONEncoder().encode(bookmarkedPoems)
                                                let jsonString = String(data: jsonData, encoding: .utf8)!
                                                
                                                
                                                
                                                JSONLibrary = jsonString
                                            } catch {
                                                print(error)
                                                
                                            }
                                        }
                                        
                                    }, label:{
                                        if bookmarkedPoems.contains(poem){
                                        Label("Bookmark", systemImage: "bookmark.slash")
                                        }else{
                                            Label("Bookmark", systemImage: "bookmark")
                                        }
                                        
                                    })
                                }
                                
                                
                                ToolbarItem(placement: .primaryAction){
                                    
                                    Button(action:{
                                        if subscribed {
                                            showingMenu = true
                                            
                                        }else{
                                            showingSubscribeView = true
                                        }
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
                                                Text("Controls color")
                                                    .bold()
                                                ScrollView(.horizontal){
                                                    HStack(){
                                                        ForEach(colors, id: \.self) { name in
                                                            Button(action:{userAccentColor = name
                                                                mainColor = Color("\(name)")
                                                            }, label:{HStack{
                                                                Circle()
                                                                    .frame(width: 50, height: 50)
                                                                    .foregroundColor(Color("\(name)"))
                                                                
                                                            }})
                                                                .buttonStyle(.borderless)
                                                            
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                Spacer()
                                                
                                                
                                            }.padding()
                                                .frame(minWidth: 300)
                                                .background(.thinMaterial)
                                        }
                                }
                            }, label: {
                                HStack{
                                    VStack{
                                        Text(poem.text.prefix(60))
                                            .font(fontName == "System" ? .system(size: 5.0, design: .serif):.custom(fontName, size: 5.0))
                                            .foregroundColor(Color.primary)
                                            .multilineTextAlignment(.leading)
                                            .padding(.all, 5)
                                            .mask(
                                                LinearGradient(gradient: Gradient(colors: [Color("BackgroundColor").opacity(1.0), Color("BackgroundColor").opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                                            )
                                    }
                                    .frame(width: 40, height: 53, alignment: .center)
                                    .background(Color("BackgroundColor"))
                                    
                                    .cornerRadius(3.0)
                                    .shadow(color: Color.black.opacity(0.2), radius: 1.0, x: 0, y: 0.5)
                                    
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
                                }
                                
                            })
                            
                            
                        }
                        Button(action: {
                            if subscribed {
                            showingAddNewPoemView = true
                            }else{
                                showingSubscribeView = true
                            }
                        }, label:{
                            HStack{
                                VStack{
                                    Image(systemName: "plus")
                                        .foregroundColor(Color(userAccentColor))
                                }
                                .frame(width: 40, height: 53, alignment: .center)
                                .background(Color("BackgroundColor"))
                                
                                .cornerRadius(3.0)
                                .shadow(color: Color.black.opacity(0.2), radius: 1.0, x: 0, y: 0.5)
                                VStack(alignment: .leading){
                                    
                                    Text("Add new")
                                        .bold()
                                        .foregroundColor(Color(userAccentColor))
                                        .multilineTextAlignment(.leading)
                                    
                                    
                                }
                            }
                        }).sheet(isPresented: $showingAddNewPoemView) {
                            VStack{
                                HStack{
                                    Button(role: .cancel, action: {
                                        newTitle = ""
                                        newAuthor = ""
                                        newText = """
                            """
                                        showingAddNewPoemView = false
                                    }, label: {
                                        Text("Cancel")
                                    })
                                        .tint(Color.secondary)
                                        .buttonStyle(.bordered)
                                    Spacer()
                                    Button(action: {
                                        bookmarkedPoems.append(WebPoem(id: newTitle, author: newAuthor, title: newTitle, text: newText, language: "Eng", source: "Custom"))
                                        
                                        do {
                                            let jsonData = try JSONEncoder().encode(bookmarkedPoems)
                                            let jsonString = String(data: jsonData, encoding: .utf8)!
                                            
                                            
                                            
                                            JSONLibrary = jsonString
                                        } catch {
                                            print(error)
                                            
                                        }
                                        showingAddNewPoemView = false
                                    }, label: {
                                        Text("Done")
                                    })
                                        .buttonStyle(.bordered)
                                        .tint(Color(userAccentColor))
                                
                                }
                                .padding()
                                TextField("Title", text: $newTitle)
                                    .textFieldStyle(.plain)
                                    .font(fontName == "System" ? .system(size: 40, design: .serif):.custom(fontName, size: 40))
                                   
                                    .foregroundColor(Color.primary)
                                    .padding([.horizontal, .top])
                                TextField("Author", text: $newAuthor)
                                    .textFieldStyle(.plain)
                                    .font(fontName == "System" ? .system(size: 16, design: .serif):.custom(fontName, size: 16))
                                    .padding(.horizontal)
                                    .foregroundColor(Color.secondary)
                                Text("Enter text:")
                                    .font(.footnote)
                                    .foregroundColor(Color.secondary)
                                    .padding(.top)
                                TextEditor(text: $newText)
                                    .font(fontName == "System" ? .system(size: 14, design: .serif):.custom(fontName, size: 14))
                                    .foregroundColor(Color.primary)
                                    .background(Color.secondary)
                                    .padding(.horizontal)
                                Button(role: .destructive ,action: {
                                    newTitle = ""
                                    newAuthor = ""
                                    newText = """
                        """
                                }, label: {
                                    Text("Clean")
                                })
                                    .buttonStyle(.borderless)
                                    .padding(.bottom, 5)
                                    
                            }
                           
                        }
                    }
                    }
                    .task{
                        getBookmarkedPoems()
                    }
                    Section(header: Text("Discover")){
                        
                        ForEach(searchResults) { poem in
                            NavigationLink(destination:
                                            PoemView(language: poem.language, author: poem.author, title: poem.text, inputText: poem.text, complete: false, fontSize: fontSize, fontName: fontName, linesOnPage: linesOnPage, customAccentColor: userAccentColor)
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
                                    
                                        if !subscribed {
                                            showingSubscribeView = true
                                        }
                                        if bookmarkedPoems.contains(poem){
                                            for index in 0..<bookmarkedPoems.count{
                                                if poem.title == bookmarkedPoems[index].title{
                                                    bookmarkedPoems.remove(at: index)
                                                    break
                                                }
                                            }
                                            
                                            
                                            do {
                                                let jsonData = try JSONEncoder().encode(bookmarkedPoems)
                                                let jsonString = String(data: jsonData, encoding: .utf8)!
                                                
                                                
                                                
                                                JSONLibrary = jsonString
                                            } catch {
                                                print(error)
                                                
                                            }
                                        }else{
                                        bookmarkedPoems.append(poem)
                                        
                                        do {
                                            let jsonData = try JSONEncoder().encode(bookmarkedPoems)
                                            let jsonString = String(data: jsonData, encoding: .utf8)!
                                            
                                            
                                            
                                            JSONLibrary = jsonString
                                        } catch {
                                            print(error)
                                            
                                        }
                                        }
                                        
                                    }, label:{
                                        if bookmarkedPoems.contains(poem){
                                        Label("Bookmark", systemImage: "bookmark.slash")
                                        }else{
                                            Label("Bookmark", systemImage: "bookmark")
                                        }
                                    })
                                }
#if os(macOS)
                                
                                ToolbarItem(){
                                    Button(action:{
                                        if subscribed{
                                        showingLearnView = true
                                        }else{
                                            showingSubscribeView = true
                                        }
                                    }, label:{
                                        Label("Learn", systemImage: "brain.head.profile")
                                        
                                    })
                                        .popover(isPresented: $showingLearnView) {
                                            LearnView(language: poem.language, author: poem.author, title: poem.title, inputText: poem.text, fontName: fontName)
                                        }
                                }
                                
#endif
                                ToolbarItem(placement: .primaryAction){
                                    
                                    Button(action:{
                                        if subscribed {
                                        showingMenu = true
                                        }else{
                                            showingSubscribeView = true
                                        }
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
                                                Text("Controls color")
                                                    .bold()
                                                ScrollView(.horizontal){
                                                    HStack(){
                                                        ForEach(colors, id: \.self) { name in
                                                            Button(action:{
                                                                userAccentColor = name
                                                                mainColor = Color("\(name)")
                                                            }, label:{HStack{
                                                                Circle()
                                                                    .frame(width: 50, height: 50)
                                                                    .foregroundColor(Color("\(name)"))
                                                                
                                                            }})
                                                                .buttonStyle(.borderless)
                                                            
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                }
                                                
                                                Spacer()
                                                if showingSubscribeView{
                                                    SubscribeView(userAccentColor: userAccentColor)
                                                }
                                                Button(action:{
                                                   
                                                   
                                                    showingSubscribeView.toggle()
                                                    
                                                }, label: {
                                                    Text("Manage your account")
                                                        .font(.footnote)
                                                        .foregroundColor(Color.secondary)
                                                    
                                                })
                                                
                                            }
                                            .padding()
                                                .frame(minWidth: 300)
                                                .background(.thinMaterial)
                                                .animation(.spring(), value: showingSubscribeView)
                                        }
                                }
                                
                            }
                                           
                                           , label: {
                                HStack{
                                    
                                    VStack{
                                        Text(poem.text.prefix(60))
                                            .font(fontName == "System" ? .system(size: 5.0, design: .serif):.custom(fontName, size: 5.0))
                                            .foregroundColor(Color.primary)
                                            .multilineTextAlignment(.leading)
                                            .padding(.all, 5)
                                            .mask(
                                                LinearGradient(gradient: Gradient(colors: [Color("BackgroundColor").opacity(1.0), Color("BackgroundColor").opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                                            )
                                    }
                                    .frame(width: 40, height: 53, alignment: .center)
                                    .background(Color("BackgroundColor"))
                                    
                                    .cornerRadius(3.0)
                                    .shadow(color: Color.black.opacity(0.2), radius: 1.0, x: 0, y: 0.5)
                                    
                                    
                                    
                                    VStack(alignment: .leading){
                                        
                                        Text(poem.title)
                                            .bold()
                                            .multilineTextAlignment(.leading)
                                        
                                        Text(poem.author)
                                            .font(.footnote)
                                            .multilineTextAlignment(.leading)
                                        
                                        
                                    }
                                    
                                }
                                
                                
                            })
                                .task{
                                    if poem == searchResults.last{
                                        getOnlinePoems()
                                    }
                                }
                            
                            
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
                .searchable(text: $searchText){
                    Text("William Shakespeare").searchCompletion("William Shakespeare")
                    Text("Emily Dickinson").searchCompletion("Emily Dickinson")
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
                
                VStack{
                    Spacer()
                    
                    
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
            
            
        } .environmentObject(store)
        
        .accentColor(Color(userAccentColor))
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
                print(error)
                state = LoadingStats.error
            }
        }
        
    }
    
    func getBookmarkedPoems(){
        
        async{
            
            do {
                state = LoadingStats.loading
                bookmarkedPoems = [WebPoem]()
                   
                    let jsonData = try JSONLibrary.data(using: .utf8)
                    
                    let poems = try JSONDecoder().decode([WebPoem].self, from: jsonData!)
                    bookmarkedPoems = poems
                 
                
            } catch {
                print(error)
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
