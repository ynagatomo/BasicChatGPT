//
//  OpenAIMessage.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/03/30.
//

import Foundation

// OpenAI API Message - Response Message
// web: https://platform.openai.com/docs/api-reference/chat/create
// It is still beta. This might be changed.
struct OpenAIMessage: Codable {
    let id: String
    let object: String
    // let created: Int ... don't care
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage
}

// OpenAI Choice - Respnse
struct OpenAIChoice: Codable {
    let index: Int
    let message: OpenAIContent
    let finishReason: String

    enum CodingKeys: String, CodingKey {
        case index
        case message
        case finishReason = "finish_reason"
    }
}

// OpenAI Content - Response
struct OpenAIContent: Codable {
    let role: String
    let content: String
}

// OpenAI Usage - Response
struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// OpenAI Chat Error - Response
struct ChatError: Codable {
    public struct Payload: Codable {
        let message: String
        let type: String
        let param: String
        let code: String
    }

    public let error: Payload
}
