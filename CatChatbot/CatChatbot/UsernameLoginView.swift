import SwiftUI

class UsernameAuthViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var authToken: String? = nil
    
    private let baseURL = Constants.baseURL
    
    func register(
        username: String,
        password: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/auth/register") else {
            completion(false, "无法构造注册URL，请检查baseURL配置")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(false, "JSON序列化失败: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(false, "注册请求错误: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                completion(false, "未收到有效返回数据")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = json["success"] as? Bool, success == true {
                        let token = json["token"] as? String
                        DispatchQueue.main.async {
                            self?.isLoggedIn = true
                            self?.authToken = token
                            completion(true, nil)
                        }
                    } else {
                        let errorMsg = json["error"] as? String ?? "未知错误"
                        completion(false, errorMsg)
                    }
                } else {
                    completion(false, "JSON 解析失败，格式不正确")
                }
            } catch {
                completion(false, "JSON解析失败: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func login(
        username: String,
        password: String,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/api/auth/login") else {
            completion(false, "无法构造登录URL，请检查baseURL配置")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "password": password
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion(false, "JSON序列化失败: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(false, "登录请求错误: \(error.localizedDescription)")
                return
            }
            guard let data = data else {
                completion(false, "未收到有效返回数据")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let success = json["success"] as? Bool, success == true {
                        let token = json["token"] as? String
                        DispatchQueue.main.async {
                            self?.isLoggedIn = true
                            self?.authToken = token
                            completion(true, nil)
                        }
                    } else {
                        let errorMsg = json["error"] as? String ?? "未知错误"
                        completion(false, errorMsg)
                    }
                } else {
                    completion(false, "JSON 解析失败，格式不正确")
                }
            } catch {
                completion(false, "JSON解析失败: \(error.localizedDescription)")
            }
        }.resume()
    }
}

struct UsernameLoginView: View {
    @StateObject private var authViewModel = UsernameAuthViewModel()
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showRegister: Bool = false
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var pendingAction: (() -> Void)?
    
    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                ChatView()
            } else {
                VStack(spacing: 20) {
                    Text(showRegister ? "注册 K-11 账号" : "K-11 学习助手登录")
                        .font(.headline)
                    
                    TextField("用户名", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                    
                    SecureField("密码", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        if showRegister {
                            authViewModel.register(username: username,
                                                   password: password) { success, errorMsg in
                                if success {
                                    self.alertTitle = "注册成功"
                                    self.alertMessage = "恭喜您注册成功，欢迎使用\(Constants.appDisplayName)"
                                    self.pendingAction = {
                                        self.authViewModel.isLoggedIn = true
                                    }
                                    self.showAlert = true
                                } else {
                                    self.alertTitle = "注册失败"
                                    self.alertMessage = errorMsg ?? "未知错误"
                                    self.pendingAction = nil
                                    self.showAlert = true
                                }
                            }
                            
                        } else {
                            authViewModel.login(username: username,
                                                password: password) { success, errorMsg in
                                if success {
                                    self.alertTitle = "登录成功"
                                    self.alertMessage = "欢迎回来！"
                                    self.pendingAction = {
                                        self.authViewModel.isLoggedIn = true
                                    }
                                    self.showAlert = true
                                } else {
                                    self.alertTitle = "登录失败"
                                    self.alertMessage = errorMsg ?? "未知错误"
                                    self.pendingAction = nil
                                    self.showAlert = true
                                }
                            }
                        }
                    }) {
                        Text(showRegister ? "注册" : "登录")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        showRegister.toggle()
                    }) {
                        Text(showRegister ? "已有账号？去登录" : "没有账号？去注册")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if let action = pendingAction {
                        action()
                    }
                }
            )
        }
    }
}

struct UsernameLoginView_Previews: PreviewProvider {
    static var previews: some View {
        UsernameLoginView()
    }
}