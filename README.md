# Flask RAG API 接口文档

本API基于 Flask 提供，后端使用 RAG（检索增强生成）技术，实现基于 **K-11 教育领域** 知识的智能问答。

---

## 💡 项目简介

项目是基于 LlamaIndex 和 LangChain 构建的 RAG 应用，专为 **K-11教育领域** 设计。它能够对存放于 `edu_docs/` 文件夹中的学科资料（如PDF、TXT等教材、教辅文档）进行检索，并通过外部知识增强大模型（如OpenAI GPT系列）生成针对学生问题的精准回答和辅导。

**主要技术栈**：

- RAG实现: `LlamaIndex`、`LangChain`
- 后端框架: `Flask`
- 前端框架: `Vue` + `ElementUI Pro` (示例，本项目API文档主要关注后端)

---

## 🌲 项目结构说明

```
.
├── flask_rag_api.py          # Flask 后端 API 主程序
├── rag_system.py             # RAG 核心实现逻辑
├── rag_langchain_chat.py     # LangChain 对话功能集成
├── edu_docs                  # 存放用于构建K-11教育知识库的文档数据 (例如：教材PDF)
└── vector_k11                # 向量索引持久化存储路径
```
*Note: `edu_docs` and `vector_k11` are the default directories used by the RAG system.*

---

## 🚀 环境依赖及启动方式

### 安装依赖

```bash
pip install flask llama-index langchain openai werkzeug
# 如果使用 .env 文件管理 OpenAI API Key，还需安装 python-dotenv
pip install python-dotenv
```

### 启动服务（开发模式）

```bash
python flask_rag_api.py
```

默认启动地址为：

```
http://127.0.0.1:5005
```

---

## 📖 接口详细说明

本项目当前提供以下核心接口：

| 功能                   | 接口路径             | 方法  | 描述                                       |
|-----------------------|---------------------|------|--------------------------------------------|
| 检索增强问答（多轮） | `/api/chat`         | POST | 基于会话的智能问答，支持多轮对话         |
| RAG文档检索接口       | `/retrieve`         | POST | 根据查询语句检索相关文档片段             |
| 用户名密码注册        | `/api/auth/register`| POST | 用户使用用户名和密码进行注册             |
| 用户名密码登录        | `/api/auth/login`   | POST | 用户使用用户名和密码进行登录             |
| Apple登录认证        | `/api/auth/apple`   | POST | （示例）处理Apple Sign-In的身份验证回调 |

---

### 📌 接口一：检索增强多轮对话 (`/api/chat`)

**接口描述**：

基于会话的智能问答接口，支持多轮对话，自动管理上下文。主要用于K-11学生的学习提问。

**请求方式**：

```http
POST /api/chat
Content-Type: application/json
```

**请求参数**：

| 参数              | 类型     | 必须 | 说明                 | 示例                                  |
|------------------|----------|------|----------------------|---------------------------------------|
| conversation_id  | string   | 是   | 会话唯一标识，用于维持对话上下文 | `"student_session_001"`                 |
| message          | string   | 是   | 用户当前轮次提问内容 | `"什么是牛顿第一定律？"`                  |

**请求示例**：

```json
{
    "conversation_id": "student_session_001",
    "message": "请解释一下什么是光合作用。"
}
```

**返回数据**：

| 参数             | 类型     | 说明                   |
|-----------------|----------|------------------------|
| conversation_id | string   | 返回的会话标识，与请求一致 |
| answer          | string   | 模型生成的回答内容       |

**成功响应示例**：

```json
{
    "conversation_id": "student_session_001",
    "answer": "光合作用是植物、藻类和某些细菌利用光能，将二氧化碳和水转化为富能有机物（如葡萄糖），并释放氧气的过程。这个过程主要发生在植物叶片的叶绿体中。"
}
```

**异常响应示例**：

缺少参数时：

```json
{
    "error": "conversation_id is required"
}
```

---

