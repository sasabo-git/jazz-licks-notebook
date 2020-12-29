import Vue from 'vue'
import Form from './form.vue'
import Router from './router.js'

document.addEventListener('DOMContentLoaded', () => {
  const score = document.getElementById('js-form-score')
  if (score) {
    const scoreId = score.getAttribute('data-score-id')
    var userSignedIn = score.getAttribute('user-signed-in')
    userSignedIn = userSignedIn === 'true'
    new Vue({
      // routerのrは小文字でないとエラーが発生する
      router: Router,
      render: (h) =>
        h(Form, {
          props: {
            scoreId: scoreId,
            userSignedIn: userSignedIn,
          },
        }),
    }).$mount('#js-form-score')
  }
})
