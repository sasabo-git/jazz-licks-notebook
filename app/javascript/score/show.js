import Vue from 'vue'
import ShowScore from './show.vue'

document.addEventListener('DOMContentLoaded', () => {
  const score = document.getElementById('js-show-score')
  if (score) {
    const scoreId = score.getAttribute('data-score-id')
    var firstLine = score.getAttribute('data-first-measure')
    firstLine = firstLine === 'true'
    new Vue({
      render: (h) =>
        h(ShowScore, {
          props: {
            scoreId: scoreId,
            firstLine: firstLine,
          },
        }),
    }).$mount('#js-show-score')
  }
})
