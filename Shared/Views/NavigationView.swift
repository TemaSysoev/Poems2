//
//  NavigationView.swift
//  Poems2
//
//  Created by Tema Sysoev on 08.06.2021.
//

import SwiftUI
import CryptoKit
struct ColumnsView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject var store: Store = Store()
    
    @State private var searchText = ""
    @State private var searchSuggestion = Suggestion()
    @SceneStorage("suggestionStyleDEV") private var suggestionStyleDEV = 2
    @State public var onlinePoems = [WebPoem]()
    @State public var bookmarkedPoems = [WebPoem]()
    
    @State private var state = LoadingStats.loading
    
    @State private var showingMenu = false
    @State private var showingLearnView = false
    
    @State private var mainColor = Color("pattern1Color")
    
    @AppStorage("fontSize") private var fontSize = 18
    @AppStorage("fontName") private var fontName = "System"
    @AppStorage("linesOnPage") private var linesOnPage = 3
    @AppStorage("userAccentColor") private var userAccentColor = "pattern6Color"
    @AppStorage("JSONLibrary") private var JSONLibrary = """

"""
    @AppStorage("subscribed") private var subscribed = false
    @AppStorage("language") private var language = "English"
    var fonts = ["System", "Helvetica Neue", "Athelas", "Charter", "Georgia", "Iowan", "Palatino", "New York", "Seravek", "Times New Roman"]
    var fontSizes = [14, 15, 16, 17, 18, 19, 20, 21, 22]
    @State private var value = 0
    var colors = ["pattern1Color", "pattern2Color", "pattern3Color", "pattern4Color", "pattern5Color", "pattern6Color", "pattern7Color"]
    var columns: [GridItem] =
             Array(repeating: .init(.flexible(minimum: 100, maximum: 150)), count: 2)
    
    
    @State private var showingAddNewPoemView = false
    @State private var showingSettings = false
    @State private var showingSubscribeView = false
    @State private var newTitle = ""
    @State private var newAuthor = ""
    @State private var newText = """
"""
    
    var searchResults: [WebPoem] {
        
        return onlinePoems
        
    }
    var body: some View {
        NavigationView {
           
            VStack {
                
                List{
                    
                    Section(header: Text("Search suggestions")){
                      
                            Text("Authors")
                            .font(.body)
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack{
                            ForEach(searchSuggestion.authors, id: \.self){ author in
                                Button(action: {
                                    searchText = author
                                    searchOnlinePoems(search: searchText)
                                }, label:{
                                    Text(author)
                                })

                                    .buttonStyle(.bordered)
                              
                                    .tint(Color(userAccentColor))
                                  
                                
                            }
                            }
                           
                            }
                           
                            #if os(iOS)
                            .padding(.vertical, -20)
                            .listRowSeparator(.hidden)
                            #endif
                        
                        
                            Text("Poems about")
                                    .font(.body)
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack{
                            ForEach(searchSuggestion.keyWords, id: \.self){ word in
                                Button(action: {
                                    searchText = word
                                    searchOnlinePoems(search: searchText)
                                }, label:{
                                    Text(word)
                                })

                                    .buttonStyle(.bordered)
                              
                                    .tint(Color(userAccentColor))
                                  
                            }
                            }
                                
                            }
                           
                            #if os(iOS)
                            .padding(.vertical, -20)
                            .listRowSeparator(.hidden)
                            #endif
                        
                    }
                       
                    Section(header: Text("My library")){
                        if !subscribed {
                            Button(action:{
                                showingSubscribeView = true
                            }, label:{
                                Label("Unlock my shelf", systemImage: "books.vertical")
                            })
                                .buttonStyle(.borderless)
                                .sheet(isPresented: $showingSubscribeView){
                                    
                                    SubscribeView(userAccentColor: userAccentColor)
#if os(macOS)
                                    Button(action: {showingSubscribeView = false}, label:{Text("Close")})
                                        .padding(.bottom)
#endif
                                }
                        }
                        
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
                                        .keyboardShortcut("b", modifiers: .command)
                                }
                                
                                
                                
                                ToolbarItem(placement: .primaryAction){
                                    
                                    Button(action:{
                                        
                                        showingMenu = true
                                        
                                        
                                    }, label: {
                                        Image(systemName:"eyeglasses")
                                        
                                        
                                    })
                                        .keyboardShortcut("m", modifiers: .command)
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
                                                    Stepper(value: $fontSize,
                                                            in: 8...30,
                                                            step: 1) {
                                                        Text(LocalizedStringKey("\(fontSize)"))
                                                    }
                                                    
                                                    
                                                }
                                                .frame(height: 20)
#if os(iOS)
                                                Divider()
                                                Text("Controls color")
                                                    .bold()
                                                ScrollView(.vertical, showsIndicators: false){
                                                    VStack(){
                                                        ForEach(colors, id: \.self) { name in
                                                            Button(action:{userAccentColor = name
                                                                mainColor = Color("\(name)")
                                                            }, label:{
                                                                ZStack{
                                                                    HStack{
                                                                        Text("Spring When daises")
                                                                            .foregroundColor(Color.primary)
                                                                            .redacted(reason: .placeholder)
                                                                            .padding()
                                                                        Spacer()
                                                                        Image(systemName: "bookmark")
                                                                            .foregroundColor(Color(name))
                                                                            .padding(.vertical)
                                                                        Image(systemName: "eyeglasses")
                                                                            .foregroundColor(Color(name))
                                                                            .padding()
                                                                    }
                                                                }
                                                                
                                                                .background(Color(name).opacity(0.05))
                                                                
                                                                
                                                            })
                                                                .tint(Color.black)
                                                            
                                                                .cornerRadius(13.0)
                                                                .buttonStyle(.borderless)
                                                                .padding(5)
                                                            
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                }
                                                .disabled(!subscribed)
                                                Spacer()
#endif
                                                
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
                                        
#if os(iOS)
                                            .foregroundColor(Color.primary)
                                            .mask(
                                                LinearGradient(gradient: Gradient(colors: [Color("BackgroundColor").opacity(1.0), Color("BackgroundColor").opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                                            )
#else
                                            .foregroundColor(Color.gray)
#endif
                                            .multilineTextAlignment(.leading)
                                            .padding(.all, 5)
                                        
                                        
                                        
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
                                .disabled(!subscribed)
                            
                            
                            
                        }
                        Button(action: {
                            
                            showingAddNewPoemView = true
                            
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
                            
                        })
                            .buttonStyle(BorderlessButtonStyle())
                            .keyboardShortcut("n", modifiers: .command)
                            .sheet(isPresented: $showingAddNewPoemView) {
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
                                        
                                            .keyboardShortcut("s", modifiers: .command)
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
                                
#if os(macOS)
                                
                                .frame(minWidth: 400, minHeight: 500)
#endif
                                if !subscribed{
                                    SubscribeView(userAccentColor: userAccentColor)
                                }
                                
                            }
                        
                    }
                    .task{
                        
                        getBookmarkedPoems()
                    }
                    Section(header: Text("Discover")){
                        
                        ForEach(onlinePoems) { poem in
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
                                        .keyboardShortcut("b", modifiers: .command)
                                }
#if os(macOS)
                                
                                ToolbarItem(){
                                    Button(action:{
                                        
                                        showingLearnView = true
                                        
                                    }, label:{
                                        Label("Learn", systemImage: "brain.head.profile")
                                        
                                    })
                                        .popover(isPresented: $showingLearnView) {
                                            VStack{
                                                LearnView(language: poem.language, author: poem.author, title: poem.title, inputText: poem.text, fontName: fontName)
                                                    .disabled(!subscribed)
                                                if !subscribed{
                                                    SubscribeView(userAccentColor: userAccentColor)
                                                }
                                            }
                                        }
                                }
                                
#endif
                                ToolbarItem(placement: .primaryAction){
                                    
                                    Button(action:{
                                        
                                        showingMenu = true
                                        
                                    }, label: {
                                        Image(systemName:"eyeglasses")
                                        
                                        
                                    })
                                        .keyboardShortcut("r", modifiers: .command)
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
                                                    Stepper(value: $fontSize,
                                                            in: 8...30,
                                                            step: 1) {
                                                        Text("\(fontSize)")
                                                    }
                                                    
                                                    
                                                }
                                                .frame(height: 20)
                                                .disabled(!subscribed)
#if os(iOS)
                                                Divider()
                                                Text("Controls color")
                                                    .bold()
                                                ScrollView(.vertical, showsIndicators: false){
                                                    VStack(){
                                                        ForEach(colors, id: \.self) { name in
                                                            Button(action:{userAccentColor = name
                                                                mainColor = Color("\(name)")
                                                            }, label:{
                                                                ZStack{
                                                                    HStack{
                                                                        Text("Spring When daises")
                                                                            .foregroundColor(Color.primary)
                                                                            .redacted(reason: .placeholder)
                                                                            .padding()
                                                                        Spacer()
                                                                        Image(systemName: "bookmark")
                                                                            .foregroundColor(Color(name))
                                                                            .padding(.vertical)
                                                                        Image(systemName: "eyeglasses")
                                                                            .foregroundColor(Color(name))
                                                                            .padding()
                                                                    }
                                                                }
                                                                
                                                                .background(Color(name).opacity(0.05))
                                                                
                                                                
                                                            })
                                                                .tint(Color.black)
                                                                .cornerRadius(13.0)
                                                                .buttonStyle(.borderless)
                                                                .padding(5)
                                                                .disabled(!subscribed)
                                                            
                                                            
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                }
                                                
                                                Spacer()
#endif
                                                if !subscribed{
                                                    SubscribeView(userAccentColor: userAccentColor)
                                                }
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
                                        
#if os(iOS)
                                            .foregroundColor(Color.primary)
                                            .mask(
                                                LinearGradient(gradient: Gradient(colors: [Color("BackgroundColor").opacity(1.0), Color("BackgroundColor").opacity(0.0)]), startPoint: .top, endPoint: .bottom)
                                            )
#else
                                            .foregroundColor(Color.gray)
#endif
                                            .multilineTextAlignment(.leading)
                                            .padding(.all, 5)
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
                                        state = LoadingStats.loading
                                        getOnlinePoems()
                                        
                                    }
                                }
                            
                            
                        }
                        
                    }
                    if state == LoadingStats.loading || state == LoadingStats.searching{
                        HStack{
                            Spacer()
                            ProgressView()
                                .padding()
                            Spacer()
                        }
                    }
                    if state == .searching {
                        HStack{
                            ProgressView()
                                .padding()
                            Text("Searching...")
                        }
                        .padding()
                    }
                    
                    if state == .error{
                        
                        Button(action: {
                            getOnlinePoems()
                        }, label:{
                            Label("Try again", systemImage: "bolt.horizontal.circle")
                        })
                        
                            .padding()
                    }
                    
                    if state == .notFound{
                        
                        
                        VStack(alignment: .center){
                            
                            Button(action: {
                                searchText = ""
                                getOnlinePoems()
                                
                            }, label:{
                                Label("Nothing found", systemImage: "text.badge.xmark")
                                
                            }
                            )
                            
                            
                            
                        }
                        .padding()
                        
                    }
                }
                
                
                #if os(iOS)
                
                .listStyle(.sidebar)
                #endif
                
                .accentColor(Color(userAccentColor))
#if os(macOS)
                
                .frame(minWidth: 200)
#endif
                
#if os(iOS)
                .navigationBarTitle(Text("Poems"))
#else
                .navigationTitle("Poems")
#endif
                
                
                
                
                
                .searchable(text: $searchText)
                .onSubmit(of: .search) {
                    state = .searching
                    let searchTextForURL = searchText.replacingOccurrences(of: " ", with: "%20")
                    searchOnlinePoems(search: searchTextForURL)
                    
                }
                .onChange(of: searchText){ _ in
                    if searchText == ""{
                        getOnlinePoems()
                    }
                }
                #if os(iOS)
                .refreshable {
                    state = .loading
                    onlinePoems = [WebPoem]()
                    getOnlinePoems()
                    getSearchSuggestions(language: language)
                    
                    }
                #endif
                
                
                
            }
            .toolbar{
                /*
                Picker("Language", selection: $language) {
                    ForEach(["English", "Russian"], id: \.self) { l in
                        Text(LocalizedStringKey(l))
                    }
                }*/
                Button(action: {
                    showingSettings.toggle()
                }, label:{
                    Image(systemName: "gear")
                })
                    .popover(isPresented: $showingSettings) {
                        SettingsView()
                            .frame(width: 300, height: 300)
                    }
                    
            }
            .onChange(of: language){ _ in
                onlinePoems = [WebPoem]()
                state = .loading
               
                getOnlinePoems()
                getSearchSuggestions(language: language)
            }
            .onChange(of: fontSize){value in
                if fontSize < 16{
                    linesOnPage = 4
                } else {
                    if fontSize < 19{
                        linesOnPage = 3
                    } else {
                        if fontSize < 23{
                            linesOnPage = 2
                        } else {
                            linesOnPage = 1
                        }
                    }
                }
                
            }
            PoemView(language: "", author: "", title: "", inputText: """
When daisies pied and violets blue
                     And lady-smocks all silver-white
               And cuckoo-buds of yellow hue
                     Do paint the meadows with delight,
               The cuckoo then, on every tree,
               Mocks married men; for thus sings he:
                                                                   “Cuckoo;
               Cuckoo, cuckoo!” O, word of fear,
               Unpleasing to a married ear!

               When shepherds pipe on oaten straws,
                     And merry larks are ploughmen's clocks,
               When turtles tread, and rooks, and daws,
                     And maidens bleach their summer smocks,
               The cuckoo then, on every tree,
               Mocks married men; for thus sings he,
                                                                   “Cuckoo;
               Cuckoo, cuckoo!” O, word of fear,
               Unpleasing to a married ear!
""", complete: false, fontSize: 12, fontName: "System", linesOnPage: 3, customAccentColor: userAccentColor).redacted(reason: .placeholder)
          
            
        } .environmentObject(store)
            .onAppear{
                getSearchSuggestions(language: language)
            }
        
            .accentColor(Color(userAccentColor))
            .navigationViewStyle(.columns)
#if os(macOS)
            .toolbar {
                
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: { // 1
                        Image(systemName: "sidebar.leading")
                    })
                }
            }
