//
//  ContentView.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/03/29.
//

import SwiftUI

// Main content view

struct ContentView: View {
    var body: some View {
        NavigationSplitView {
            ChatIndexView()
        } detail: {
            Text("Select a chat.")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ChatStore.sample)
    }
}
