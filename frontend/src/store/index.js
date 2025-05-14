// File: frontend/src/store/index.js
import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { useRouter } from 'vue-router';

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
  const router = useRouter();
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

  function logout() {
    token.value = null;
    user.value = null;
    setPersistedAuth(null, null);
    localStorage.removeItem('rag_conversation_id');
    if (router) {
      router.push('/login');
    } else {
      console.warn('Router not available for logout redirect');
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