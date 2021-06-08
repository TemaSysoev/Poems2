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
struct LocalPoems: Codable {
    let title: String
    let text: String
    let author: String
    let language: String
}
struct Poet: Codable{
    let name: String
    let url:String
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
                    let poem = WebPoem(author: poems[index].poet.name, title: poems[index].title, text: poems[index].content, language: "English")
                    
                    result.append(poem)
                    
                }
                
                
            }else{
                print("error while parsing from Poemist")
            }
        case "Local":
            if let jsonPoems: [LocalPoems] = try? decoder.decode([LocalPoems].self, from: json) {
                
                let poems = jsonPoems
                
                for index in 0..<poems.count{
                    let poem = WebPoem(author: poems[index].author, title: poems[index].title, text: poems[index].text, language: poems[index].language)
                    
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
    
    func getPoemsFromJson(site: String) -> [WebPoem]{
        var result = [WebPoem]()
        
        
        if let url = URL(string: site) {
            
            if let data = try? Data(contentsOf: url) {
                
                result = WebPoemsHelper().parse(json: data, source: recognizeSource(url: site))
            }else{
                print("data error")
            }
        }
        return result
    }
    func recognizeSource(url: String) -> String{
        var sourceName = ""
        if url.contains("poemist"){
            sourceName = "Poemist"
        }
        if url == "https://github.com/TemaSysoev/Poems2/blob/main/Shared/data.json"{
            sourceName = "Local"
        }
        
        
        return sourceName
    }
}
