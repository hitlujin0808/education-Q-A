// File: frontend/src/views/Home.vue
<template>
  <el-container class="home-container">
    <el-main>
      <el-card class="home-card">
        <template #header>
          <div class="card-header">
            <h1>欢迎使用 {{ appDisplayName }}</h1>
          </div>
        </template>
        <p>
          本项目是一个基于 RAG (Retrieval Augmented Generation) 技术的智能问答系统，
          专为 K-11 教育领域设计。通过将教材、学习资料等文档（如 TXT, PDF）存储后，
          系统能够利用 RAG 技术对这些资料进行高效检索，并结合大型语言模型，
          为用户提供精准、相关的答案。
        </p>
        
        <h2>核心功能</h2>
        <ul class="feature-list">
          <li><strong>智能问答:</strong> 基于上传的文档资料进行智能问答。</li>
          <li><strong>领域专精:</strong> 特别优化 K-11 教育内容。</li>
          <li><strong>多轮对话:</strong> 支持上下文理解，进行自然的连续交流。</li>
        </ul>

        <h2>技术栈</h2>
        <ul class="tech-stack-list">
          <li><strong>后端:</strong> Flask (Python) API</li>
          <li><strong>RAG核心:</strong> LlamaIndex, Langchain</li>
          <li><strong>前端:</strong> Vue 3, Element Plus, Vite</li>
          <li><strong>iOS App:</strong> SwiftUI (提供移动端体验)</li>
        </ul>

        <div class="actions">
          <el-button v-if="!authStore.isAuthenticated" type="primary" size="large" @click="goToLogin">
            <el-icon><User /></el-icon> 登录体验
          </el-button>
          <el-button v-else type="success" size="large" @click="goToChat">
            <el-icon><ChatDotRound /></el-icon> 开始提问
          </el-button>
        </div>
      </el-card>
    </el-main>
  </el-container>
</template>

<script setup>
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { User, ChatDotRound } from '@element-plus/icons-vue';

const appDisplayName = 'K-11 学习助手';
const router = useRouter();
const authStore = useAuthStore();

const goToLogin = () => {
  router.push('/login');
};

const goToChat = () => {
  router.push('/chat');
};
</script>

<style scoped>
.home-container {
  padding: 20px;
  background-color: #f4f6f8;
  min-height: calc(100vh - 60px - 40px);
  display: flex;
  justify-content: center;
  align-items: center;
}

.home-card {
  max-width: 800px;
  width: 100%;
  margin: 0 auto;
  border-radius: 12px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
}

.card-header h1 {
  margin: 0;
  color: #333;
  font-size: 24px;
  text-align: center;
}

p {
  line-height: 1.8;
  color: #555;
  font-size: 16px;
  margin-bottom: 20px;
}

h2 {
  color: #409EFF;
  border-bottom: 2px solid #e0e0e0;
  padding-bottom: 8px;
  margin-top: 30px;
  margin-bottom: 15px;
  font-size: 20px;
}

.feature-list,
.tech-stack-list {
  list-style-type: none;
  padding-left: 0;
}

.feature-list li,
.tech-stack-list li {
  margin-bottom: 10px;
  font-size: 15px;
  color: #555;
  display: flex;
  align-items: center;
}

.feature-list li::before,
.tech-stack-list li::before {
  content: '✓';
  color: #67C23A;
  margin-right: 10px;
  font-weight: bold;
}

.actions {
  margin-top: 30px;
  text-align: center;
}

.actions .el-button {
  min-width: 150px;
}

.el-icon {
  margin-right: 5px;
}
</style>