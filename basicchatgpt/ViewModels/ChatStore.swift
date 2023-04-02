//
//  ChatStore.swift
//  basicchatgpt
//
//  Created by Yasuhito Nagatomo on 2023/03/30.
//
import Foundation

// Chat Store

@MainActor
final class ChatStore: ObservableObject {
    @Published var conversations = [Conversation]()  // Conversations
    @Published var userSettings = UserSettings()     // User Settings

    private let chatManager = ChatManager()          // Chat Manager
    // The file path used to save conversations.
    private let savePath = URL.documentsDirectory.appending(path: AppConstant.conversationsSavePath)

    #if DEBUG
    static let sample = {  // Sample chat store for debug, which has a sample conversation.
        let chatStore = ChatStore()
        chatStore.conversations = [Conversation.sample]
        chatStore.userSettings.openAIAPIKey = "dummy"  // The API Key is dummy.
        return chatStore
    }()
    #endif

    init() { }

    // Setup the Chat Store data
    //
    // loads User Settings from UserDefaults
    // loads Conversations from a file
    func setup() {

        // User Settings

        if let data = UserDefaults.standard.data(forKey: AppConstant.userSettingsKey),
           let userSettings = try? JSONDecoder().decode(UserSettings.self, from: data) {
            self.userSettings = userSettings
        } else {
            // do nothing - no stored data
        }

        // Conversations

        if let data = try? Data(contentsOf: savePath),
           let decoded = try? JSONDecoder().decode([Conversation].self, from: data) {
            conversations = decoded
        } else {
            // do nothing - no saved data
        }
    }

    // Save the Chat Store data
    //
    // stores User Settings into UserDefaults
    // stores Conversations into a file
    func save() {

        // User Settings

        if let data = try? JSONEncoder().encode(userSettings) {
            UserDefaults.standard.set(data, forKey: AppConstant.userSettingsKey)
        } else {
            // do nothing - development time failure
            assertionFailure("failed to encode the user settings.")
        }

        // Conversations

        guard !conversations.isEmpty else { return }

        do {
            let data = try JSONEncoder().encode(conversations)
            try data.write(to: savePath)
        } catch {
            // do nothing - development time failure
            assertionFailure("failed to encode the conversations.")
        }
    }

    // Send the conversation of the ID to OpenAI server
    func sendConversation(of id: UUID) async {
        guard let index = conversationIndex(of: id),
              conversations[index].state == .idle else { return } // inhibit the duplication
        guard !userSettings.openAIAPIKey.isEmpty else { return }  // requires the API Key

        conversations[index].state = .asking

        let authToken = userSettings.openAIAPIKey
        let model = conversations[index].settings.chatModel.rawValue
        let messages = conversations[index].chats.map { (role: $0.role, content: $0.content) }
        let temperature = conversations[index].settings.temperature
        let topProbabilityMass = conversations[index].settings.topProbabilityMass
        let maxTokens = Int(conversations[index].settings.maxTokens)
        let presencePenalty = conversations[index].settings.presencePenalty
        let frequencyPenalty = conversations[index].settings.frequencyPenalty
        let response = await chatManager.sendConversation(
            authToken: authToken,
            model: model,
            messages: messages,
            temperature: temperature,
            topProbabilityMass: topProbabilityMass,
            maxTokens: maxTokens,
            presencePenalty: presencePenalty,
            frequencyPenalty: frequencyPenalty)

        // The conversation can be deleted or moved the index while awaiting.
        if let index2 = conversationIndex(of: id) {
            conversations[index2].state = .idle
            let chat = Chat(role: response.role,
                            content: response.content,
                            usage: [response.promptTokens, response.completionTokens])
            conversations[index2].append(chat: chat)
        } else {
            // do nothing - the conversation was deleted while awaiting
        }
    }

    // Return the conversation of the ID if exists
    func conversation(of id: UUID) -> Conversation? {
        conversations.first { $0.id == id }
    }

    // Return the index of a conversation of the ID if exists
    func conversationIndex(of id: UUID) -> Int? {
        conversations.firstIndex(where: { $0.id == id })
    }

    // Add a conversation
    @discardableResult
    func addNewConversation() -> UUID {
        // add one conversation to the list of conversations
        let conversation = Conversation(title: "A chat",                  // default title
            settings: ChatSettings(chatModel: userSettings.defaultModel)) // default settings
        conversations.insert(conversation, at: 0)

        // add one message (chat) to the new conversation as the initial value
        conversations[0].addChat()

        return conversation.id  // ID of the new conversation
    }

    // Duplicate the conversation
    @discardableResult
    func duplicateConversation(of conversationID: UUID) -> UUID? {

        // duplicate the conversation of the ID

        if var duplicated = conversation(of: conversationID) {
            let newID = duplicated.updateID()   // assign new ID
            duplicated.state = .idle            // don't duplicate state

            // insert it in the conversation list

            if let index = conversationIndex(of: conversationID) {
                conversations.insert(duplicated, at: index + 1)
                return newID
            } else {
                assertionFailure("Invalid conversation ID.")
                return nil
            }
        }
        assertionFailure("Invalid conversation ID.")
        return nil
    }

    // Add a message (chat) to the conversation of the index
    func addChat(for conversationIndex: Int) {
        conversations[conversationIndex].addChat()
    }
}
