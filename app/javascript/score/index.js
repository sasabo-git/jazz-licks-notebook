import Vue from 'vue'
import IndexScore from './index.vue'

document.addEventListener('DOMContentLoaded', () => {
  const score = document.getElementById('js-index-score')
  if (score) {
    var firstLine = score.getAttribute('data-first-measure')
    firstLine = firstLine === 'true'
    new Vue({
      render: (h) =>
        h(IndexScore, {
          props: {
            firstLine: firstLine,
          },
        }),
    }).$mount('#js-index-score')
  }
})
