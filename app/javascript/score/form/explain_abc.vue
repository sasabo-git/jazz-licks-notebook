<template lang="pug">
  article.explain.message.is-light
    .message-header
      | メロディーの書き方
      button.button.is-warning.is-light.is-small(v-on:click='showExplainAbc')
        | {{ showOrHide }}
    .message-body(v-show='show')
      .columns
        .column
          p 音の高さと休符
          .content
            ul
              li 音階: A~G, a~g
              li 中央のド: C
              li Cのオクターブ上: c
              li cのオクターブ上: c'
              li Cのオクターブ下: C,
              li 休符: z
        .column
          p 調号 演奏記号
          .content
            ul
              li C# (シャープ): ^C
              li Cb (フラット): _C
              li タイ: -C2
              li スラー: (C4D4)
              li 3連符: (3AAA
        .column
          p 小節線
          .content
            ul
              li 小節線: |
              li 終止線: |]
</template>

<script>
export default {
  data() {
    return {
      show: false,
      showOrHide: '表示',
    }
  },
  methods: {
    showExplainAbc: function () {
      this.show = !this.show
      this.showOrHide = this.show ? '非表示' : '表示'
    },
  },
}
</script>
