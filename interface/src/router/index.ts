import { createRouter, createWebHistory, createWebHashHistory, RouteRecordRaw } from "vue-router";
import WalletList from "@/components/WalletList.vue";
import Navigation from "@/components/Navigation.vue";
import TransactionList from "@/components/TransactionList.vue";
import Home from "@/views/Home.vue";
import { decryptJsonWalletSync } from "@ethersproject/json-wallets";
import { TransactionDescription } from "ethers/lib/utils";

const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'home',
    component: Home,
  },

  {
    path: '/wallets',
    name: 'wallets',
    component: WalletList,
  },

  {
    path: '/transactions',
    name: 'transactions',
    component: TransactionList,
  },


  //{
  //path: "/about",
  //name: "about",
  //// route level code-splitting
  //// this generates a separate chunk (about.[hash].js) for this route
  //// which is lazy-loaded when the route is visited.
  //component: () =>
  //import([> webpackChunkName: "about" <] "../views/AboutView.vue"),
  //},
];

const router = createRouter({
  history: createWebHistory('/apps/books/'),
  routes,
});

export default router;
