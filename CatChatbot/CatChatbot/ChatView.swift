//
//  ChatView.swift
//  CatChatbot
//
//  Created by YourName on 3/3/25.
//
//  这是一个示例聊天界面，用于演示如何通过
//  Flask RAG 后端 /api/chat 接口进行对话。
//  请确保后端已运行，并将 baseURL 改为实际可访问地址。
//

import SwiftUI

enum MessageRole {
    case user
    case assistant
}

struct ChatMessage: Identifiable, Hashable {
    let id = UUID()
    let role: MessageRole
    let content: String
    let timestamp: Date = Date()
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var currentInput: String = ""
    @Published var isTyping: Bool = false

    private var conversationId: String = "k11Conversation_001"
    private let baseURL = Constants.baseURL

    init() {
        let welcomeMessage = ChatMessage(
            role: .assistant,
            content: Constants.welcomeText
        )
        messages.append(welcomeMessage)
    }

    func sendMessage() {
        guard !currentInput.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }

        let userMsg = ChatMessage(role: .user, content: currentInput)
        messages.append(userMsg)

        let requestBody: [String: Any] = [
            "conversation_id": conversationId,
            "message": currentInput
        ]

        currentInput = ""
        isTyping = true

        guard let url = URL(string: "\(baseURL)/api/chat") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("序列化 JSON 失败: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isTyping = false
            }

            if let error = error {
                print("请求出错: \(error)")
                return
            }

            guard let data = data else {
                print("无有效返回数据")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let answer = json["answer"] as? String {
                    DispatchQueue.main.async {
                        let assistantMsg = ChatMessage(role: .assistant, content: answer)
                        self?.messages.append(assistantMsg)
                    }
                } else if let jsonErr = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let errorMsg = jsonErr["error"] as? String {
                    DispatchQueue.main.async {
                        let assistantMsg = ChatMessage(role: .assistant,
                                                       content: "错误：\(errorMsg)")
                        self?.messages.append(assistantMsg)
                    }
                }
            } catch {
                print("JSON 解析错误: \(error)")
            }
        }.resume()
    }
}

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(Array(viewModel.messages.enumerated()), id: \.element.id) { index, msg in
                            if shouldShowTimeDivider(index) {
                                timeDivider(for: msg.timestamp)
                            }
                            messageView(msg)
                                .id(msg.id)
                        }

                        if viewModel.isTyping {
                            HStack {
                                messageBubble(content: "正在输入...", role: .assistant)
                                Spacer()
                            }
                            .padding(.leading, 10)
                            .id(UUID())
                        }
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 15)
                }
                .background(Color(.systemGray6))
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        scrollView.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
                .onChange(of: viewModel.isTyping) { _ in
                    withAnimation {
                        scrollView.scrollTo(viewModel.messages.last?.id, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack {
                TextField("请输入...", text: $viewModel.currentInput)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 1)

                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Text("发送")
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .disabled(viewModel.currentInput.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color(.systemGray6))
        }
        .navigationTitle(Constants.appDisplayName)
        .background(Color(.systemGray6))
    }

    private func messageView(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.role == .assistant {
                messageBubble(content: msg.content, role: .assistant)
                Spacer()
            } else {
                Spacer()
                messageBubble(content: msg.content, role: .user)
            }
        }
        .padding(.horizontal)
    }

    @ViewBuilder
    private func messageBubble(content: String, role: MessageRole) -> some View {
        let bgColor: Color = (role == .assistant) ? .white : .green
        let textColor: Color = (role == .assistant) ? .black : .white

        Text(content)
            .foregroundColor(textColor)
            .padding()
            .background(bgColor)
            .cornerRadius(10)
            .shadow(radius: 1)
    }

    private func shouldShowTimeDivider(_ index: Int) -> Bool {
        guard index > 0 else { return true }
        let prevMessage = viewModel.messages[index - 1]
        let currMessage = viewModel.messages[index]
        return currMessage.timestamp.timeIntervalSince(prevMessage.timestamp) > 60
    }

    private func timeDivider(for date: Date) -> some View {
        Text(formatDate(date))
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}