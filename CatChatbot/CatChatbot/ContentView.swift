//
//  ContentView.swift
//  CatChatbot
//
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                NavigationLink(destination: ChatView()) {
                    Text("进入 \(Constants.appDisplayName)")
                        .padding()
                }
            }
            .padding()
            .navigationTitle("首页")
        }
    }
}

#Preview {
    ContentView()
}