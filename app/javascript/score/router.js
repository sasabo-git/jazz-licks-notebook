import Vue from 'vue'
import VueRouter from 'vue-router'
import BasicInformationForm from './basic-information-form.vue'
import FormBody from './form_body.vue'

// ここでVueでVueRouterを使うことを明示
// 明示しないとエラーになるので削除不可
// 参考：https://salifyataala.medium.com/unknown-custom-element-router-link-did-you-register-the-component-correctly-bba1e9917132
Vue.use(VueRouter)

const routes = [
  { path: '/', props: true, component: BasicInformationForm },
  { path: '/body', name: 'ScoreBody', props: true, component: FormBody },
]

export default new VueRouter({ routes })
