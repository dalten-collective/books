import { createStore as createVuexStore } from "vuex";

import ship from "./ship";
import books from "./books";

export const createStore = () => {
  return createVuexStore({
    modules: {
      ship,
      books,
    },
  });
};
