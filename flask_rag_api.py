# -*- coding: utf-8 -*-
"""
File: flask_rag_api.py
----------------------------------------
本文件基于 Flask 提供后端 REST API，以便前端聊天请求能够
调用 rag_langchain_chat.py 返回答案。支持多会话（conversation_id），
使每个会话拥有独立的对话上下文。
"""

import os
from flask import Flask, request, jsonify
from rag_system import RAGSystem
from rag_langchain_chat import (
    RAGLangChainChat,
    DEFAULT_DATA_DIR,
    DEFAULT_PERSIST_DIR,
)
# import jwt  # 仅作示例，如果要实现JWT请先 pip install pyjwt
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta

chat_sessions = {}

def get_or_create_chat_session(conversation_id: str) -> RAGLangChainChat:
    """
    根据 conversation_id 获取或创建一个 RAGLangChainChat 对象。
    每个会话拥有各自的对话上下文（memory）。
    """
    if conversation_id not in chat_sessions:
        chat_sessions[conversation_id] = RAGLangChainChat(
            data_dir=DEFAULT_DATA_DIR,
            persist_dir=DEFAULT_PERSIST_DIR,
            model_name="gpt-3.5-turbo",
            temperature=0.0
        )
    return chat_sessions[conversation_id]

app = Flask(__name__)

rag_system = RAGSystem(data_dir=DEFAULT_DATA_DIR, persist_dir=DEFAULT_PERSIST_DIR)

@app.route("/api/chat", methods=["POST"])
def api_chat():
    """
    接收聊天请求，JSON 参数示例:
      {
        "conversation_id": "abc123",
        "message": "请问CKD是什么？"
      }

    返回JSON:
      {
        "conversation_id": "abc123",
        "answer": "模型回答..."
      }
    """
    data = request.get_json(silent=True) or {}
    conversation_id = data.get("conversation_id")
    user_input = data.get("message")

    if not conversation_id:
        return jsonify({"error": "conversation_id is required"}), 400
    if not user_input:
        return jsonify({"error": "message is required"}), 400

    chat_bot = get_or_create_chat_session(conversation_id)

    try:
        answer = chat_bot.chat(user_input)
        return jsonify({
            "conversation_id": conversation_id,
            "answer": answer
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/retrieve', methods=['POST'])
def retrieve():
    """
    RAG检索接口
    POST请求，接收JSON数据，包含:
      - query: 查询语句 (必需)
      - similarity_top_k: 检索数量 (可选，默认5)
    """
    data = request.get_json()

    if 'query' not in data:
        return jsonify({'error': "'query' parameter is required."}), 400

    query = data['query']
    similarity_top_k = data.get('similarity_top_k', 5)

    try:
        result = rag_system.retrieve(query, similarity_top_k)
        return jsonify({'result': result}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

users_db = {}

@app.route('/api/auth/apple', methods=['POST'])
def auth_apple():
    """
    该接口处理 iOS 客户端传来的 Apple identityToken，用于验证并创建/获取用户信息。
    具体验证逻辑请根据 Apple 官方文档/需求实现。
    """
    try:
        data = request.get_json()
        identity_token = data.get("identity_token")
        user_identifier = data.get("user_identifier", "")

        if not identity_token:
            return jsonify({"error": "missing identity_token"}), 400

        if user_identifier in users_db:
            user_record = users_db[user_identifier]
        else:
            user_record = {
                "user_id": user_identifier,
                "created_at": str(datetime.now())
            }
            users_db[user_identifier] = user_record

        fake_token = f"fake-token-for-{user_identifier}-{int(datetime.now().timestamp())}"

        return jsonify({
            "success": True,
            "token": fake_token,
            "user": user_record
        }), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/auth/register', methods=['POST'])
def register():
    """
    使用用户名+密码的注册接口
    POST JSON 格式示例:
    {
        "username": "catlover",
        "password": "123456"
    }
    返回:
    {
        "success": true,
        "token": "fake-token-..."
    }
    """
    data = request.get_json() or {}
    username = data.get("username")
    password = data.get("password")
    if not username or not password:
        return jsonify({"error": "username and password are required"}), 400

    if username in users_db:
        return jsonify({"error": "username already exists"}), 400

    hashed_pwd = generate_password_hash(password, method='pbkdf2:sha256')

    users_db[username] = {
        "password": hashed_pwd,
        "created_at": str(datetime.now())
    }

    fake_token = f"userpass-{username}-{int(datetime.now().timestamp())}"
    return jsonify({
        "success": True,
        "token": fake_token,
        "user": {
            "user_id": username,
            "created_at": users_db[username]["created_at"]
        }
    }), 200

@app.route('/api/auth/login', methods=['POST'])
def login():
    """
    使用用户名+密码的登录接口
    POST JSON 格式示例:
    {
        "username": "catlover",
        "password": "123456"
    }
    返回:
    {
        "success": true,
        "token": "fake-token-..."
    }
    """
    data = request.get_json() or {}
    username = data.get("username")
    password = data.get("password")
    if not username or not password:
        return jsonify({"error": "username and password are required"}), 400

    user_record = users_db.get(username)
    if not user_record:
        return jsonify({"error": "user not found"}), 404

    if not check_password_hash(user_record["password"], password):
        return jsonify({"error": "incorrect password"}), 401

    fake_token = f"userpass-{username}-{int(datetime.now().timestamp())}"
    return jsonify({
        "success": True,
        "token": fake_token,
        "user": {
            "user_id": username,
            "created_at": user_record["created_at"]
        }
    }), 200

if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5005, debug=True)