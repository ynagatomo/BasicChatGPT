//
//  ChatManager.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/03/29.
//

// Chat Manager - An adapter for OpenAI API modules

final class ChatManager {
    struct Response {
        let role: String            // role: user of assistant
        let content: String         // message
        let promptTokens: Int       // prompt tokens of the conversation (not the chat)
        let completionTokens: Int   // completion tokens of the conversation (not the chat)
    }

    private let openAIAPI = OpenAIChatAPI()     // OpenAI API module

    // Send a conversation to OpenAI server
    //
    // swiftlint:disable function_parameter_count
    func sendConversation(authToken: String,            // OpenAI API Key
                          model: String,                // GPT model name
                          messages: [(role: String, content: String)],  // messages
                          temperature: Double,          // temperature
                          topProbabilityMass: Double,   // top probability mass
                          maxTokens: Int,               // max tokens
                          presencePenalty: Double,      // presence penalty
                          frequencyPenalty: Double) async -> Response { // frequency penalty
        do {
            // Send the conversation (chats/messages)

            let chatMessages = messages.map {
                OpenAIChatMessage(role: OpenAIChatRole.from(string: $0.role),
                                  content: $0.content)
            }
            let result = try await openAIAPI.sendChat(authToken: authToken,
                                                      model: model,
                                                      messages: chatMessages,
                                                      temperature: temperature,
                                                      topProbabilityMass: topProbabilityMass,
                                                      maxTokens: maxTokens,
                                                      presencePenalty: presencePenalty,
                                                      frequencyPenalty: frequencyPenalty)

            // Return the response from OpenAI server

            let role = result.choices.first?.message.role ?? ""
            let content = result.choices.first?.message.content ?? ""
            let promptTokens = result.usage.promptTokens
            let completionTokens = result.usage.completionTokens

            return Response(role: role, content: content,
                            promptTokens: promptTokens, completionTokens: completionTokens)

        } catch OpenAIError.networkingError(let statusCode) {

            // Networking Error

            let role = OpenAIChatRole.system.rawValue
            let content = "HTTP Error: Status code = \(statusCode ?? -1)"
            return Response(role: role, content: content, promptTokens: 0, completionTokens: 0)
        } catch OpenAIError.decodingError {

            // Decoding Error

            let role = OpenAIChatRole.system.rawValue
            let content = "Error: Decoding error due to an invalid data."
            return Response(role: role, content: content, promptTokens: 0, completionTokens: 0)
        } catch OpenAIError.chatError(let error) {

            // Chat messaging Error

            let role = OpenAIChatRole.system.rawValue
            let content = error.message
            return Response(role: role, content: content, promptTokens: 0, completionTokens: 0)
        } catch {

            // Other Error

            let role = OpenAIChatRole.system.rawValue
            let content = error.localizedDescription
            return Response(role: role, content: content, promptTokens: 0, completionTokens: 0)
        }
    }
}
