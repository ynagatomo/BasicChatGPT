//
//  ChatView.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/04/01.
//

import SwiftUI

// Chat view

struct ChatView: View {
    @EnvironmentObject var chatStore: ChatStore
    @State private var showingChatSettings = false

    // A conversation related to this view.
    let conversationID: UUID
    var conversationIndex: Int {
        chatStore.conversationIndex(of: conversationID)!
    }

    // If communicating with the OpenAI server.
    var isIdle: Bool {
        chatStore.conversations[conversationIndex].state == .idle
    }
    // The number of tokens of this conversation.
    var allTokens: Int {
        chatStore.conversations[conversationIndex].allTokens
    }

    var body: some View {
        VStack(alignment: .leading) {

            // Header

            HStack {
                Spacer()
                Image(systemName: "server.rack")
                    .font(.system(size: 30))
                    .foregroundColor(Color("AIChatBG"))

                // Selected GPT model name

                Text(chatStore.conversations[conversationIndex].settings.chatModel.rawValue)
                    .fontWeight(.bold)

                // Specified system's role

                Text(chatStore.conversations[conversationIndex].settings.systemContent)
                    .lineLimit(1)
                    .fontWeight(.light)
                Spacer()
            }

            // Chat messages

            List($chatStore.conversations[conversationIndex].chats, editActions: .delete) { $chat in
                HStack {

                    // Icon

                    Image(systemName: chat.role == OpenAIChatRole.user.rawValue
                          ? "person.fill" : "server.rack")
                        .font(.system(size: 30))
                        .frame(width: 32)
                        .foregroundColor(chat.role == OpenAIChatRole.user.rawValue
                                         ? Color("UserChatBG")
                                         : Color("AIChatBG"))

                    // Textfield (editable and deletable)

                    TextField(chat.role, text: $chat.content, axis: .vertical)
                        .padding(8)
                        .background(chat.role == OpenAIChatRole.user.rawValue
                                    ? Color("UserChatBG").cornerRadius(10)
                                    : Color("AIChatBG").cornerRadius(10))
                        .fontWeight(.light)
                }
                .listRowSeparator(.hidden)
            }
            .textSelection(.enabled)        // User is allowed to select the text.
            .safeAreaInset(edge: .bottom) { // Buttons over the list at bottom
                 HStack {

                     // Button to add a message

                     Button(action: {
                         addMessage()
                     }, label: {
                         Label("Add Message", systemImage: "plus.circle")
                     })
                     .buttonStyle(.borderedProminent)
                     .disabled(!isIdle)  // disabled while communicating with OpenAI

                     Spacer()

                     // Status - tokens or progress which indicates communication with OpenAI

                     if isIdle {
                         Text("\(allTokens) tokens") // tokens of current chat
                     } else {
                         ProgressView()     // communicating with OpenAI server
                     }

                     Spacer()

                     // Button to send the chat to OpenAI server

                     Button(action: {
                         sendChat()
                     }, label: {
                         Label("Send", systemImage: "paperplane")
                     })
                     .buttonStyle(.borderedProminent)
                     .tint(Color("SendBtn"))
                     .disabled(!isIdle) // disabled while communicating with OpenAI
                 }
                 .padding(.horizontal)
            }
        }
        // bat title editing is enable in only inline mode
        .navigationTitle($chatStore.conversations[conversationIndex].title) // editable navi-title
        .navigationBarTitleDisplayMode(.inline) // should be inline mode for editing
        .toolbarRole(.editor)                   // aligned to leading edge
        .toolbar {

            // Button for Chat Settings

            Button(action: {
                showingChatSettings.toggle()
            }, label: {
                Image(systemName: "gear")
                Text("Chat Settings")
            })
        }
        .sheet(isPresented: $showingChatSettings) {

            // Chat Settings view

            ChatSettingsView(chatSettings: $chatStore.conversations[conversationIndex].settings)
        }
    }

    // Add a new message to this conversation
    private func addMessage() {
        chatStore.addChat(for: conversationIndex)
    }

    // Send this conversation (chat) to OpenAI server to get GPT's response
    //
    // Each conversation (chat) can be send to OpenAI simultaneously.
    // So multi tasks run simultaneously.
    private func sendChat() {
        Task {
            await chatStore.sendConversation(of: conversationID)
        }
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(conversationID: ChatStore.sample.conversations[0].id)
            .environmentObject(ChatStore.sample)
    }
}
