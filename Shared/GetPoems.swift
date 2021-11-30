//
//  GetPoems.swift
//  Poems2
//
//  Created by Tema Sysoev on 04.06.2021.
//

import Foundation


struct PoemistPoems: Codable {
    let title: String
    let content: String
    let url: String
    let poet: Poet
}


struct PoetryDB: Codable{
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
struct TestRussianPoems: Codable {
    let poet_id: String
    let title: String
    let content: String
}
struct Poet: Codable{
    let name: String
    let url:String
}

enum gettingPoemsError: Error {
    case emptyPoemsList
}


struct WebPoemsHelper{
    
    func parse(json: Data, source: String) -> [WebPoem]{
        
        let decoder = JSONDecoder()
        var result = [WebPoem]()
        switch source{
        case "Poemist":
            if let jsonPoems: [PoemistPoems] = try? decoder.decode([PoemistPoems].self, from: json) {
                
                let poems = jsonPoems
                
                for index in 0..<poems.count{
                    let poem = WebPoem(id: poems[index].poet.name, author: poems[index].poet.name, title: poems[index].title, text: poems[index].content, language: "English", source: "poemist")
                    
                    result.append(poem)
                    
                }
                
                
            }else{
                print("error while parsing from Poemist")
            }
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
    func getPoems() async throws -> [WebPoem]{
        var onlinePoems = [WebPoem]()
     
            do {
                var loadedPoems = [WebPoem]()
                let url = URL(string: "https://www.poemist.com/api/v1/randompoems")
                let (data, _) = try await URLSession.shared.data(from: url!)
             
                
                let poems = try JSONDecoder().decode([PoemistPoems].self, from: data)
                
                guard poems.count > 0 else {
                    throw gettingPoemsError.emptyPoemsList
                }
                for index in 0..<poems.count{
                    let poem = WebPoem(id: poems[index].poet.name, author: poems[index].poet.name, title: poems[index].title, text: poems[index].content, language: "English", source: "poemist")
                    
                    loadedPoems.append(poem)
                    
                    
                }
                onlinePoems = loadedPoems
               
              
            } catch {
                print("error")
            }
        
       
        return onlinePoems
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
