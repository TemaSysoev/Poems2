//
//  ContentView.swift
//  Shared
//
//  Created by Tema Sysoev on 04.06.2021.
//

import SwiftUI
import CoreData

struct WebPoem: Identifiable, Encodable, Equatable, Decodable{
    var id: String
    
    let author: String
    let title: String
    let text: String
    let language: String
    
    let source: String
    
}
enum LoadingStats{
    case loading
    case loaded
    case error
    case notFound
}
let defaults = UserDefaults.standard

func loadBookmarked() -> [String]{
    if defaults.object(forKey: "booked") != nil {
        return defaults.object(forKey: "booked")! as! [String]
    }else{
        return [""]
    }
    
}
func saveBookmarked(_ newPoem: String){
    
    var tmpPoems = loadBookmarked()
    let textForLink = newPoem.replacingOccurrences(of: " ", with: "%20")
    let endOfLine = textForLink.firstIndex(of: "\n")!
    let firstLine = textForLink[..<endOfLine]
    tmpPoems.append("\(firstLine)")
    
    
    defaults.set(tmpPoems, forKey: "booked")
    
}



private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()
/*
 struct ContentView_Previews: PreviewProvider {
 static var previews: some View {
 PoemsListView(source: "online", onlinePoems: onlinePoems)
 }
 }*/
