//
//  Chat.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/04/01.
//

import Foundation

// Chat (Message) that makes up a conversation
//
// The usage (tokens) means all consumed tokens not only for the chat (message)
// but all conversation.

struct Chat: Identifiable, Codable {
    private(set) var id = UUID()    // chat ID
    let role: String                // role of the speaker : user of assistant
    var content: String             // message
    var usage: [Int]? // consumed tokens of the conversation : [promptTokens, completionTokens]

    // If the speaker of this chat is a user.
    var isUser: Bool {
        role == OpenAIChatRole.user.rawValue
    }

    // If the speaker of this chat is a assistant.
    var isAssistant: Bool {
        role == OpenAIChatRole.assistant.rawValue
    }
}
