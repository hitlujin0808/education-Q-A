<template>
  <div class="chat-container">
    <div class="chat-header">
      <h2>{{ appDisplayName }}</h2>
    </div>
    <div class="chat-history" ref="historyRef">
      <div
        v-for="(msg, idx) in messages"
        :key="msg.id"
        :class="['chat-message', msg.role]"
      >
        <div class="avatar">
          <el-avatar
            v-if="msg.role === 'assistant'"
            :icon="ServiceIcon"
            :size="32"
            style="background: #67c23a"
          />
          <el-avatar
            v-else
            :icon="UserIcon"
            :size="32"
            style="background: #409EFF"
          />
        </div>
        <div class="bubble">
          <div class="content" v-html="msg.content"></div>
          <div class="meta">
            <span class="time">{{ formatTime(msg.timestamp) }}</span>
          </div>
        </div>
      </div>
      <div v-if="isTyping" class="chat-message assistant">
        <div class="avatar">
          <el-avatar :icon="ServiceIcon" :size="32" style="background: #67c23a" />
        </div>
        <div class="bubble">
          <div class="content">
            <span class="typing-dot" v-for="i in 3" :key="i"></span>
          </div>
          <div class="meta">
            <span class="time">{{ formatTime(new Date()) }}</span>
          </div>
        </div>
      </div>
    </div>
    <div class="chat-input-bar">
      <el-input
        v-model="currentInput"
        placeholder="请输入你的问题…"
        @keyup.enter.native="sendMessage"
        :disabled="isTyping"
        clearable
        size="large"
        class="chat-input"
      />
      <el-button
        type="primary"
        :icon="SentIcon"
        :loading="isTyping"
        :disabled="!currentInput.trim() || isTyping"
        @click="sendMessage"
        size="large"
        class="chat-send-btn"
      >发送</el-button>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, nextTick, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import 'element-plus/es/components/message/style/css'
const uuidv4 = () => crypto.randomUUID()
import { User as UserIcon, Service as ServiceIcon, Promotion as SentIcon } from '@element-plus/icons-vue'

const appDisplayName = 'K-11 学习助手'
const baseURL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5005'

const welcomeText =
  '我是面向 K-11 各学科的 AI 学习助教，有任何学习问题都可以问我哟！'

const conversationIdKey = 'rag_conversation_id'

function getOrCreateConversationId() {
  let cid = localStorage.getItem(conversationIdKey)
  if (!cid) {
    cid = `webconv_${uuidv4().replace(/-/g, '')}`
    localStorage.setItem(conversationIdKey, cid)
  }
  return cid
}

const conversationId = getOrCreateConversationId()

const messages = reactive([
  {
    id: uuidv4(),
    role: 'assistant',
    content: welcomeText,
    timestamp: new Date()
  }
])
const currentInput = ref('')
const isTyping = ref(false)
const historyRef = ref(null)

async function sendMessage() {
  const question = currentInput.value.trim()
  if (!question) return

  const userMsg = {
    id: uuidv4(),
    role: 'user',
    content: escapeHtml(question),
    timestamp: new Date()
  }
  messages.push(userMsg)
  isTyping.value = true
  currentInput.value = ''

  await nextTick()
  scrollToBottom()

  try {
    const resp = await fetch(`${baseURL}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        conversation_id: conversationId,
        message: question
      })
    })
    const data = await resp.json()
    if (resp.ok && data.answer) {
      messages.push({
        id: uuidv4(),
        role: 'assistant',
        content: escapeHtml(data.answer),
        timestamp: new Date()
      })
    } else {
      messages.push({
        id: uuidv4(),
        role: 'assistant',
        content: `错误：${escapeHtml(data.error || '未知错误')}`,
        timestamp: new Date()
      })
    }
  } catch (err) {
    messages.push({
      id: uuidv4(),
      role: 'assistant',
      content: `网络错误：${escapeHtml(err.message)}`,
      timestamp: new Date()
    })
  } finally {
    isTyping.value = false
    await nextTick()
    scrollToBottom()
  }
}

function scrollToBottom() {
  nextTick(() => {
    if (historyRef.value) {
      historyRef.value.scrollTop = historyRef.value.scrollHeight
    }
  })
}

function formatTime(date) {
  if (!(date instanceof Date)) date = new Date(date)
  const h = date.getHours().toString().padStart(2, '0')
  const m = date.getMinutes().toString().padStart(2, '0')
  return `${h}:${m}`
}

function escapeHtml(str) {
  if (!str) return ''
  return str
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/\n/g, '<br/>')
}

onMounted(() => {
  scrollToBottom()
})
</script>

<style scoped>
.chat-container {
  max-width: 600px;
  margin: 0 auto;
  background: #f6f8fa;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(120, 120, 120, 0.10);
  display: flex;
  flex-direction: column;
  height: 80vh;
  overflow: hidden;
}
.chat-header {
  background: #67c23a;
  color: #fff;
  padding: 18px 20px 12px 20px;
  text-align: left;
  font-weight: bold;
  font-size: 22px;
  letter-spacing: 1px;
}
.chat-history {
  flex: 1;
  overflow-y: auto;
  padding: 18px 8px 8px 8px;
  display: flex;
  flex-direction: column;
  gap: 10px;
  background: #f6f8fa;
}
.chat-message {
  display: flex;
  align-items: flex-start;
  margin-bottom: 5px;
  gap: 10px;
}
.chat-message.user {
  flex-direction: row-reverse;
}
.chat-message .avatar {
  margin-top: 2px;
}
.chat-message .bubble {
  max-width: 78%;
  min-width: 42px;
  background: #fff;
  border-radius: 11px;
  padding: 10px 14px 7px 14px;
  font-size: 15px;
  line-height: 1.6;
  box-shadow: 0 1px 4px rgba(80, 120, 110, 0.09);
  word-break: break-word;
  position: relative;
  border: 1px solid #f1f1f1;
}
.chat-message.user .bubble {
  background: #409EFF;
  color: #fff;
  border: none;
  align-self: flex-end;
}
.chat-message.assistant .bubble {
  background: #fff;
  color: #222;
  align-self: flex-start;
}
.chat-message .meta {
  text-align: right;
  font-size: 11px;
  color: #b2b2b2;
  margin-top: 4px;
}
.chat-input-bar {
  padding: 14px 14px 16px 14px;
  background: #f9fafb;
  display: flex;
  gap: 10px;
  border-top: 1px solid #e8e8e8;
}
.chat-input {
  flex: 1;
}
.chat-send-btn {
  min-width: 80px;
}
.typing-dot {
  display: inline-block;
  width: 7px;
  height: 7px;
  margin-right: 3px;
  border-radius: 50%;
  background: #b3dbb0;
  animation: typing-bounce 1s infinite alternate;
}
.typing-dot:nth-child(2) { animation-delay: 0.2s; }
.typing-dot:nth-child(3) { animation-delay: 0.4s; }
@keyframes typing-bounce {
  to { transform: translateY(-6px); background: #67c23a; }
}
</style>