#endif
            .task{
                Task{
                    getOnlinePoems()
                    getBookmarkedPoems()
                    getSearchSuggestions(language: "English")
                    
                }
                state = .loaded
                
            }
        
    }
    func incrementStep() {
        value += 1
        if value >= fontSizes.count { value = 0 }
    }
    
    func decrementStep() {
        value -= 1
        if value < 0 { value = fontSizes.count - 1 }
    }
    private func toggleSidebar() { // 2
#if os(iOS)
#else
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
#endif
    }
    
    func getSearchSuggestions(language: String){
        
        Task{
            do {
                
                let url = URL(string: "https://gist.githubusercontent.com/TemaSysoev/f5f7610d4b60c712aa207d28c0225c57/raw")
                let (data, _) = try await URLSession.shared.data(from: url!)
                
                let suggestions = try JSONDecoder().decode([SearchSuggestion].self, from: data)
                
                guard suggestions.count > 0 else {
                    throw gettingPoemsError.emptyPoemsList
                }
                
                for index in 0..<suggestions.count{
                    if suggestions[index].language == language{
                        searchSuggestion.language = suggestions[index].language
                        searchSuggestion.authors = suggestions[index].set.authors
                        searchSuggestion.keyWords = suggestions[index].set.titles
                    }
                }
                
                
                
            }
            catch {
                switch error{
                case gettingPoemsError.emptyPoemsList: print("No poems returned: \n")
                case SearchErrors.noSuggestionsForLanguage: print("No suggestions returned for this language:  \n")
                default: print("Unknown error:\n")
                    
                }
                print(error)
            }
            
        }
        
    }
    
    func getOnlinePoems(){
        
        Task{
            if language == "Russian"{
                
                do{
                    var counter = 0
                    if let bundlePath = Bundle.main.path(forResource: "classic_poems",
                                                         ofType: "json"),
                       let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                        
                        
                        var poems = try JSONDecoder().decode([RussianPoems].self, from: jsonData)
                        poems.shuffle()
                        for index in 0..<poems.count{
                            var author = ""
                            switch poems[index].poet_id{
                            case "pushkin": author = "Пушкин А.С."
                            case "esenin": author = "Есенин С.А."
                            case "mayakovskij": author = "Маяковский В.В."
                            case "blok": author = "Блок А.А."
                            case "tyutchev": author = "Тютчев Ф.И."
                            default: author = "Без автора"
                            }
                            if counter < 10{
                                let poem = WebPoem(id: "\(Insecure.MD5.hash(data: (poems[index].title ?? "" + author).data(using: .utf8)!))", author: author, title: poems[index].title ?? "", text: poems[index].content, language: "Russian", source: "Local")
                                
                                onlinePoems.append(poem)
                                counter += 1
                                
                            }
                            state = LoadingStats.loaded
                            
                        }
                    }
                } catch {
                    print(error)
                }
                
            }
            if language == "English"{
                
                do {
                    // state = LoadingStats.loading
                    
                    
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
                        
                        let poem = WebPoem(id: "\(Insecure.MD5.hash(data: text.data(using: .utf8)!))", author: poems[index].author, title: poems[index].title, text: text, language: "English", source: "PoetryDB")
                        
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
        
        
        
    }
    
    func getBookmarkedPoems(){
        
        Task{
            
            do {
                state = LoadingStats.loading
                bookmarkedPoems = [WebPoem]()
                
                let jsonData = JSONLibrary.data(using: .utf8)
                
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
            state = .searching
            switch language{
            case "English":
                onlinePoems = [WebPoem]()
                Task{
                    
                    do {
                        
                        
                        var loadedPoems = [WebPoem]()
                        
                        let url = URL(string: "https://poetrydb.org/author/\(search)")
                        if url != nil{
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
                                
                                let poem = WebPoem(id: "\(Insecure.MD5.hash(data: text.data(using: .utf8)!))", author: poems[index].author, title: poems[index].title, text: text, language: "English", source: "PoetryDB")
                                
                                loadedPoems.append(poem)
                                
                                
                            }
                            onlinePoems += loadedPoems
                        }
                        
                        
                        
                    } catch {
                        print("author error")
                        
                    }
                    do {
                        
                        
                        var loadedPoems = [WebPoem]()
                        let url = URL(string: "https://poetrydb.org/title/\(search)")
                        if url != nil{
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
                                
                                let poem = WebPoem(id: poems[index].title, author: poems[index].author, title: poems[index].title, text: text, language: "English", source: "PoetryDB")
                                
                                loadedPoems.append(poem)
                                
                                
                            }
                            onlinePoems += loadedPoems
                            
                        }
                        
                        
                    } catch {
                        print("title error")
                        
                    }
                    do {
                        
                        
                        var loadedPoems = [WebPoem]()
                        let url = URL(string: "https://poetrydb.org/lines/\(search)")
                        if url != nil{
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
                                
                                let poem = WebPoem(id: "\(Insecure.MD5.hash(data: text.data(using: .utf8)!))", author: poems[index].author, title: poems[index].title, text: text, language: "English", source: "PoetryDB")
                                
                                loadedPoems.append(poem)
                                
                                
                            }
                            onlinePoems += loadedPoems
                        }
                        
                        
                        
                    } catch {
                        print("lines error")
                        
                    }
                    
                    if searchResults.isEmpty {
                        state = .notFound
                        
                    }else{
                        print(searchResults)
                    }
                }
                state = .loaded
            case "Russian":
                
                Task{
                    do{
                      
                        if let bundlePath = Bundle.main.path(forResource: "classic_poems",
                                                             ofType: "json"),
                           let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                            
                            
                            var poems = try JSONDecoder().decode([RussianPoems].self, from: jsonData)
                            poems.shuffle()
                            for index in 0..<poems.count{
                                var author = ""
                                switch poems[index].poet_id{
                                case "pushkin": author = "Пушкин А.С."
                                case "esenin": author = "Есенин С.А."
                                case "mayakovskij": author = "Маяковский В.В."
                                case "blok": author = "Блок А.А."
                                case "tyutchev": author = "Тютчев Ф.И."
                                default: author = "Без автора"
                                }
                                
                                    let poem = WebPoem(id: "\(Insecure.MD5.hash(data: (poems[index].title ?? "" + author).data(using: .utf8)!))", author: author, title: poems[index].title ?? "", text: poems[index].content, language: "Russian", source: "Local")
                                    
                                    onlinePoems.append(poem)
                                   
                                    
                                
                               
                                
                            }
                        }
                    } catch {
                        print(error)
                    }
                    onlinePoems = onlinePoems.filter {($0.author.lowercased().contains(searchText.lowercased()) || $0.title.lowercased().contains(searchText.lowercased()) || $0.text.lowercased().contains(searchText.lowercased()))}
                    if onlinePoems.isEmpty {
                        state = .notFound
                    } else {
                        state = .loaded
                    }
                    
                }
                
            default: print("Unknown language")
            }
            
        }
    }
    
}



struct NavigationView_Previews: PreviewProvider {
    static var previews: some View {
        ColumnsView()
    }
}
