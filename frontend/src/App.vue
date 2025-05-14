<template>
  <div id="app-layout">
    <el-container style="min-height: 100vh;">
      <el-header height="60px" class="app-header">
        <div class="header-content">
          <span class="app-title" @click="goHome">K-11 学习助手</span>
          <div class="nav-links">
            <el-menu mode="horizontal" :ellipsis="false" background-color="transparent" text-color="#ffffff" active-text-color="#ffd04b" :router="true" default-active="/">
              <el-menu-item index="/">主页</el-menu-item>
              <el-menu-item v-if="authStore.isAuthenticated" index="/chat">聊天</el-menu-item>
              <el-menu-item v-if="!authStore.isAuthenticated" index="/login">登录</el-menu-item>
              <el-menu-item v-if="authStore.isAuthenticated" @click="handleLogout">退出 ({{ authStore.username }})</el-menu-item>
            </el-menu>
          </div>
        </div>
      </el-header>
      <el-main class="app-main">
        <router-view v-slot="{ Component }">
          <transition name="fade" mode="out-in">
            <component :is="Component" />
          </transition>
        </router-view>
      </el-main>
    </el-container>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router';
import { useAuthStore } from '@/stores/auth';
import { onMounted } from 'vue';

const router = useRouter();
const authStore = useAuthStore();

onMounted(() => {
  authStore.checkAuthStatus();
});

const goHome = () => {
  router.push('/');
};

const handleLogout = async () => {
  authStore.logout(router);
};
</script>

<style>
body {
  margin: 0;
  font-family: 'PingFang SC', 'Microsoft YaHei', Arial, sans-serif;
  background-color: #f5f7fa;
}

#app-layout {
}

.app-header {
  background: #409EFF;
  color: white;
  padding: 0 20px;
  display: flex;
  align-items: center;
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}

.app-title {
  font-size: 20px;
  font-weight: bold;
  cursor: pointer;
}

.nav-links .el-menu {
  border-bottom: none;
}

.nav-links .el-menu--horizontal > .el-menu-item {
  color: white;
  border-bottom: none;
}
.nav-links .el-menu--horizontal > .el-menu-item:hover {
  background-color: #66b1ff !important;
}
.nav-links .el-menu--horizontal > .el-menu-item.is-active {
  color: #ffd04b !important;
  border-bottom: 2px solid #ffd04b !important;
  background-color: transparent !important;
}

.app-main {
  background: #f5f7fa;
  padding: 0px;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.2s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}
</style>