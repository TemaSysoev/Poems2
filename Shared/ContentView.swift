//
//  ContentView.swift
//  Shared
//
//  Created by Tema Sysoev on 04.06.2021.
//

import SwiftUI
import CoreData


enum LoadingStats{
    case loading
    case loaded
    case error
    case notFound
}
enum Event{
    case didLoad
    case didFail
    case fetchNext
    case languageSwithed
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
