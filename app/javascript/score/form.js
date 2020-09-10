import Vue from 'vue'
import ShowScore from './form.vue'

document.addEventListener('DOMContentLoaded', () => {
  const score = document.getElementById('js-form-score')
  if (score) {
    const scoreId = score.getAttribute('data-score-id')
    new Vue({
      render: (h) =>
        h(ShowScore, {
          props: {
            scoreId: scoreId,
          },
        }),
    }).$mount('#js-form-score')
  }
})
