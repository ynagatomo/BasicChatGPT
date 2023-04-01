//
//  ChatSettings.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/04/01.
//

import Foundation

// Chat Settings
//
// Each conversation can have its own chat settings.

struct ChatSettings: Codable {

    // GPT Model

    var chatModel: OpenAIChatModel

    // Parameters

    var temperature: Double = OpenAIChatConversation.temperatureDefault
    var topProbabilityMass: Double = OpenAIChatConversation.topProbabilityMassDefault
    var maxTokens: Double = Double(AppConstant.maxTokenDefault)
    var presencePenalty: Double = OpenAIChatConversation.presencePenaltyDefault
    var frequencyPenalty: Double = OpenAIChatConversation.frequencyPenaltyDefault

    // System role

    var systemContent: String = AppConstant.systemRoleContentDefault
}
