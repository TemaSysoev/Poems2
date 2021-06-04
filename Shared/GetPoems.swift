//
//  GetPoems.swift
//  Poems2
//
//  Created by Tema Sysoev on 04.06.2021.
//

import Foundation
import SwiftUI

struct DemoData: Codable {

    let title: String
    let text: String
    let author: String
    let language: String

}

struct WebPoemsHelper{
    
    func getJsonFile(link: String, completion: @escaping (Result<Data, Error>) -> Void){
        if let url = URL(string: link){
            let urlSession = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
                if let error = error {
                    completion(.failure(error))
                    
                }
                if let data = data {
                    completion(.success(data))
                    
                }
            }
            urlSession.resume()
        }
        
    }
    func parseJsonFile(data: Data) -> Poem{
        let poem = Poem()
        do {
            let decodedData = try JSONDecoder().decode(DemoData.self, from: data)
            
            poem.title = decodedData.title
            poem.text = decodedData.text
            poem.author = decodedData.author
            poem.language = decodedData.language
        }catch{
            poem.title = "Error parsing json"
            poem.text = "Placeholder text"
            poem.author = "Bug"
            poem.language = "Russian"
        }
        
        return poem
    }
}
