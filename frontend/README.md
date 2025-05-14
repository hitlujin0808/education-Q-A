# 前端 Web 交互体验（Chat Web Demo）

本目录 `frontend/` 提供一个Web 前端，实现基于浏览器的 Chat 聊天体验，便于直接通过网页与后端 Flask RAG API (`/api/chat`) 进行对话。适用于本地开发、演示及快速验证 RAG 问答系统功能。

---

## 目录结构

```
frontend/
├── README.md            # 本说明文档
├── index.html           # 主页面（简易Chat UI）
├── main.js              # 前端交互逻辑
├── style.css            # 基础样式
```

---

## 1. 快速开始

1. **确保后端 Flask 服务在本地运行**  
   （默认监听端口为 `http://localhost:5005`）

2. **进入 `frontend/` 目录：**
   ```bash
   cd frontend
   ```

3. **直接用浏览器打开 `index.html` 即可体验（无需构建）**  
   或用 `python3 -m http.server` 启动本地静态文件服务：

   ```bash
   python3 -m http.server 8080
   # 浏览器访问 http://localhost:8080
   ```

   > ⚠️  如需跨域支持，请确保 Flask 启动时允许 CORS（见下方“跨域配置”）

---

## 2. 文件说明

### index.html

- 提供一个简洁的聊天界面，包括消息展示区、输入框和发送按钮。
- 通过 `main.js` 实现与后端 API 的异步通信。

### main.js

- 管理消息列表、发送用户输入、展示助手回复。
- 默认请求后端 `/api/chat` 接口，支持多轮对话（conversation_id 本地生成）。

### style.css

- 聊天消息气泡样式，输入区布局，响应式适配基础。

---

## 3. 配置与说明

- **API 地址**  
  默认请求 `http://localhost:5005/api/chat`，如需部署至服务器或端口不同，可在 `main.js` 修改 `API_BASE_URL`。

- **会话隔离**  
  每次刷新页面会自动生成一个唯一会话ID，保证上下文独立。

- **CORS跨域**  
  如果你用的是本地文件或不同端口访问，请确保 Flask 后端允许跨域。例如在 `flask_rag_api.py` 增加：

  ```python
  from flask_cors import CORS
  CORS(app)
  ```

---

## 5. 代码示例片段

**index.html** 头部模块引入示例：

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>K-11 学习助手 Chat Web Demo</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
  <!-- 聊天区域 & 输入区将在此处渲染 -->
  <script src="main.js"></script>
</body>
</html>
```

**main.js** 初始化配置示例：

```js
// main.js
const API_BASE_URL = "http://localhost:5005";
const CHAT_ENDPOINT = `${API_BASE_URL}/api/chat`;
// ... 其余逻辑见 main.js
```

---

## 6. 可选：集成进项目主入口

如需正式集成，可以将 `frontend/` 作为静态资源目录，配置 Flask 或 Nginx 提供静态文件服务。

---