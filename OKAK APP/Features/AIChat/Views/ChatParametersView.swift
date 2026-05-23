
import SwiftUI

struct ChatParametersView: View {
    let chat: ChatDTO
    var onSave: (UpdateChatParametersRequest) -> Void

    @State private var model: String
    @State private var reasoningLevel: String
    @State private var searchEnabled: Bool
    @State private var streamingEnabled: Bool
    @Environment(\.dismiss) private var dismiss

    init(chat: ChatDTO, onSave: @escaping (UpdateChatParametersRequest) -> Void) {
        self.chat = chat
        self.onSave = onSave
        _model = State(initialValue: OKAKModel.normalize(chat.model))
        _reasoningLevel = State(initialValue: chat.reasoningLevel)
        _searchEnabled = State(initialValue: chat.searchEnabled)
        _streamingEnabled = State(initialValue: chat.streamingEnabled)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Модель") {
                    Picker("Модель", selection: $model) {
                        ForEach(OKAKModel.all, id: \.id) { m in
                            Text(m.label).tag(m.id)
                        }
                    }
                }
                Section("Reasoning") {
                    Picker("Уровень", selection: $reasoningLevel) {
                        Text("Low").tag("low")
                        Text("Medium").tag("medium")
                        Text("High").tag("high")
                    }
                    .pickerStyle(.segmented)
                }
                Section {
                    Toggle("Web search", isOn: $searchEnabled)
                    Toggle("Streaming", isOn: $streamingEnabled)
                }
            }
            .navigationTitle("Параметры чата")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Сохранить") {
                        onSave(UpdateChatParametersRequest(
                            model: model,
                            reasoningLevel: reasoningLevel,
                            searchEnabled: searchEnabled,
                            streamingEnabled: streamingEnabled
                        ))
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Отмена") { dismiss() }
                }
            }
        }
    }
}
