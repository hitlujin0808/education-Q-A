import { createApp } from 'vue';
import App from './App.vue';
import ElementPlus from 'element-plus';
import 'element-plus/dist/index.css';
import * as ElementPlusIconsVue from '@element-plus/icons-vue';

import router from './router';
import { createPinia } from 'pinia';

import axios from 'axios';
axios.defaults.baseURL = import.meta.env.DEV ? '' : (import.meta.env.VITE_API_BASE_URL || 'http://localhost:5005');

const app = createApp(App);

for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component);
}

app.config.globalProperties.$axios = axios;

const pinia = createPinia();
app.use(pinia);

app.use(router);
app.use(ElementPlus);

app.mount('#app');