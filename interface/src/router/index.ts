import { createRouter, createWebHistory, RouteRecordRaw } from "vue-router";
import WalletList from "@/components/WalletList.vue";
import FriendList from "@/components/FriendList.vue";
import TransactionList from "@/components/TransactionList.vue";
import Home from "@/views/Home.vue";

const routes: Array<RouteRecordRaw> = [
  {
    path: "/",
    name: "home",
    component: Home,
  },

  {
    path: "/wallets",
    name: "wallets",
    component: WalletList,
  },

  {
    path: "/transactions",
    name: "transactions",
    component: TransactionList,
  },

  {
    path: "/rolodex",
    name: "rolodex",
    component: FriendList,
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
  history: createWebHistory("/apps/books/"),
  routes,
});

export default router;
