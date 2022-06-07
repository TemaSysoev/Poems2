//
//  CompareHelper.swift
//  Stihi
//
//  Created by Tema Sysoev on 24.03.2021.
//

import Foundation
import SwiftUI
struct UIOutput {
    func getColor(_ s: String) -> Color {
        var color = Color.accentColor
        switch s {
        case "Ошибка":
            color = Color.red
        default:
            color = Color.accentColor
        }
        
        return color
    }
    func slice(s1: String, s2: String) -> String{
        var slicedText = ""
        
        let allWords = s2.components(separatedBy: .whitespacesAndNewlines)
        
        var openWordsCounter = s1.components(separatedBy: .whitespacesAndNewlines).count - 1
        var helperForSlicedText = [String]()
        
        let symbols = [" ", ",", ".", "…", "!", "?", "", "—", ";", ":", "–"]
        if openWordsCounter < allWords.count{
            slicedText = ""
            if openWordsCounter > 0{
                helperForSlicedText = Array(allWords[0...openWordsCounter])
                for index in 0..<helperForSlicedText.count{
                    for jndex in 0..<symbols.count{
                        if helperForSlicedText[index] == symbols[jndex]{
                            openWordsCounter += 1
                        }
                    }
                }
                for i in 0..<helperForSlicedText.count {
                    slicedText += " " + helperForSlicedText[i]
                }
            }
        }else{
            slicedText = ""
        }
        return slicedText
    }
}
struct Check{
    var language = "Rus"
    func simplify(_ s: String) -> String{
        var result = s.lowercased()
    
            let badSymbols = [" ", ",", ".", "…", "!", "?", "", "—", ";", ":", "\n", "а", "о", "и", "е", "ё", "э", "я", "у", "ю", "сс", "нн", "ы", "й", "ь", "ъ", "–", "e", "y", "u", "i", "o", "a", "'", "-", "s", "r", "w", "z", "c", "d", "l", "t", "x"]
            for symbol in badSymbols {
                result = result.replacingOccurrences(of: symbol, with: "")
            }
       
        return result
    }
    func simplifyTypedText(_ s: String) -> String{
        var result = s.lowercased()
    
            let badSymbols = [" ", ",", ".", "…", "!", "?", "", "—", ";", ":", "\n", "\""]
            for symbol in badSymbols {
                result = result.replacingOccurrences(of: symbol, with: "")
            }
       
        return result
    }
    
    func levenshteinDistance(s1: String, s2: String) -> Int {
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
    func compareTypedText(s1: String, s2: String) -> String{
        
        let c1 = simplifyTypedText(s1)
        let c2 = simplifyTypedText(s2)
        
        var state = "Проверяем"
        
        if c1 != "" && c2 != ""{
            
            if c2.contains(c1) {
                if c2.first == c1.first{
                    
                    if c2 == c1{
                        state = "Все верно"
                       
                    }else{
                        state = "Слушаю..."
                        
                    }
                }else{
                    state = "Ошибка"
                }
                
            } else {
                state = "Ошибка"
            }
        
       
        
    }
        return state
    }
    func compare(s1: String, s2: String) -> String{
        
        let c1 = simplify(s1)
        var c2 = simplify(s2)
        
        var state = "Проверяем"
        
        if c1 != "" && c2 != ""{
            
            if c2.contains(c1) {
                if c2 == c1{
                    state = "Все верно"
                   
                }else{
                    state = "Слушаю..."
                    
                }
                
            }else{
                if c1.count < c2.count {
                    c2 = String(c2[c1.startIndex..<c1.endIndex])
                    if levenshteinDistance(s1: c1, s2: c2) <= 10{
                        state = "Слушаю..."
                       
                    }else{
                        state = "Ошибка"
                        
                    }
                }else{
                    if levenshteinDistance(s1: c1, s2: c2) <= 10{
                        state = "Все верно"
                       
                    }else{
                        state = "Ошибка"
                        
                    }
                }
                
               
            }
        }
        else {
            state = "Слушаю..."
           
        }
        
        return state
        
    }
}
