//
//  PoemView.swift
//  Poems2
//
//  Created by Tema Sysoev on 08.06.2021.
//

import SwiftUI

struct PoemView: View {
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
    
    @State var help = true
    @State var showSettings = false
    @State var addNew = false
    
    @State var slicedText = ""
    
   
    @State var showingSheet = false
    
    @State var selectedLanguage = "Rus"
    
   
    @State var price = String()
  
   
    var body: some View {
        
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false){
                
                ForEach(0..<fourLines.count, id: \.self){ index in
                    if index != paragraphStep {
                        Button(action: {
                            paragraphStep = index
                        }, label: {
                            Text(fourLines[index])
                                .font(.system(.title2, design: .serif))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                        })
                        .buttonStyle(BorderlessButtonStyle())
                        
                        .id("\(index)")
                    }else{
                        Button(action: {
                            help.toggle()
                        }, label: {
                            Text(fourLines[paragraphStep])
                                
                                .id("current")
                                .multilineTextAlignment(.center)
                                .font(.system(.title2, design: .serif))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color.primary)
                                .onChange(of: inputText, perform: { value in
                                    fourLineParse()
                                })
                                .onAppear{
                                    fourLineParse()
                                }
                        })
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            
            .frame(maxWidth: .infinity)
            .onAppear(perform: {
                proxy.scrollTo("current")
            })
            .onChange(of: paragraphStep, perform: { value in
                proxy.scrollTo("current")
            })
            
            .animation(.spring())
            .foregroundColor(.black)
            
        }
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
        PoemView(language: "RUS", author: "", title: "", inputText: "", complete:false)
    }
}
