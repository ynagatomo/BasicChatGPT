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
    @FocusState private var isFocused: Bool  // focus on a keyboard

    // A conversation related to this view.
    let conversationID: UUID
    var conversationIndex: Int? {
        // The conversation showed in the view might be deleted or moved to other index.
        chatStore.conversationIndex(of: conversationID)
    }

    // If communicating with the OpenAI server.
    var isIdle: Bool {
        conversationIndex == nil
        ? true
        : chatStore.conversations[conversationIndex!].state == .idle
    }
    // The number of tokens of this conversation.
    var allTokens: Int {
        conversationIndex == nil
        ? 0
        : chatStore.conversations[conversationIndex!].allTokens
    }

    var body: some View {
        if let conversationIndex {
            VStack(alignment: .leading) {

                // Header

                HStack {
                    Spacer()

                    // Icon

                    Image(systemName: "server.rack")
                        .font(.system(size: 30))
                        .foregroundColor(Color("AIChatFG"))

                    // Selected GPT model name

                    Text(chatStore.conversations[conversationIndex].settings.chatModel.rawValue)
                        .fontWeight(.bold)

                    // Specified system's role

                    Text(chatStore.conversations[conversationIndex].settings.systemContent)
                        .lineLimit(1)
                        .fontWeight(.light)
                    Spacer()
                } // HStack

                // Chat messages

                List($chatStore.conversations[conversationIndex].chats, editActions: .all /* .delete */ ) { $chat in
                    HStack {

                        // Icon

                        Image(systemName: chat.role == OpenAIChatRole.user.rawValue
                              ? "person.fill" : "server.rack")
                        .font(.system(size: 30))
                        .frame(width: 32)

                        // Textfield (editable and deletable)

                        TextField(chat.role, text: $chat.content, axis: .vertical)
                            .padding(8)
                            .background(chat.role == OpenAIChatRole.user.rawValue
                                        ? Color("UserChatBG").cornerRadius(10)
                                        : Color("AIChatBG").cornerRadius(10))
                            .fontWeight(.light)
                            .focused($isFocused)
                    }
                    .listRowSeparator(.hidden)
                    .foregroundColor(chat.role == OpenAIChatRole.user.rawValue
                                     ? Color("UserChatFG")
                                     : Color("AIChatFG"))
                } // List
                .toolbar { // Button to hide the keyboard by unfocusing
                    ToolbarItemGroup(placement: .keyboard) {
                        Button(action: { isFocused = false }, label: {
                            Label("Hide", systemImage: "arrow.down")
                        })
                    }
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
                } // safeAreaInset
            } // VStack
            // bat title editing is enable in only inline mode
            .navigationTitle($chatStore.conversations[conversationIndex].title) // editable navi-title
            .navigationBarTitleDisplayMode(.inline) // should be inline mode for editing
            .toolbarRole(.editor)                   // aligned to leading edge
            .toolbar {
                ToolbarItem(id: "duplicate", placement: .primaryAction) {

                    // Button for duplication of conversation

                    Button(action: {
                        duplicate()
                    }, label: {
                        Image(systemName: "doc.on.doc")
                    })
                }

                ToolbarItem(id: "settings", placement: .primaryAction) {

                    // Button for Chat Settings

                    Button(action: {
                        showingChatSettings.toggle()
                    }, label: {
                        Image(systemName: "gearshape.2")
                        //                Image(systemName: "gear")
                        //                Text("Chat Settings")
                    })
                }
            } // toolbar
            .sheet(isPresented: $showingChatSettings) {

                // Chat Settings view

                ChatSettingsView(chatSettings: $chatStore.conversations[conversationIndex].settings)
            } // sheet
        } else {
            // The conversation could be inaccessible.
            Text("Select a chat.")
        }
    } // body

    // Add a new message to this conversation
    private func addMessage() {
        guard let conversationIndex else { return }
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

    // Duplicate the current conversation to branch the thread
    private func duplicate() {
        chatStore.duplicateConversation(of: conversationID)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(conversationID: ChatStore.sample.conversations[0].id)
            .environmentObject(ChatStore.sample)
    }
}