### 📌 接口二：文档内容检索 (`/retrieve`)

**接口描述**：

根据用户输入的查询语句，使用RAG系统从K-11教育知识库中检索出最相关的文档内容片段。

**请求方式**：

```http
POST /retrieve
Content-Type: application/json
```

**请求参数**：

| 参数              | 类型     | 必须 | 说明                      | 示例                                                  |
|------------------|----------|------|---------------------------|-------------------------------------------------------|
| query            | string   | 是   | 用户待检索的查询语句       | `"初中物理的力学主要有哪些知识点？"`                         |
| similarity_top_k | int      | 否   | 返回最相关的结果数量（默认5） | `3`                                                   |

**请求示例**：

```json
{
    "query": "高中语文必修上册中《沁园春·长沙》的写作背景是什么？",
    "similarity_top_k": 2
}
```

**返回数据**：

| 参数    | 类型   | 说明                                   |
|--------|--------|----------------------------------------|
| result | string | 检索到的最相关文档片段（带分数） |

**成功响应示例**：

```json
{
    "result": "---------------------------------------------\nScore: 0.895\n《沁园春·长沙》是毛泽东于1925年晚秋，离开故乡韶山，去广州主持农民运动讲习所，途经长沙，重游橘子洲，感慨万千，用一阕词抒写了他当时对中华民族前途的乐观主义精神和以天下为己任的革命抱负。\n---------------------------------------------\n\n---------------------------------------------\nScore: 0.870\n写作背景：1925年，中国革命形势高涨。......毛泽东在长沙停留，重游橘子洲头，面对湘江秋景，回顾往昔，展望未来，写下了这首词。\n---------------------------------------------"
}
```

**异常响应示例**：

缺少参数时：

```json
{
    "error": "'query' parameter is required."
}
```

---

### 📌 接口三：用户名密码注册 (`/api/auth/register`)

**接口描述**：
允许用户通过提供用户名和密码来注册新账户。

**请求方式**：
```http
POST /api/auth/register
Content-Type: application/json
```

**请求参数**：
| 参数     | 类型   | 必须 | 说明     | 示例         |
|----------|--------|------|----------|--------------|
| username | string | 是   | 用户名   | `"student01"` |
| password | string | 是   | 密码     | `"pass123!"`  |

**请求示例**：
```json
{
    "username": "student01",
    "password": "securePassword123"
}
```

**成功响应示例**：
```json
{
    "success": true,
    "token": "userpass-student01-1678886400",
    "user": {
        "user_id": "student01",
        "created_at": "YYYY-MM-DD HH:MM:SS.ffffff"
    }
}
```
**异常响应示例** (用户名已存在):
```json
{
    "error": "username already exists"
}
```
**异常响应示例** (缺少参数):
```json
{
    "error": "username and password are required"
}
```

---

### 📌 接口四：用户名密码登录 (`/api/auth/login`)

**接口描述**：
允许已注册用户通过用户名和密码登录。

**请求方式**：
```http
POST /api/auth/login
Content-Type: application/json
```

**请求参数**：
| 参数     | 类型   | 必须 | 说明     | 示例         |
|----------|--------|------|----------|--------------|
| username | string | 是   | 用户名   | `"student01"` |
| password | string | 是   | 密码     | `"pass123!"`  |

**请求示例**：
```json
{
    "username": "student01",
    "password": "securePassword123"
}
```

**成功响应示例**：
```json
{
    "success": true,
    "token": "userpass-student01-1678886401",
    "user": {
        "user_id": "student01",
        "created_at": "YYYY-MM-DD HH:MM:SS.ffffff"
    }
}
```
**异常响应示例** (用户不存在或密码错误):
```json
{
    "error": "user not found" 
}
```
```json
{
    "error": "incorrect password"
}
```

---

### 📌 接口五：Apple 登录认证 (`/api/auth/apple`)

