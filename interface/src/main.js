import { createApp } from 'vue';
import Antd from 'ant-design-vue';
import 'ant-design-vue/dist/antd.css';
import App from './App.vue';
import router from './router';
import './index.css';
import { createStore } from './store';

const app = createApp(App);
const store = createStore(app);

app.use(store);
app.use(Antd);
app.use(router);
app.mount('#app');
