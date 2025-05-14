// File: frontend/src/stores/auth.js

import { defineStore } from 'pinia';
import { ref, computed } from 'vue';

// Key for localStorage persistence
const localStorageKey = 'authData_k11_rag';

const getPersistedAuth = () => {
  const data = localStorage.getItem(localStorageKey);
  return data ? JSON.parse(data) : { token: null, user: null };
};

const setPersistedAuth = (token, user) => {
  if (token && user) {
    localStorage.setItem(localStorageKey, JSON.stringify({ token, user }));
  } else {
    localStorage.removeItem(localStorageKey);
  }
};

export const useAuthStore = defineStore('auth', () => {
  const persisted = getPersistedAuth();
  const token = ref(persisted.token);
  const user = ref(persisted.user);

  const isAuthenticated = computed(() => !!token.value);
  const username = computed(() => user.value?.username || '');

  function login(authToken, userDetails) {
    token.value = authToken;
    user.value = userDetails;
    setPersistedAuth(authToken, userDetails);
  }

  function logout(routerInstance) {
    token.value = null;
    user.value = null;
    setPersistedAuth(null, null);
    localStorage.removeItem('rag_conversation_id');
    if (routerInstance) {
      routerInstance.push('/login');
    } else {
      console.warn('Router instance was not provided to the logout action. Cannot redirect using router.push().');
    }
  }

  function checkAuthStatus() {
    const persistedData = getPersistedAuth();
    if (persistedData.token && persistedData.user) {
      token.value = persistedData.token;
      user.value = persistedData.user;
    } else {
      token.value = null;
      user.value = null;
    }
  }

  checkAuthStatus();

  return {
    token,
    user,
    isAuthenticated,
    username,
    login,
    logout,
    checkAuthStatus,
  };
});