import axios from 'axios';

const BASE_URL = import.meta.env.DEV ? '' : (import.meta.env.VITE_API_BASE_URL || 'http://localhost:5005');

const apiClient = axios.create({
  baseURL: BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json'
  }
});

export async function chat(conversationId, message) {
  const response = await apiClient.post('/api/chat', {
    conversation_id: conversationId,
    message
  });
  return response.data;
}

export async function retrieve(query, similarityTopK = 5) {
  const response = await apiClient.post('/retrieve', {
    query,
    similarity_top_k: similarityTopK
  });
  return response.data;
}

export async function register(username, password) {
  const response = await apiClient.post('/api/auth/register', {
    username,
    password
  });
  return response.data;
}

export async function login(username, password) {
  const response = await apiClient.post('/api/auth/login', {
    username,
    password
  });
  return response.data;
}

export async function authApple(identityToken, userIdentifier) {
  const response = await apiClient.post('/api/auth/apple', {
    identity_token: identityToken,
    user_identifier: userIdentifier
  });
  return response.data;
}