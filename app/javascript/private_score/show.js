import Vue from 'vue'
import ShowPrivateScore from '../score/show.vue'

document.addEventListener('DOMContentLoaded', () => {
  const score = document.getElementById('js-show-private-score')
  if (score) {
    const scoreId = score.getAttribute('data-score-id')
    let firstLine = score.getAttribute('data-first-measure')
    firstLine = firstLine === 'true'
    new Vue({
      render: (h) =>
        h(ShowPrivateScore, {
          props: {
            scoreId: scoreId,
            firstLine: firstLine,
            privateScore: true,
          },
        }),
    }).$mount('#js-show-private-score')
  }
})
