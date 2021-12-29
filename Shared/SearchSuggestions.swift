//
//  SearchSuggestions.swift
//  Poems
//
//  Created by Tema Sysoev on 24.12.2021.
//

import Foundation
import CryptoKit

public struct SearchSuggestion: Codable {
    let language: String
    let set: SearchSuggestionsSet
}
public struct SearchSuggestionsSet: Codable {
    let authors: [String]
    let titles: [String]
}
public struct Suggestion{
    var language = "English"
    var authors = [""]
    var keyWords = [""]
}
enum SearchErrors: Error{
    case noSuggestionsForLanguage
}
 

