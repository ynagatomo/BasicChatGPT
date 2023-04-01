//
//  BasicChatGPTApp.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/03/29.
//

import SwiftUI

// An iOS chat app using OpenAI Chat API with GPT-3.5/GPT-4
@main
struct BasicChatGPTApp: App {
    @StateObject private var chatStore = ChatStore()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(chatStore)
                .onAppear {
                    chatStore.setup()   // loads conversations and settings
                }
                .onChange(of: scenePhase) { newPhase in
                    // You may need to handle the inactive phase only.
                    if newPhase == .inactive || newPhase == .background {
                        chatStore.save()    // saves conversations and settings
                    } else {
                        // active phase: do nothing
                    }
                }
        }
    }
}
