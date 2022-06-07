//
//  GetPoems.swift
//  Poems2
//
//  Created by Tema Sysoev on 04.06.2021.
//

import Foundation

struct WebPoem: Identifiable, Encodable, Equatable, Decodable{
    var id: String
    
    let author: String
    let title: String
    let text: String
    let language: String
    
    let source: String
    
}

struct PoetryDB: Codable, Hashable{
    let title: String
    let author: String
    let lines: [String]
    let linecount: String
}
struct LocalPoems: Codable {
    let title: String
    let text: String
    let author: String
    let language: String
}
struct RussianPoems: Codable {
    let poet_id: String
    let title: String?
    let content: String
}


enum gettingPoemsError: Error {
    case emptyPoemsList
}


struct WebPoemsHelper{
    
    func parse(json: Data, source: String) -> [WebPoem]{
        
        let decoder = JSONDecoder()
        var result = [WebPoem]()
        switch source{
      
        case "Local":
            if let jsonPoems: [LocalPoems] = try? decoder.decode([LocalPoems].self, from: json) {
                
                let poems = jsonPoems
                
                for index in 0..<poems.count{
                    let poem = WebPoem(id: poems[index].author, author: poems[index].author, title: poems[index].title, text: poems[index].text, language: poems[index].language, source: "local")
                    
                    result.append(poem)
                    
                }
                
                
            }else{
                print("error while parsing from local")
            }
        default:
            print("unrecognised source")
            
        }
        return result
    }
    
    
    
    func recognizeSource(url: String) -> String{
        var sourceName = "Local"
        if url.contains("poemist"){
            sourceName = "Poemist"
        }
        if url == "https://github.com/TemaSysoev/Poems2/blob/main/Shared/data.json"{
            sourceName = "Local"
        }
        
        
        return sourceName
    }
}
