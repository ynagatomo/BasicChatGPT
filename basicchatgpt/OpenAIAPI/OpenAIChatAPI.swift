//
//  OpenAIChatAPI.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/03/30.
//

import Foundation

// Error Definition - OpenAI Error

enum OpenAIError: Error {
    case networkingError(statusCode: Int?)      // networking error
    case decodingError                          // decoding error
    case chatError(error: ChatError.Payload)    // chat error
}

// OpenAI Chat API class

final class OpenAIChatAPI {
    private let session: URLSession

    init(session: URLSession = URLSession.shared) {
        self.session = session
    }
}

extension OpenAIChatAPI {

    // Send a conversation (chats/messages) to OpenAI server

    func sendChat(authToken: String,                 // OpenAI API Key
                  model: String,                     // GPT model name
                  messages: [OpenAIChatMessage],     // messages
                  temperature: Double? = nil,        // temperature
                  topProbabilityMass: Double? = nil, // top_p
                  choices: Int? = nil,               // choices
                  stream: Bool? = nil,               // stream
                  stop: [String]? = nil,             // stop
                  maxTokens: Int? = nil,             // max tokens
                  presencePenalty: Double? = nil,    // presence penalty
                  frequencyPenalty: Double? = nil,   // frequency penalty
                  logitBias: [Int: Double]? = nil,   // logit bias
                  user: String? = nil) async throws -> OpenAIMessage { // user

        // create the payload body

        let body = OpenAIChatConversation(model: model,
                                    messages: messages,
                                    temperature: temperature,
                                    topProbabilityMass: topProbabilityMass,
                                    choices: choices,
                                    stream: stream,
                                    stop: stop,
                                    maxTokens: maxTokens,
                                    presencePenalty: presencePenalty,
                                    frequencyPenalty: frequencyPenalty,
                                    logitBias: logitBias,
                                    user: user)

        // create the HTTPRequest

        let request = prepareRequest(authToken: authToken, body: body)

        // Send the payload to OpenAI Server

        let response: (data: Data, urlResponse: URLResponse)
        do {
            response = try await URLSession.shared.data(for: request)
        } catch {
            throw OpenAIError.networkingError(statusCode: nil)
        }

        // Check the HTTP status and return the response

        if let httpStatus = response.urlResponse as? HTTPURLResponse {
            switch httpStatus.statusCode {
            case 200..<400:
                do {
                    // decode the response

                    let decoded = try JSONDecoder().decode(OpenAIMessage.self, from: response.data)
                    return decoded      // return the response (OpenAIMessage)
                } catch {
                    /* do nothing for the next check */
                }

                do {
                    // try to decode the response as a ChatError payload

                    let chatError = try JSONDecoder().decode(ChatError.self,
                                                             from: response.data)
                    // Chat error
                    throw OpenAIError.chatError(error: chatError.error)
                } catch {
                    // Decoding error
                    throw OpenAIError.decodingError
                }
            case 400...:
                // Networking error
                throw OpenAIError.networkingError(statusCode: httpStatus.statusCode)
            default:
                // Networking error
                throw OpenAIError.networkingError(statusCode: httpStatus.statusCode)
            }
        } else {
            fatalError("Failed to cast the response to HTTPURLResponse.")
        }
    }

    // Make a URLRequest
    private func prepareRequest(authToken: String, body: OpenAIChatConversation) -> URLRequest {
        let url = URL(string: OpenAIEndpoint.baseURL + OpenAIEndpoint.path)!
        var request: URLRequest = URLRequest(url: url)

        request.httpMethod = OpenAIEndpoint.method
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "content-type")

        if let encoded = try? JSONEncoder().encode(body) {
            request.httpBody = encoded
        } else {
            assertionFailure("Failed to encode the body of chat conversation.")
        }

        return request
    }
}
