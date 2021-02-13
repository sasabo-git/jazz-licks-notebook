<template lang="pug">
  .container
    .form.box
      .tabs.is-box
        ul
          li.is-active
            a 基本情報ページ
          li
            router-link(:to="{name:'ScoreBody'}", v-on:click.native='setBasicScoreInformations') 作曲ページ
      .title-form.field.is-horizontal
        .field-label.is-normal
          label.label
            | タイトル
        .field-body
          .field
            p.control
              input(v-model='title', class="input", placeholder="タイトルを記入して下さい")
      .key.field.is-horizontal
        .field-label.is-normal
          label.label
            | キー
        .field-body
          .keynote.field
            .control
              .select
                select(v-model='keynote')
                  option(v-for='keynote in allTones')
                    | {{ keynote }}
              .select
                select(v-model='tonality')
                  option(v-for='tonality in tonalities', v-bind:value='tonality.value')
                    | {{ tonality.text }}
      .meter.field.is-horizontal
        .field-label.is-normal
          label.label
            | 拍子
        .field-body
          .field.is-narrow
            p.control
              input(v-model='meter').input
      .note-length.field.is-horizontal
        .field-label.is-normal
          label.label
            | 基本音符長
        .field-body
          .field.is-narrow
            p.control
              input(v-model='noteLength').input
          .hoge.mt-2
            | 分音符
      .chord-progression.field.is-horizontal
        .field-label.is-normal
          label.label
            | コード進行
        .field-body
          .field
            p.control
              .select
                select(v-model='chordProgression')
                  option(v-for='progression in chordProgressions', v-bind:value='progression.value')
                    | {{ progression.text }}
      .memo.field.is-horizontal
        .field-label.is-normal
          label.label
            | メモ
        .field-body
          .field
            p.control.is-expanded
              textarea(v-model='memo', class="textarea", rows="4", placeholder="曲に関するメモを記入できます(任意)")
</template>

<script>
import config from './form_const'

export default {
  props: {
    store: { type: Object, required: true },
  },

  data() {
    return {
      title: this.store.states.title,
      keynote: this.store.states.keynote,
      tonality: this.store.states.tonality,
      melody: this.store.states.melody,
      meter: this.store.states.meter,
      chordProgression: this.store.states.chordProgression,
      bpm: this.store.states.bpm,
      noteLength: this.store.states.noteLength,
      memo: this.store.states.memo,

      tonalities: [
        { text: 'メジャー', value: 'major' },
        { text: 'マイナー', value: 'minor' },
      ],
      chordProgressions: [
        { text: '', value: 'free' },
        { text: '2-5-1', value: '2-5-1' },
      ],
    }
  },

  computed: {
    allTones() {
      return config.ALLTONES
    },
  },

  watch: {
    // storeの値に変更を反映する。
    store: {
      handler: function (val) {
        this.title = val.states.title
        this.keynote = val.states.keynote
        this.tonality = val.states.tonality
        this.meter = val.states.meter
        this.chordProgression = val.states.chordProgression
        this.noteLength = val.states.noteLength
        this.memo = val.states.memo
      },
      // deepをtrueにしないとオブジェクトの値を検知できなくなるので削除不可
      deep: true,
    },
  },

  methods: {
    setBasicScoreInformations() {
      this.store.setBasicScoreInformations({
        title: this.title,
        keynote: this.keynote,
        tonality: this.tonality,
        chordProgression: this.chordProgression,
        meter: this.meter,
        noteLength: this.noteLength,
        memo: this.memo,
      })
    },
  },
}
</script>
