//
//  PoemView.swift
//  Poems2
//
//  Created by Tema Sysoev on 08.06.2021.
//

import SwiftUI

struct PoemView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var language: String
    @State var author: String
    @State var title: String
    @State var inputText: String
    @State var complete: Bool
    
    @State var selectedIndex = Int()
    @State var fourLines = ["""
    """]
    @State var checkAnswer = "Слушаю..."
    @State var debugText = ""
    @State var paragraphStep = 0
    
    @State var userText = ""
    @State var statusColor = Color.accentColor
    
    @State var searchText = ""
    
    @State var c1out = ""
    @State var c2out = ""
    @State var misOut = ""
    @State var debug = false
    
    @State var showLearnView = false
    @State var showSettings = false
    @State var addNew = false
    
    @State var slicedText = ""
    
    
    @State var showingSheet = false
    
    @State var selectedLanguage = "Rus"
    
    
    @State var price = String()
    
    @State private var showReadingSettings = false
    @State private var showingLearnView = false
    @State private var showingCameraViewController = false
    public var fontSize: Int
    public var fontName: String
    public var linesOnPage: Int
    public var backgroundImageName: String
    var listOfFonts = ["System", "Helvetica Neue", "Athelas", "Charter", "Georgia", "Iowan", "Palatino", "New York", "Seravek", "Times New Roman"]
    var listOfFontSizes = [12, 18, 24]
    var listOfLinesOnPage = [2, 3, 4]
    
    @State public var offset = CGSize(width: 0, height: 0)
    @State var pushBack = false
    @State var drag = false
    @State private var currentPage = 1
    @State private var nextPage = 2
   
    
    var body: some View {
        ZStack(alignment: .center){
           
           
        VStack(alignment: .center){
            
            Spacer()
            ZStack(alignment: .center){
               
                            VStack{
                                ForEach(0..<fourLines.count, id: \.self){ index in
                                    
                                    if (index / linesOnPage < (currentPage + 1)) && (index/linesOnPage >= currentPage) {
                                        
                                        Text(fourLines[index])
                                            
                                            .id("\(index)")
                                            .multilineTextAlignment(.center)
                                            .font(fontName == "System" ? .system(size: CGFloat(fontSize), design: .serif):.custom(fontName, size: CGFloat(fontSize)))
                                            
                                            .allowsTightening(true)
                                            .padding()
                                            .foregroundColor(Color.primary)
                                            
                                            .onChange(of: inputText, perform: { value in
                                                fourLineParse()
                                            })
                                            .onAppear{
                                                fourLineParse()
                                            }
                                        
                                    }
                                   
                                }
                                if currentPage - 1 == fourLines.count / linesOnPage {
                                    Label("To beginning", systemImage: "arrow.uturn.left")
                                        .font(fontName == "System" ? .system(size: CGFloat(fontSize), design: .serif):.custom(fontName, size: CGFloat(fontSize)))
                                       
                                        .padding()
                                        .foregroundColor(Color.primary)
                                }
                            }
                        .frame(width: 380, height: 560, alignment: .center)
                        .offset(x: 0, y: -(10-self.offset.width/10))
                        .background(Color("BackgroundColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .zIndex(pushBack ? 2 : 1)
                        .padding()
                
                        .shadow(color: Color.black.opacity(0.2), radius: 3.0, x: 0, y: 0)
                
                        .scaleEffect(x: (abs(self.offset.width) + 800)/1000, y: (abs(self.offset.width) + 800)/1000, anchor: .center)
                        
                        
                            VStack{
                                
                                ForEach(0..<fourLines.count, id: \.self){ index in
                                    
                                    if (index / linesOnPage < currentPage) && (index/linesOnPage >= currentPage - 1) {
                                        
                                        Text(fourLines[index])
                                        
                                            .id("\(index)")
                                           
                                            .multilineTextAlignment(.center)
                                            .font(fontName == "System" ? .system(size: CGFloat(fontSize), design: .serif):.custom(fontName, size: CGFloat(fontSize)))
                                            .allowsTightening(true)
                                            
                                            .padding()
                                            .foregroundColor(Color.primary)
                                            .onChange(of: inputText, perform: { value in
                                                fourLineParse()
                                            })
                                            .onAppear{
                                                fourLineParse()
                                            }
                                        
                                    }
                                }
                            }
                           
                            .frame(width: 380, height: 560, alignment: .center)
                            .background(Color("BackgroundColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .padding()
                            .shadow(color: Color.black.opacity(0.2), radius: 3.0, x: 0, y: 0)
                            .zIndex(pushBack ? 1 : 2)
                            .offset(x: self.offset.width<150 ? self.offset.width*2: (150-(self.offset.width-150))*2, y: 0)
                      //  .animation(.spring(), value: self.offset)
                        .rotationEffect(.degrees(Double(90*self.offset.width)/3000))
                        .scaleEffect(x: 1 - abs(self.offset.width)/1800, y: 1 - abs(self.offset.width)/1800, anchor: .center)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    self.drag = true
                                    self.offset = gesture.translation
                                    if (abs(self.offset.height) > 100) || (abs(self.offset.width) > 150){
                                        self.pushBack = true
                                    }else{
                                        self.pushBack = false
                                    }
                                }
                            
                                .onEnded { _ in
                                    self.drag = false
                                    if (abs(self.offset.height) > 100) || (abs(self.offset.width) > 100){
                                        
#if os(iOS)
                                        let impactMed = UIImpactFeedbackGenerator(style: .light)
                                        impactMed.impactOccurred()
#endif
                                        self.pushBack = false
                                        self.offset = .zero
                                        if currentPage < fourLines.count / linesOnPage + 1{
                                            currentPage += 1
                                            nextPage += 1
                                        }else{
                                            currentPage = 1
                                            nextPage = 2
                                        }
                                        
                                       
                                        
                                        
                                    } else {
                                        self.pushBack = false
                                        self.offset = .zero
                                    }
                                    
                                    
                                }
                        )
                        
                        
                        
                    
            }
            
            .frame(maxWidth: .infinity)
            Spacer()
            HStack{
#if os(iOS)
                Button(action:{
                    showingLearnView = true
                    
                }, label:{
                   Image(systemName: "brain.head.profile")
                        .padding()
                })
                    
                    .background(.thinMaterial)
                    .clipShape(Circle())
                    .sheet(isPresented: $showingLearnView) {
                        LearnView(language: language, author: author, title: title, inputText: inputText, fontName: fontName)
                    }
#endif
            HStack{
                Button(action: {
                    currentPage -= 1
                    nextPage -= 1
                }, label: {
                    Image(systemName: "chevron.left")
                        .padding()
                })
                    .buttonStyle(.borderless)
                    .background(.thinMaterial)
                    .clipShape(Circle())
                    .disabled(!(currentPage > 1))
                    .padding(7)
                Text("\(currentPage) of \(fourLines.count / linesOnPage + 1)")
                    .padding()
                Button(action: {
                    currentPage += 1
                    nextPage += 1
                }, label: {
                    Image(systemName: "chevron.right")
                        .padding()
                })
                    .buttonStyle(.borderless)
                    .background(.thinMaterial)
                    .clipShape(Circle())
                    .disabled(!(currentPage < fourLines.count / linesOnPage + 1))
                    .padding(7)
            }
            
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 100))
#if os(iOS)
                Button(action:{
                    showingCameraViewController = true
                    
                }, label:{
                   Image(systemName: "video")
                        .padding()
                })
                    
                    .background(.thinMaterial)
                    .clipShape(Circle())
                    .sheet(isPresented: $showingCameraViewController) {
                        CameraAndTextView(language: language, author: author, title: title, inputText: inputText, fontName: fontName)
                    }
#endif
        }
            .padding()

        }
        
            
    }
        
        
    }
    
    static func stringify(json: Any, prettyPrinted: Bool = false) -> String {
        var options: JSONSerialization.WritingOptions = []
        if prettyPrinted {
            options = JSONSerialization.WritingOptions.prettyPrinted
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: options)
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            print(error)
        }
        
        return ""
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
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
    func fourLineParse() {
        var tmpLines = inputText.components(separatedBy: .newlines)
        var tmpFourLines = ["""
        """]
        var tmpCounter = 0
        var pararaphCounter = 0
        for i in 0..<tmpLines.count{
            tmpLines[i] = tmpLines[i].replacingOccurrences(of: "    ", with: "")
            
            if tmpCounter < 4{
                tmpFourLines[pararaphCounter] += (tmpLines[i] + "\n")
                tmpCounter += 1
            }else{
                pararaphCounter += 1
                tmpCounter = 1
                tmpFourLines.append(tmpLines[i] + "\n")
            }
        }
        fourLines = tmpFourLines
    }
    func getFirstAndEndWord(s: String) -> [String]{
        let splited = s.components(separatedBy: .whitespaces)
        var result = [String]()
        result.append(splited[0])
        result.append(splited[splited.endIndex-1])
        return result
    }
    func misL(s1: String, s2: String) -> Int {
        if s1.count*s2.count != 0 {
            let a1 = Array(s1)
            let a2 = Array(s2)
            
            var f = [[Int]](repeating: [Int](repeating: 0, count: s2.count + 1), count: s1.count + 1)
            for i in 0...s1.count {
                for j in 0...s2.count{
                    if i*j == 0 {
                        f[i][j] = i+j
                    }else{
                        f[i][j] = 0
                    }
                }
            }
            for i in 1...s1.count {
                for j in 1...s2.count{
                    if a1[i-1] == a2[j-1] {
                        f[i][j] = f[i-1][j-1]
                    }else{
                        f[i][j] = 1 + min(f[i-1][j], f[i][j-1], f[i-1][j-1])
                    }
                }
            }
            
            
            return f[s1.count][s2.count]
        } else{
            return max(s1.count, s2.count)
        }
    }
}

struct PoemView_Previews: PreviewProvider {
    static var previews: some View {
        PoemView(language: "RUS", author: "Пушкин А.С.", title: "Письмо Татьяны к Онегину", inputText: "Я к вам пишу – чего же боле?\nЧто я могу еще сказать?\nТеперь, я знаю, в вашей воле\nМеня ", complete:false, fontSize: 18, fontName: "System", linesOnPage: 3, backgroundImageName: "pattern1")
    }
}
