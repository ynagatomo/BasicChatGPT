//
//  UserSettingsView.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/04/01.
//

import SwiftUI

// User Settings view for app wide settings

struct UserSettingsView: View {
    @Binding var userSettings: UserSettings
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack {
            HStack {
                Spacer()

                // View Title

                Text("User Settings")
                    .padding()

                Spacer()

                // Button to dismiss

                Button(action: dismiss.callAsFunction,
                       label: {
                    Text("DONE")
                }).padding(.horizontal)
            }

            Form {
                Section("OpenAI") {
                    Group {

                        // OpenAI API Key

                        LabeledContent("OpenAI API Key") {
                            SecureField("enter your OpenAI API Key",
                                        text: $userSettings.openAIAPIKey)
                            .textFieldStyle(.roundedBorder)
                        }
                        .listRowSeparator(.hidden)

                        Text("""
                        OpenAI API Key is required to use the GPT APIs. \
                        Get it at OpenAI Webpage and put it here.
                        """)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Group {

                        // Default GPT Model, which is used for each chat as a default model

                        Picker("Default GPT Model", selection: $userSettings.defaultModel) {
                            ForEach(OpenAIChatModel.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .listRowSeparator(.hidden)

                        Text("""
                        Select the default GPT model. \
                        You can change it for each chat in the Chat Settings.
                        """)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

        }
    }
}

struct UserSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        UserSettingsView(userSettings: .constant(UserSettings()))
    }
}
