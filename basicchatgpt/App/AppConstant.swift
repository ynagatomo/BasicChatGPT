//
//  AppConstant.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/03/31.
//

import Foundation

// Definition of app wide constants
enum AppConstant {
    // OpenAI API - maxToken default value <= 2048 or 4000
    static let maxTokenDefault = 600

    // Default system role content
    static let systemRoleContentDefault = "You are an AI assistant."

    // Path in the document directory where the chat conversations are saved.
    static let conversationsSavePath = "conversationsStore"

    // Key for storing the User Settings data into UserDefaults
    static let userSettingsKey = "user_settings_key"
}
