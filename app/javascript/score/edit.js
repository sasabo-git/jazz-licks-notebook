import Vue from 'vue'
import ShowScore from './edit.vue'

document.addEventListener('DOMContentLoaded', () => {
  const score = document.getElementById('js-edit-score')
  if (score) {
    const scoreId = score.getAttribute('data-score-id')
    new Vue({
      render: (h) =>
        h(ShowScore, {
          props: {
            scoreId: scoreId,
          },
        }),
    }).$mount('#js-edit-score')
  }
})
