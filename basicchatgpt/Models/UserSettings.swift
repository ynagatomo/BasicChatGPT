//
//  UserSettings.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/04/01.
//

import Foundation

// User Settings
//
// The app has one user settings. All conversations shares it.

struct UserSettings: Codable {

    // OpenAI API Key - It is required to use OpenAI API.

    var openAIAPIKey: String = ""

    // Default GPT model - It is used as a default model for chat settings.

    var defaultModel = OpenAIChatModel.gpt35turbo
}
