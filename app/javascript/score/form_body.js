import Vue from 'vue'
import ShowScore from './form.vue'

document.addEventListener('DOMContentLoaded', () => {
  const score = document.getElementById('js-form-score')
  if (score) {
    const scoreId = score.getAttribute('data-score-id')
    var userSignedIn = score.getAttribute('user-signed-in')
    userSignedIn = userSignedIn === 'true'
    new Vue({
      render: (h) =>
        h(ShowScore, {
          props: {
            scoreId: scoreId,
            userSignedIn: userSignedIn,
          },
        }),
    }).$mount('#js-form-score')
  }
})
