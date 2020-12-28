<template lang="pug">
  .container
    .tabs.is-boxed
      ul
        li
          router-link(to='/') 基本情報
        li
          router-link(:to="{name:'ScoreBody'}", v-on:click.native='setBasicScoreInformations') 作曲
    p.title.is-size-5
      | 曲の基本設定
    .content
      p.title-form
        h6.subtitle.mb-1
          | タイトル
        input(v-model='title', class="input", placeholder="タイトルを記入して下さい")
      p.memo-form
        h6.subtitle.mb-1
          | メモ
        textarea(v-model='memo', class="textarea", rows="4", placeholder="曲に関するメモを記入できます(任意)")
      p.key
        h6.subtitle.mb-1
          | キー
        .columns.is-variable.is-1
          .column
            .keynote.select.is-small
              select(v-model='keynote')
                option(v-for='keynote in allTones')
                  | {{ keynote }}
          .column
            .tonality.select.is-small
                select(v-model='tonality')
                  option(v-for='tonality in tonalities', v-bind:value='tonality.value')
                    | {{ tonality.text }}
      p.chord-progression
        h6.subtitle.is-6.mb-1
          | コード進行
        .select.is-small
          select(v-model='chordProgression')
            option(v-for='progression in chordProgressions', v-bind:value='progression.value')
              | {{ progression.text }}
      p.meter
        h6.subtitle.is-6.mb-1
          | 拍子記号
        .columns.is-variable.is-1
          .column.is-4
            input(v-model='meter').input.is-small
          .column
            | 拍子
</template>

<script>
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
      allTones: [
        'C',
        'Db',
        'D',
        'Eb',
        'E',
        'F',
        'Gb',
        'G',
        'Ab',
        'A',
        'Bb',
        'B',
      ],
      chordProgressions: [
        { text: '自由', value: 'free' },
        { text: '2-5-1', value: '2-5-1' },
      ],
    }
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
        this.bpm = val.states.bpm
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
        bpm: this.bpm,
        memo: this.memo,
      })
    },
  },
}
</script>