**接口描述**：
（此为后端示例接口）处理来自 iOS 客户端通过 "Sign in with Apple" 方式登录时发送的 `identityToken`。后端应对此 `identityToken` 进行验证（例如与 Apple 服务器校验），并基于验证结果创建或获取用户信息，返回一个会话 token。

**请求方式**：
```http
POST /api/auth/apple
Content-Type: application/json
```

**请求参数**：
| 参数            | 类型   | 必须 | 说明                               | 示例 (Token是编造的)                                      |
|-----------------|--------|------|------------------------------------|---------------------------------------------------------|
| identity_token  | string | 是   | Apple提供的身份令牌                  | `"eyJraWQiOiJBSURPUEsxIiwiYWxnIjoiUlMyNTYifQ..."`         |
| user_identifier | string | 否   | Apple提供的用户唯一标识 (可选传入) | `"001234.abc123def456ghi789.0123"`                      |

**请求示例**：
```json
{
    "identity_token": "eyJraWQiOiJBSURPUEsxIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLnlvdXItYXBwLWJ1bmRsZS1pZCIsImV4cCI6MTY3ODg4NjQwMCwiaWF0IjoxNjc4ODg2MzQwLCJzdWIiOiIwMDEyMzQuYWJjMTIzZGVmNDU2Z2hpNzg5LjAxMjMiLCJjX2hhc2giOiJLWU..." ,
    "user_identifier": "001234.abc123def456ghi789.0123"
}
```
**成功响应示例** (后端成功验证并签发会话token):
```json
{
    "success": true,
    "token": "fake-token-for-001234.abc123def456ghi789.0123-1678886400",
    "user": {
        "user_id": "001234.abc123def456ghi789.0123",
        "created_at": "YYYY-MM-DD HH:MM:SS.ffffff"
    }
}
```
**异常响应示例** (缺少 `identity_token`):
```json
{
    "error": "missing identity_token"
}
```
*注意: 真实的Apple Token验证会更复杂，可能涉及公钥获取和JWT解码验证等步骤。此处的后端实现为简化版，仅作演示。*

---

## 🛠️ 接口测试说明

项目提供了单元测试文件，方便接口快速自测：

**测试文件路径**：  
```
test_flask_rag_api.py
```

运行测试：

```bash
python test_flask_rag_api.py
```
测试用例中也包含了针对K-11教育领域问题的示例。

---

## 🔑 OpenAI API Key 配置说明

项目使用OpenAI模型，需要设置环境变量：

```bash
export OPENAI_API_KEY="你的真实OpenAI_API_KEY"
```

或者在项目根目录创建`.env`文件（需要 `python-dotenv`库）：

```dotenv
OPENAI_API_KEY=你的真实OpenAI_API_KEY
```

---

## 📚 推荐开发流程

1.  安装依赖。
2.  配置OpenAI API Key环境变量或`.env`文件。
3.  准备K-11教育相关的教材、教辅等数据文件到 `edu_docs/` 文件夹。
4.  首次运行API会自动扫描 `edu_docs/` 目录并构建向量索引，存储于 `vector_k11/`。后续启动会直接加载已有索引。
5.  后端开发调试阶段使用Postman、Insomnia等工具或 `test_flask_rag_api.py` 测试接口。
6.  前端（如Vue应用）通过HTTP请求调用后端API，实现用户交互界面。
7.  后端功能迭代后，更新或添加单元测试用例，确保功能无误。

---

🚩 **注意事项**：

-   初次运行时由于文档量较大，构建索引可能需要较长时间，请耐心等待。
-   后续在 `edu_docs/` 目录中新增或修改文档后，通常需要手动删除持久化文件夹（如 `vector_k11`）中的旧索引并重启API服务，以便重新生成包含最新内容的索引。
-   推荐使用Docker或虚拟环境（如venv, conda）进行开发和部署，以简化环境管理和依赖隔离。

---

以上为本项目API的详细文档，后续新增功能或接口时请及时更新此文档，以确保团队高效协作开发。