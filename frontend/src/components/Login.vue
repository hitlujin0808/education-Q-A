<template>
  <div class="login-container">
    <el-card class="login-card">
      <h2 class="login-title">{{ showRegister ? '注册 K-11 账号' : 'K-11 学习助手登录' }}</h2>
      <el-form :model="form" ref="formRef" @submit.prevent="onSubmit" @keyup.enter="onSubmit">
        <el-form-item prop="username" :rules="[{ required: true, message: '请输入用户名', trigger: 'blur' }]">
          <el-input
            v-model="form.username"
            placeholder="用户名"
            :prefix-icon="UserIcon"
            clearable
            autocomplete="username"
          />
        </el-form-item>
        <el-form-item prop="password" :rules="[{ required: true, message: '请输入密码', trigger: 'blur' }]">
          <el-input
            v-model="form.password"
            type="password"
            placeholder="密码"
            :prefix-icon="LockIcon"
            show-password
            clearable
            autocomplete="current-password"
          />
        </el-form-item>
        <el-form-item>
          <el-button
            type="primary"
            :loading="loading"
            style="width: 100%;"
            @click="onSubmit"
          >
            {{ showRegister ? '注册' : '登录' }}
          </el-button>
        </el-form-item>
        <el-form-item>
          <el-link type="info" @click="toggleRegister">
            {{ showRegister ? '已有账号？去登录' : '没有账号？去注册' }}
          </el-link>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue';
import { useRouter, useRoute } from 'vue-router';
import { ElMessage } from 'element-plus';
import { useAuthStore } from '@/stores/auth';
import { User as UserIcon, Lock as LockIcon } from '@element-plus/icons-vue';

const BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:5005';

const router = useRouter();
const route = useRoute();
const authStore = useAuthStore();

const form = reactive({
  username: '',
  password: ''
});
const formRef = ref(null);
const loading = ref(false);
const showRegister = ref(false);

const onSubmit = async () => {
  if (!form.username.trim() || !form.password) {
    ElMessage.warning('请输入用户名和密码');
    return;
  }

  loading.value = true;
  try {
    const endpoint = showRegister.value ? '/api/auth/register' : '/api/auth/login';
    const res = await fetch(`${BASE_URL}${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        username: form.username,
        password: form.password
      })
    });
    const data = await res.json();

    if (data.success && data.token) {
      const userDetails = data.user || { username: form.username };
      authStore.login(data.token, userDetails);
      ElMessage.success(showRegister.value ? '注册成功！' : '登录成功！');
      const redirectPath = route.query.redirect || '/chat';
      router.push(redirectPath);
    } else {
      ElMessage.error(data.error || (showRegister.value ? '注册失败' : '登录失败'));
    }
  } catch (err) {
    ElMessage.error('网络错误，请重试');
  } finally {
    loading.value = false;
  }
};

const toggleRegister = () => {
  showRegister.value = !showRegister.value;
};
</script>

<style scoped>
.login-container {
  min-height: calc(100vh - 60px);
  display: flex;
  align-items: center;
  justify-content: center;
  background: #f5f7fa;
}
.login-card {
  width: 360px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
  border-radius: 12px;
  padding: 24px;
}
.login-title {
  text-align: center;
  margin-bottom: 24px;
  color: #303133;
  font-weight: 600;
  font-size: 20px;
}
.el-form-item {
  margin-bottom: 20px;
}
.el-button {
  height: 40px;
  font-size: 15px;
}
.el-link {
  font-size: 14px;
}
</style>