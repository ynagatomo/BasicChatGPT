//
//  OpenAIChatConversation.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/03/30.
//

import Foundation

// OpenAI Chat API - Request message
// web: https://platform.openai.com/docs/api-reference/chat
// It is still beta. This might be changed.
// Please refer to the web for the detail.

// OpenAI Models - GPT-3.5 and GPT-4
// web: https://platform.openai.com/docs/models/overview
// They will be updated.
// swiftlint:disable identifier_name
enum OpenAIChatModel: String, CaseIterable, Codable {
    case gpt4 = "gpt-4"
    case gpt4_0314 = "gpt-4-0314"
    case gpt4_32k = "gpt-4-32k"
    case gpt4_32k0314 = "gpt-4-32k-0314"
    case gpt35turbo = "gpt-3.5-turbo"
    case gpt35turbo0301 = "gpt-3.5-turbo-0301"
}

// OpenAI Chat Role
enum OpenAIChatRole: String, Codable {
    case system
    case user
    case assistant

    static func from(string: String) -> Self {
        if string == Self.system.rawValue {
            return Self.system
        } else if string == Self.user.rawValue {
            return Self.user
        } else {
            return Self.assistant
        }
    }
}

// OpenAI Chat Message
struct OpenAIChatMessage: Codable {
    let role: OpenAIChatRole
    let content: String
}

// OpenAI Chat Conversation - request message
struct OpenAIChatConversation: Codable {

    // ID of the model to use.
    static let descriptionForModel = """
    GPT-4 is more capable than any GPT-3.5 model. \
    GPT-3.5-turbo is the most capable GPT-3.5 model and optimized \
    for chat at 1/10th the cost of GPT-3.
    """
    var model: String

    // The messages to generate chat completions for.
    var messages: [OpenAIChatMessage]

    // Optional, Defaults to 1
    // What sampling temperature to use, between 0 and 2.
    // Higher values like 0.8 will make the output more random,
    // while lower values like 0.2 will make it more focused and deterministic.
    // Generally recommended altering this or top_p but not both.
    static let temperatureMin: Double = 0.0
    static let temperatureDefault: Double = 1.0
    static let temperatureMax: Double = 2.0
    static let descriptionForTemperature = """
    Higher values like 0.8 will make the output more random, \
    while lower values like 0.2 will make it more focused and deterministic.
    """
    var temperature: Double?

    // top_p: Optional, Defaults to 1
    // An alternative to sampling with temperature, called nucleus sampling,
    // where the model considers the results of the tokens with top_p probability mass.
    // So 0.1 means only the tokens comprising the top 10% probability mass are considered.
    // Generally recommended altering this or temperature but not both.
    static let topProbabilityMassMin: Double = 0.0
    static let topProbabilityMassDefault: Double = 1.0
    static let topProbabilityMassMax: Double = 1.0
    static let descriptionForTopp = """
    The model considers the results of the tokens with top_p \
    probability mass. So 0.1 means only the tokens comprising \
    the top 10% probability mass are considered.
    """
    var topProbabilityMass: Double?

    // n: Optional, Defaults to 1
    // How many chat completion choices to generate for each input message.
    var choices: Int?

    // Optional, Defaults to false
    // If set, partial message deltas will be sent, like in ChatGPT.
    // Tokens will be sent as data-only server-sent events as they become available,
    // with the stream terminated by a data: [DONE] message.
    // See the OpenAI Cookbook for example code.
    var stream: Bool?

    // Optional, Defaults to null
    // Up to 4 sequences where the API will stop generating further tokens.
    var stop: [String]?

    // max_tokens: Optional, Defaults to inf
    // The maximum number of tokens to generate in the chat completion.
    // The total length of input tokens and generated tokens is limited
    // by the model's context length.
    // max: 2048 or 4000 depends on model
    static let maxTokensMax: Int = 2048
    static let descriptonForMattokens = """
    The maximum number of tokens to generate in the chat completion. \
    The total length of input tokens and generated tokens is limited \
    by the model's context length.
    """
    var maxTokens: Int?

    // presence_penalty: Optional, Defaults to 0
    // Number between -2.0 and 2.0. Positive values penalize new tokens
    // based on whether they appear in the text so far, increasing the
    // model's likelihood to talk about new topics.
    static let presencePenaltyMin: Double = -2.0
    static let presencePenaltyDefault: Double = 0.0
    static let presencePenaltyMax: Double = 2.0
    static let descriptionForPresencePenalty = """
    Positive values penalize new tokens based on whether they \
    appear in the text so far, increasing the model's likelihood \
    to talk about new topics.
    """
    var presencePenalty: Double?

    // frequency_penalty: Optional, Defaults to 0
    // Number between -2.0 and 2.0. Positive values penalize new tokens
    // based on their existing frequency in the text so far, decreasing
    // the model's likelihood to repeat the same line verbatim.
    static let frequencyPenaltyMin: Double = -2.0
    static let frequencyPenaltyDefault: Double = 0.0
    static let frequencyPenaltyMax: Double = 2.0
    static let descriptionForFrequencyPenalty = """
    Positive values penalize new tokens based on their existing \
    frequency in the text so far, decreasing the model's likelihood \
    to repeat the same line verbatim.
    """
    var frequencyPenalty: Double?

    // logit_bias: Optional, Defaults to null
    // Modify the likelihood of specified tokens appearing in the completion.
    // Accepts a json object that maps tokens (specified by their token ID in the tokenizer)
    // to an associated bias value from -100 to 100.
    // Mathematically, the bias is added to the logits generated by the model
    // prior to sampling. The exact effect will vary per model,
    // but values between -1 and 1 should decrease or increase likelihood of selection;
    // values like -100 or 100 should result in a ban or exclusive selection
    // of the relevant token.
    var logitBias: [Int: Double]?

    // Optional, A unique identifier representing your end-user,
    // which can help OpenAI to monitor and detect abuse.
    var user: String?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case topProbabilityMass = "top_p"
        case choices = "n"
        case stream
        case stop
        case maxTokens = "max_tokens"
        case presencePenalty = "presence_penalty"
        case frequencyPenalty = "frequency_penalty"
        case logitBias = "logit_bias"
        case user
    }
}
