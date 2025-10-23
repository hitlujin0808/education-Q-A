# Flask RAG API Interface Documentation

This API is delivered via Flask, with the backend employing RAG (Retrieval-Augmented Generation) technology to deliver intelligent question-answering based on knowledge within the **K-11 education sector**.

---

## 💡 Project Summary

This project is a RAG application built upon LlamaIndex and LangChain, specifically designed for the **K-11 education sector**. It retrieves subject-specific materials (such as PDFs, TXT files, textbooks, and supplementary teaching documents) stored within the `edu_docs/` folder, and generates precise answers and guidance for student queries through external knowledge-enhanced large language models (such as the OpenAI GPT series).

**Primary Technology Stack**：

- RAG implementation: `LlamaIndex`、`LangChain`
- Backend framework: `Flask`
- Front-end framework: `Vue` + `ElementUI Pro` (Example: This project's API documentation primarily focuses on the backend.)

---

## 🌲 Project Structure Description

```
.
├── flask_rag_api.py          # Flask Backend API Main Programme
├── rag_system.py             # RAG Core Implementation Logic
├── rag_langchain_chat.py     # LangChain Conversation Function Integration
├── edu_docs                  # Store document data used to build the K-11 educational knowledge base (e.g., teaching materials in PDF format)
└── vector_k11                # Vector Index Persistent Storage Path
```
*Note: `edu_docs` and `vector_k11` are the default directories used by the RAG system.*

---

## 🚀 Environment dependencies and startup methods

### Install dependencies

```bash
pip install flask llama-index langchain openai werkzeug
# If using a .env file to manage your OpenAI API Key, you will also need to install python-dotenv.
pip install python-dotenv
```

### Start Service (Development Mode)

```bash
python flask_rag_api.py
```

The default launch address is

```
http://127.0.0.1:5005
```

---

## 📖 Interface Specification

This project currently provides the following core interfaces

| Function                                           | Interface Path      | Method| Description                                                                               |
|----------------------------------------------------|---------------------|-------|-------------------------------------------------------------------------------------------|
| Retrieval-Enhanced Question-Answering (Multi-Turn) | `/api/chat`         | POST  | Conversation-based intelligent question-answering, supporting multi-turn dialogue         |
| RAG Document Retrieval Interface                   | `/retrieve`         | POST  | Retrieve relevant document fragments based on the query statement                         |
| Username Password Register                         | `/api/auth/register`| POST  | Users register using their username and password                                          |
| Username and Password Login                        | `/api/auth/login`   | POST  | Users log in using their username and password                                            |
| Apple Sign-In Authentication                       | `/api/auth/apple`   | POST  | (Example) Handling Apple Sign-In authentication callbacks                                 |

---

### 📌 Interface One: Retrieval-Enhanced Multi-Turn Dialogue (`/api/chat`)

**Interface Description**：

A conversation-based intelligent question-answering interface supporting multi-turn dialogue with automatic context management. Primarily designed for academic enquiries by pupils in K-11。

**Request method**：

```http
POST /api/chat
Content-Type: application/json
```

**Request parameters**：

| Parameters       | Type     | Must | Note                 |Example                                  |
|------------------|----------|------|----------------------|---------------------------------------|
| conversation_id  | string   | yes  | Session identifier, used to maintain dialogue context | `"student_session_001"`                 |
| message          | string   | yes  | User's current round query | `"What is Newton's First Law?"`                  |

**Request example**：

```json
{
    "conversation_id": "student_session_001",
    "message": "Please explain what photosynthesis is."
}
```

**Return data**：

| Parameters      | Type     | Note                   |
|-----------------|----------|------------------------|
| conversation_id | string   | The returned session identifier matches the request |
| answer          | string   | Model-generated response conten       |

**Example of Successful Response**：

```json
{
    "conversation_id": "student_session_001",
    "answer": "Photosynthesis is the process by which plants, algae, and certain bacteria utilise light energy to convert carbon dioxide and water into energy-rich organic compounds (such as glucose), whilst releasing oxygen. This process primarily occurs within the chloroplasts of plant leaves."
}
```

**Example of an abnormal response**：

In the absence of parameters：

```json
{
    "error": "conversation_id is required"
}
```

---

### 📌 Interface 2: Document Content Retrieval (`/retrieve`)

**Interface Description**：

Based on the query entered by the user, the RAG system retrieves the most relevant document content snippets from the K-11 educational knowledge base.

**Request method**：

```http
POST /retrieve
Content-Type: application/json
```

**Request parameters**：

|  Parameters      |  Type    | Must | Note                      | Example                                                  |
|------------------|----------|------|---------------------------|-------------------------------------------------------|
| query            | string   | yes  | User query to be retrieved       | `"What are the main topics covered in mechanics within the junior secondary physics curriculum?"` |
| similarity_top_k | int      | no   | Number of most relevant results returned (default: 5) | `3`                                                   |

**Request example**：

```json
{
    "query": "What is the background to the composition of “Qin Yuan Chun: Changsha” in the Compulsory Chinese Language Textbook for Senior Secondary School, Volume 1?",
    "similarity_top_k": 2
}
```

**Return data**：

| Parameters     | Type   | Note                                   |
|--------|--------|----------------------------------------|
| result | string | The most relevant document fragments retrieved (with scores) |

**Successful Response Example**：

```json
{
    "result": "---------------------------------------------\nScore: 0.895\nQin Yuan Chun: Changsha In late autumn of 1925, Mao Zedong departed his native Shaoshan for Guangzhou to preside over the Peasants' Movement Institute. Passing through Changsha, he revisited Orange Isle, where profound emotion welled within him. Through this verse, he expressed his optimistic outlook on the future of the Chinese nation and his revolutionary aspiration to shoulder the destiny of the world.\n---------------------------------------------\n\n---------------------------------------------\nScore: 0.870\nWriting Background: In 1925, the revolutionary tide in China was surging high. ... Mao Zedong paused his journey in Changsha, revisited Orange Isle, and facing the autumn scenery of the Xiang River, he reflected on the past and contemplated the future, composing this poem.\n---------------------------------------------"
}
```

**Example of an abnormal response**：

When parameters are missing：

```json
{
    "error": "'query' parameter is required."
}
```

---

### 📌 Interface Three: Username and Password Registration (`/api/auth/register`)

**Interface Description**：
Allow users to register new accounts by providing a username and password.

**Request method**：
```http
POST /api/auth/register
Content-Type: application/json
```

**Request parameters**：
| Parameters     | Type   | Must | Note     | Example         |
|----------|--------|------|----------|--------------|
| username | string | yes  | Username   | `"student01"` |
| password | string | yes  | Password     | `"pass123!"`  |

**Request example**：
```json
{
    "username": "student01",
    "password": "securePassword123"
}
```

**Successful Response Example**：
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
**Anomaly Response Examples** (Username already exists):
```json
{
    "error": "username already exists"
}
```
**Example of an abnormal response** (Missing parameters):
```json
{
    "error": "username and password are required"
}
```

---

### 📌 Interface 4: Username and Password Login (`/api/auth/login`)

**Interface Description**：
Registered users may log in using their username and password.

**Request method**：
```http
POST /api/auth/login
Content-Type: application/json
```

**Request parameters**：
| Parameters     | Type   | Must | Note     | Example         |
|----------|--------|------|----------|--------------|
| username | string | yes   | Username   | `"student01"` |
| password | string | yes   | Password     | `"pass123!"`  |

**Request example**：
```json
{
    "username": "student01",
    "password": "securePassword123"
}
```

**Successful Response Example**：
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
**Example of abnormal response** (User does not exist or password is incorrect):
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

### 📌 Interface 5: Apple Sign-In Authentication (`/api/auth/apple`)

**Interface Description**：
(This is a backend example interface) Handles the `identityToken` sent when logging in via ‘Sign in with Apple’ from an iOS client. The backend should validate this `identityToken` (e.g., by verifying with Apple's servers) and, based on the validation result, create or retrieve user information, returning a session token.

**Request method**：
```http
POST /api/auth/apple
Content-Type: application/json
```

**Request parameters**：
| Parameters      | Type   | Must | Note                               | Example (Token is fictitious)                                      |
|-----------------|--------|------|------------------------------------|---------------------------------------------------------|
| identity_token  | string | yes   | Identity token provided by Apple                  | `"eyJraWQiOiJBSURPUEsxIiwiYWxnIjoiUlMyNTYifQ..."`         |
| user_identifier | string | no    | Apple-provided user identifier (optional input)   | `"001234.abc123def456ghi789.0123"`                      |

**Request example**：
```json
{
    "identity_token": "eyJraWQiOiJBSURPUEsxIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLnlvdXItYXBwLWJ1bmRsZS1pZCIsImV4cCI6MTY3ODg4NjQwMCwiaWF0IjoxNjc4ODg2MzQwLCJzdWIiOiIwMDEyMzQuYWJjMTIzZGVmNDU2Z2hpNzg5LjAxMjMiLCJjX2hhc2giOiJLWU..." ,
    "user_identifier": "001234.abc123def456ghi789.0123"
}
```
**Successful Response Example** (The backend has successfully verified and issued the session token):
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
**Example of an abnormal response** (Lacking `identity_token`):
```json
{
    "error": "missing identity_token"
}
```
*Note: Authentic Apple Token verification is more complex and may involve steps such as public key acquisition and JWT decoding and validation. The backend implementation here is a simplified version for demonstration purposes only.*

---

## 🛠️ Interface Testing Specification

The project provides unit test files to facilitate rapid self-testing of interfaces

**Test file path**：  
```
test_flask_rag_api.py
```

Operational testing：

```bash
python test_flask_rag_api.py
```
The test cases also include examples addressing issues within the K-11 education sector.

---

## 🔑 OpenAI API Key Configuration Guide

The project utilises OpenAI models and requires the configuration of environment variables：

```bash
export OPENAI_API_KEY="Your actual OpenAI API key"
```

Alternatively, create a `.env` file in the project root directory (requires the `python-dotenv` library)：

```dotenv
OPENAI_API_KEY=你的真实OpenAI_API_KEY
```

---

## 📚 Recommended Development Process

1.  Install dependencies.
2.  Configure the OpenAI API Key environment variable or `.env` file.
3.  Prepare K-11 education-related teaching materials, supplementary resources, and other data files into the `edu_docs/` folder.
4.  Upon initial API execution, the system will automatically scan the `edu_docs/` directory and construct a vector index, which is stored within `vector_k11/`. Subsequent launches will directly load the existing index.
5.  During the backend development debugging phase, utilise tools such as Postman or Insomnia, or employ the `test_flask_rag_api.py` script to test the interfaces.
6.  The front-end (such as a Vue application) invokes back-end APIs via HTTP requests to implement the user interface.
7.  Following the iteration of backend functionality, update or add unit test cases to ensure the functionality is error-free.

---

🚩 **Notes**：

-   During the initial run, due to the substantial volume of documents, indexing may take a considerable amount of time. Please be patient.
-   Following the creation or modification of documents within the `edu_docs/` directory, it is typically necessary to manually delete the outdated index from the persistent folder (such as `vector_k11`) and restart the API service. This ensures the index is   regenerated to incorporate the latest content.
-   It is recommended to use Docker or virtual environments (such as venv or conda) for development and deployment to simplify environment management and ensure dependency isolation.

---

The above constitutes the comprehensive documentation for this project's API. Should any new features or interfaces be introduced subsequently, please ensure this documentation is promptly updated to facilitate efficient collaborative development within the team.
