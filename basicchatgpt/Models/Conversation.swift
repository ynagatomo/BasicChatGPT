//
//  Conversation.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/04/01.
//

import Foundation

// Conversation between person and AI

struct Conversation: Identifiable, Codable {
    enum State: Int, Codable {
        case idle    // doing nothing
        case asking  // communicating with OpenAI server
    }

    private(set) var id = UUID() // ID
    var state = State.idle       // state
    var title: String         // conversation title
    var chats = [Chat]()      // conversation messages (chats) by person and AI
    private(set) var lastUpdated = Date() // last updated date
    var settings: ChatSettings            // chat settings for this conversation

    #if DEBUG
    static let sample: Conversation = {  // sample data for debug
        var conv = Conversation(title: "Algorithm", settings: ChatSettings(chatModel: .gpt35turbo))
        conv.append(chat: Chat(role: "user",
                               content: """
                               What is your favorite algorithm in computer science?
                               """,
                               usage: nil))
        conv.append(chat: Chat(role: "assistant",
                               content: """
                               As an AI language model, I do not have personal \
                               preferences or emotions to have a favorite algorithm. \
                               However, some popular and widely used algorithms in \
                               computer science include sorting algorithms like \
                               QuickSort and MergeSort, search algorithms like \
                               Binary Search, and graph algorithms like Dijkstra's \
                               algorithm and Bellman-Ford algorithm.
                               """,
                               usage: nil))
        return conv
    }()
    #endif

    // The first User's message (chat) or ""
    var firstUserContent: String {
        if let chat = chats.first(where: { $0.role == "user" }) {
            return chat.content  // the first User's message
        }
        return ""  // none
    }

    // Tokens - max of (prompt tokens + completion tokens)
    var allTokens: Int {
        (chats.map { ($0.usage?[0] ?? 0) + ($0.usage?[1] ?? 0) }).max() ?? 0
    }

    // Add a chat (message) of alternating user or assistant (AI)
    mutating func addChat() {
        let chat: Chat
        if let lastChat = chats.last {

            // Alternating user's or assistant's

            if lastChat.isUser {
                chat = Chat(role: OpenAIChatRole.assistant.rawValue,
                            content: "")
            } else {
                chat = Chat(role: OpenAIChatRole.user.rawValue,
                            content: "")
            }
        } else {

            // The first chat (message) is user's.

            chat = Chat(role: OpenAIChatRole.user.rawValue,
                            content: "")
        }
        chats.append(chat)      // add the chat (message) to this conversation
        lastUpdated = Date()    // update the date
    }

    // Add the chat (message) to this conversation
    mutating func append(chat: Chat) {
        chats.append(chat)      // add the chat (message) to this conversation
        lastUpdated = Date()    // update the date
    }

    @discardableResult
    mutating func updateID() -> UUID {
        id = UUID()
        return id
    }
}
