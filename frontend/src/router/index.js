// File: frontend/src/router/index.js

import { createRouter, createWebHistory } from 'vue-router';
import { useAuthStore } from '@/stores/auth';

// Import view components
import Home from '@/views/Home.vue';
import Login from '@/components/Login.vue';
import Chat from '@/components/Chat.vue';

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home,
  },
  {
    path: '/login',
    name: 'Login',
    component: Login,
    meta: { guestOnly: true },
  },
  {
    path: '/chat',
    name: 'Chat',
    component: Chat,
    meta: { requiresAuth: true },
  },
  // Catch-all route for unmatched paths, redirect to Home
  {
    path: '/:pathMatch(.*)*',
    redirect: '/',
  },
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes,
});

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore();

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    // Route requires authentication, but user is not authenticated
    next({ name: 'Login', query: { redirect: to.fullPath } });
  } else if (to.meta.guestOnly && authStore.isAuthenticated) {
    // Route is only for guests, but user is already authenticated
    next({ name: 'Chat' });
  } else {
    next();
  }
});

export default router;