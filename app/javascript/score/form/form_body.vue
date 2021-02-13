<template lang="pug">
  .container
    .form.box
      .tabs.is-box
        ul
          li
            router-link(to='/', v-on:click.native='setScoreBody()') 基本情報ページ
          li.is-active
            a 作曲ページ
      .music-form.columns
        .column.is-4
          .melody-form.field
            label.label
              | メロディー
            p.control
              textarea(v-model='melody', class="textarea", rows="4")
          .bpm.field.field
            label.label
              | テンポ
            .columns.is-variable.is-1
              p.control
                .column
                  input(v-model='bpm').input.is-small
                .column.mt-1
                  | bpm
        .column
          p.abc-paper
            textarea(readonly)#abc-source(v-model='tune').is-hidden
            #midi
            #paper
    guide(:chordProgression='chordProgression', :keynote='store.states.keynote', :tonality='tonality', v-show="chordProgression !== 'free'")
    nav.save-button.level-center
      .level-item
        button(v-if="userSignedIn" @click="saveOrUpdate" type="button").button.is-warning.has-text-black.has-text-weight-bold
          | 保存する
</template>

<script>
import formMixin from './form_mixin'
import 'font-awesome/css/font-awesome.min.css'
import 'abcjs/abcjs-midi.css'
import abcjs from 'abcjs/midi'
import _ from 'lodash'
import explainAbc from './explain_abc.vue'
import guide from './guide.vue'

export default {
  components: {
    'explain-abc': explainAbc,
    guide,
  },

  mixins: [formMixin],

  props: {
    scoreId: { type: String, required: true },
    userSignedIn: { type: Boolean, required: true },
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

      editor: {},
    }
  },

  computed: {
    tune: {
      get: function () {
        let target =
          `K:${this.key}\n` +
          `M:${this.meter}\n` +
          `L:1/${this.noteLength}\n` +
          `Q:${this.bpm}\n` +
          this.body
        return target
      },
    },

    body: {
      get: function () {
        let target = []
        target = this.melody.replace(/".*?"/g, '').split('|')
        if (this.chords.length) {
          let length = Math.min(target.length, this.chords.length)
          for (let i = 0; i < length; i++) {
            target[i] = this.chords[i] + target[i]
          }
          if (target.length < this.chords.length) {
            Array.prototype.push.apply(target, this.chords.slice(length))
          }
        }
        return !target.length ? '|' : target.join('|')
      },
    },
  },

  watch: {
    // storeの値に変更を反映する。
    store: {
      handler: function (val) {
        this.title = val.states.title
        this.keynote = val.states.keynote
        this.tonality = val.states.tonality
        this.melody = val.states.melody
        this.meter = val.states.meter
        this.chordProgression = val.states.chordProgression
        this.bpm = val.states.bpm
        this.noteLength = val.states.noteLength
        this.memo = val.states.memo
      },
      // deepをtrueにしないとオブジェクトの値を検知できなくなるので削除不可
      deep: true,
    },

    tune: _.debounce(function () {
      this.editor.fireChanged()
    }, 300),
  },

  mounted: function () {
    /* eslint-disable */
    this.editor = new abcjs.Editor('abc-source', {
      canvas_id: 'paper',
      generate_midi: true,
      midi_id: 'midi',
      abcjsParams: {
        staffwidth: 650,
        paddingright: 15,
        responsive: 'resize',
      },
    })
    /* eslint-enable */
  },

  methods: {
    async saveOrUpdate() {
      const self = this
      let id = ''
      let method = 'POST'
      if (self.scoreId !== 'new') {
        id = `${self.scoreId}`
        method = 'PUT'
      }
      if (!self.title || !self.body) {
        // ここにメッセージを出したい
        return null
      }
      const params = {
        title: self.title,
        key: self.key,
        meter: self.meter,
        bpm: self.bpm,
        body: self.body,
        chord_progression: self.chordProgression, // eslint-disable-line camelcase
        memo: self.memo,
      }
      await fetch(`/api/scores/${id}`, {
        method: `${method}`,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': self.token(),
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params),
      })
        .then((response) => {
          return self.scoreId === 'new' ? response.json() : response
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
        .then((data) => {
          if (!id) id = data.id
          location.href = `/scores/${id}`
        })
    },

    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },

    setScoreBody() {
      this.store.setScoreBody({
        melody: this.melody,
        bpm: this.bpm,
      })
    },

    showDialog() {
      this.$refs.dialog.showDialog()
    },
  },
}
</script>
