import Vue from 'vue'
import BasicInformationForm from './basic-information-form.vue'

document.addEventListener('DOMContentLoaded', () => {
  // const scoreId = score.getAttribute('data-score-id')
  // var userSignedIn = score.getAttribute('user-signed-in')
  // userSignedIn = userSignedIn === 'true'
  new Vue({
    render: (h) =>
      h(BasicInformationForm, {
        props: {
          // scoreId: scoreId,
          // userSignedIn: userSignedIn,
        },
      }),
  }).$mount('#js-basic-information-form-score')
})
