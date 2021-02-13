<template lang="pug">
.modal(v-bind:class="{ 'is-active': isShow }")
  .modal-background
  .modal-content
    h6.subtitle.is-6.is-marginless
      | 音の高さと休符
    ul
      li 音階: A~G, a~g
      li 中央のド: C
      li Cのオクターブ上: c
      li cのオクターブ上: c'
      li Cのオクターブ下: C,
      li 休符: z
    h6.subtitle.is-6.is-marginless
      | 調号 演奏記号
    ul
      li C# (シャープ): ^C
      li Cb (フラット): _C
      li タイ: -C2
      li スラー: (C4D4)
      li 3連符: (3AAA
    h6.subtitle.is-6.is-marginless
      | 小節線
    ul
      li 小節線: |
      li 終止線: |]
  button.modal-close.is-large(aria-label='close', @click='closeDialog')
</template>

<script>
export default {
  data() {
    return {
      isShow: false,
    }
  },
  methods: {
    showDialog: function () {
      this.isShow = true
    },
    closeDialog: function () {
      this.isShow = false
    },
  },
}
</script>
