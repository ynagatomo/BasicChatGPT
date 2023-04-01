//
//  ChatSettingsView.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/04/01.
//

import SwiftUI

// Chat Settings view
//
// Each conversation (chat) can have own settings of
// - GPT model
// - Parameters such as temperature, max tokens, top_p, etc
// - System role such as "You are the best smartest assistant."

struct ChatSettingsView: View {
    @Binding var chatSettings: ChatSettings
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Spacer()

                // Title

                Text("Chat Settings")
                    .padding()

                Spacer()

                // Button to dismiss

                Button(action: dismiss.callAsFunction,
                    label: {
                        Text("DONE")
                        .padding(.horizontal)
                })
            }

            Form {
                Group {

                    // GPT Model

                    Picker("GPT Model", selection: $chatSettings.chatModel) {
                        ForEach(OpenAIChatModel.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    Text(OpenAIChatConversation.descriptionForModel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .listRowSeparator(.hidden)

                Section("Parameters") {
                    Group {

                        // Temperature

                        LabeledContent("Temperature " + String(format: "%.1f", chatSettings.temperature)) {
                            Slider(value: $chatSettings.temperature,
                                   in: OpenAIChatConversation.temperatureMin
                                   ... OpenAIChatConversation.temperatureMax,
                                   step: 0.1)
                        }
                        Text(OpenAIChatConversation.descriptionForTemperature)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .listRowSeparator(.hidden)

                    Group {

                        // Max tokens

                        LabeledContent("Max tokens " + String(format: "%.0f", chatSettings.maxTokens)) {
                            Slider(value: $chatSettings.maxTokens,
                                   in: 1.0...Double(OpenAIChatConversation.maxTokensMax),
                                   step: 1)
                        }
                        Text(OpenAIChatConversation.descriptonForMattokens)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .listRowSeparator(.hidden)

                    Group {

                        // Top probability mass

                        LabeledContent("Top P " + String(format: "%.2f", chatSettings.topProbabilityMass)) {
                            Slider(value: $chatSettings.topProbabilityMass,
                                   in: OpenAIChatConversation.topProbabilityMassMin
                                   ... OpenAIChatConversation.topProbabilityMassMax,
                                   step: 0.01)
                        }
                        Text(OpenAIChatConversation.descriptionForTopp)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .listRowSeparator(.hidden)

                    Group {

                        // Frequency penalty

                        LabeledContent("Frequency penalty " + String(format: "%.2f", chatSettings.frequencyPenalty)) {
                            Slider(value: $chatSettings.frequencyPenalty,
                                   in: OpenAIChatConversation.frequencyPenaltyMin
                                   ... OpenAIChatConversation.frequencyPenaltyMax,
                                   step: 0.01)
                        }
                        Text(OpenAIChatConversation.descriptionForFrequencyPenalty)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .listRowSeparator(.hidden)

                    Group {

                        // Presence penalty

                        LabeledContent("Presence penalty " + String(format: "%.2f", chatSettings.presencePenalty)) {
                            Slider(value: $chatSettings.presencePenalty,
                                   in: OpenAIChatConversation.presencePenaltyMin
                                   ... OpenAIChatConversation.presencePenaltyMax,
                                   step: 0.01)
                        }
                        Text(OpenAIChatConversation.descriptionForPresencePenalty)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .listRowSeparator(.hidden)
                }

                Section("System Role") {
                    Group {

                        // System role

                        LabeledContent("System role") {
                            TextField("system role", text: $chatSettings.systemContent,
                                      axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                        }
                        .textSelection(.enabled)

                        Text("Specify the AI's role for this chat.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .listRowSeparator(.hidden)
                }
            }
        }
    }
}

struct ChatSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        ChatSettingsView(chatSettings: .constant(ChatSettings(chatModel: .gpt35turbo)))
    }
}
