//
//  SignInWithAppleView.swift
//  CatChatbot
//
//  Created by YourName on 3/3/25.
//
//  该视图用于演示如何使用 Sign in with Apple 进行注册/登录
//  登录成功后，将切换到聊天界面 ChatView
//

import SwiftUI
import AuthenticationServices

class UserAuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var authToken: String? = nil
    private let baseURL = Constants.baseURL

    func authenticateWithServer(identityToken: String,
                                userIdentifier: String?,
                                completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/auth/apple") else {
            print("URL 构造失败")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "identity_token": identityToken,
            "user_identifier": userIdentifier ?? ""
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("JSON 序列化失败: \(error)")
            completion(false)
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("请求错误: \(error)")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            guard let data = data else {
                print("未收到有效返回数据")
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = json["success"] as? Bool, success == true {
                        let token = json["token"] as? String
                        
                        DispatchQueue.main.async {
                            self?.authToken = token
                            self?.isLoggedIn = true
                            completion(true)
                        }
                    } else {
                        let errorMsg = json["error"] as? String
                        print("后端错误: \(errorMsg ?? "未知错误")")
                        DispatchQueue.main.async { completion(false) }
                    }
                } else {
                    print("JSON 解析失败")
                    DispatchQueue.main.async { completion(false) }
                }
            } catch {
                print("JSON 解析错误: \(error)")
                DispatchQueue.main.async { completion(false) }
            }
        }.resume()
    }
}

struct SignInWithAppleView: View {
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var authViewModel = UserAuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                ChatView()
            } else {
                VStack(spacing: 20) {
                    Text("欢迎使用 \(Constants.appDisplayName)，请先使用 Apple 登录")
                        .padding()
                    
                    SignInWithAppleButton(.signIn,
                                          onRequest: configureRequest,
                                          onCompletion: handleCompletion)
                    .signInWithAppleButtonStyle(
                        colorScheme == .dark ? .white : .black
                    )
                    .frame(height: 50)
                    .padding(.horizontal, 40)
                }
            }
        }
    }
    
    private func configureRequest(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
    }
    
    private func handleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResults):
            if let credential = authResults.credential as? ASAuthorizationAppleIDCredential {
                guard let identityTokenData = credential.identityToken,
                      let identityTokenString = String(data: identityTokenData, encoding: .utf8)
                else {
                    print("无法解析 identityToken")
                    return
                }
                
                let userID = credential.user

                authViewModel.authenticateWithServer(
                    identityToken: identityTokenString,
                    userIdentifier: userID) { success in
                        if success {
                            print("Apple 登录成功，后端验证通过")
                        } else {
                            print("Apple 登录成功，但后端验证失败")
                        }
                }
            }
        case .failure(let error):
            print("Apple 授权失败: \(error.localizedDescription)")
        }
    }
}

struct SignInWithAppleView_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithAppleView()
    }
}