//
//  ChatIndexView.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/04/01.
//

import SwiftUI

// Chat index view that shows list of chats

struct ChatIndexView: View {
    @EnvironmentObject var chatStore: ChatStore
    @State private var showingUserSettings = false

    var body: some View {
        VStack {
            HStack {

                // Button to add a new chat

                Button(action: {
                    addChat()
                }, label: {
                    Label("Add New Chat", systemImage: "plus.circle")
                })
                .buttonStyle(.borderedProminent)

                Spacer()

                // Button to show the User Settings

                Button(action: {
                    showingUserSettings.toggle()
                }, label: {
                    Image(systemName: "gear")
                        .font(.title2)
                })
            }.padding(.horizontal)

            // List of chats

            List($chatStore.conversations, editActions: .delete) { $conversation in
                NavigationLink(value: conversation.id) {
                    ChatIndexRowView(conversation: conversation)
                }
            }
            // navDest: iOS 16+, shows dest-views lazily
            .navigationDestination(for: UUID.self) { id in

                // Chat view

                ChatView(conversationID: id)
            }
        }
        .navigationTitle("Chats")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingUserSettings) {

            // User Setting view

            UserSettingsView(userSettings: $chatStore.userSettings)
        }
        .onAppear {

            // Show the User Settings view if API Key is not set.

            if chatStore.userSettings.openAIAPIKey.isEmpty {
                showingUserSettings = true
            }
        }
    }

    // Add a new chat
    private func addChat() {
        chatStore.addNewConversation()
    }
}

// Chat List Row view

struct ChatIndexRowView: View {
    let conversation: Conversation

    var body: some View {
        VStack(alignment: .leading) {

            // Title

            Text(conversation.title)
                .fontWeight(.bold)

            // The first message

            Text(conversation.firstUserContent)
                .fontWeight(.light)
                .lineLimit(2, reservesSpace: true)

            // Date

            Text(conversation.lastUpdated.formatted())
                .foregroundColor(.secondary)
                .fontWeight(.light)
        }
    }
}

struct ChatIndexView_Previews: PreviewProvider {
    static var previews: some View {
        ChatIndexView()
            .environmentObject(ChatStore.sample)
    }
}
