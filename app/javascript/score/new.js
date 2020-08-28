import Vue from 'vue'
import NewScore from './new.vue'

document.addEventListener('DOMContentLoaded', () => {
  const score = document.getElementById('js-new-score')
  if (score) {
    new Vue({
      render: (h) => h(NewScore),
    }).$mount('#js-new-score')
  }
})
