<template lang="pug">
  .container
    .tabs.is-boxed
      ul
        li
          router-link(to='/', v-on:click.native='setScoreBody()') 基本情報
        li
          router-link(:to="{name:'ScoreBody'}") 作曲
    .tile.is-ancestor.has-background-primary
      .tile
        .setting.tile.is-parent.is-3
          article.tile.is-child.box
            .content
              p.title.is-size-5
                | 作曲ガイド
              .content
                .check-boxes(v-show='show')
                  label(v-for='guide in guides')
                    .check-box.is-fullwidth
                      input.guides(type='checkbox', :value='guide.value', v-model='checkedGuides')
                      | {{ guide.text }}
              p.title.is-size-5
                explain-abc(ref='dialog')
                button.button.is-primary(@click='test1') ABC記法の書き方
        .tile.is-9.is-vertical
          .tile
            .music-form.tile.is-parent.is-12
              article.tile.is-child.box
                p.note-length
                  h6.subtitle.is-6.mb-1
                    | 基本音符長
                  .columns.is-variable.is-1
                    .column.is-4
                      input(v-model='noteLength').input.is-small
                    .column
                      | 分音符
                p.bpm
                  h6.subtitle.is-6.mb-1
                    | テンポ (40 ~ 350)
                  .columns.is-variable.is-1
                    .column.is-4
                      input(v-model='bpm').input.is-small
                    .column
                      | bpm
                .content
                  p.melody-form
                    h6.subtitle.is-6.mb-1
                      | メロディー
                    textarea(v-model='melody', class="textarea", rows="4",  placeholder="作曲ガイドを参考にABC記譜法で記入して下さい")
                .content
                  .abc-paper
                    textarea(readonly)#abc-source(v-model='tune').is-hidden
                    #paper
                    #midi
                    .abc-guide
                      #guide
                nav.level-center
                    .level-item
                      button(v-if="userSignedIn" @click="saveOrUpdate" type="button").button.is-warning.has-text-black.has-text-weight-bold
                        | 保存する
</template>

<script>
import 'font-awesome/css/font-awesome.min.css'
import 'abcjs/abcjs-midi.css'
import abcjs from 'abcjs/midi'
import _ from 'lodash'
import explainAbc from './explain_abc.vue'

export default {
  components: { 'explain-abc': explainAbc },

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

      sevenTones: ['C', 'D', 'E', 'F', 'G', 'A', 'B'],
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
      guides: [
        { text: 'コードトーン', value: 'chordTone' },
        { text: '9th', value: '9th' },
        { text: '11th', value: '11th' },
        { text: '#11th', value: '#11th' },
        { text: '13th', value: '13th' },
        { text: 'オルタード', value: 'artered' },
        { text: 'hmp5↓', value: 'hmp5' },
        { text: 'コンディミ', value: 'semitoneToneDiminished' },
        { text: 'ホールトーン', value: 'wholeTone' },
      ],
      checkedGuides: [],
      show: true,
      editor: {},
      guide: {},
    }
  },

  computed: {
    tune: {
      get: function () {
        var target =
          `T:${this.title}\n` +
          `K:${this.key}\n` +
          `M:${this.meter}\n` +
          `L:1/${this.noteLength}\n` +
          `Q:${this.bpm}\n` +
          this.body
        return target
      },
    },
    key: {
      get: function () {
        var key = ''
        if (this.keynote && this.tonality) {
          if (this.isMajor()) {
            key = this.keynote
          } else {
            key = `${this.keynote}m`
          }
        }
        return key
      },
    },
    chords: function () {
      var chords = []
      switch (this.chordProgression) {
        case '':
        case 'free':
          if (this.melody) {
            const tmp = this.melody.match(/".*?"/g)
            if (tmp) chords = tmp
          }
          break
        case '2-5-1':
          chords = this.twoFive
          break
      }
      return chords
    },
    twelveTones: function () {
      // ここはkeynoteのsetterで作れるのでは？
      var target = []
      if (this.keynote) target = this.sortByKey(this.allTones, this.keynote)
      return target
    },
    twoFive: function () {
      // ここもtwelveTonesのsetterで作れるのでは？
      var target = []
      if (this.twelveTones.length) {
        target.push(`"${this.twelveTones[7]}7"`)
        if (this.isMajor()) {
          target.unshift(`"${this.twelveTones[2]}m7"`)
          target.push(`"${this.twelveTones[0]}maj"`)
        } else {
          target.unshift(`"${this.twelveTones[2]}m7(b5)"`)
          target.push(`"${this.twelveTones[0]}m7"`)
        }
      }
      return target
    },
    guideTone: function () {
      // ここも依存してる
      var guideTones = []
      if (this.chords.length && this.checkedGuides.length) {
        this.chords.forEach((code) => {
          var guideTone = code
          this.checkedGuides.forEach((guide) => {
            guideTone += this.availableNote(code, guide)
          })
          guideTones.push(guideTone)
        })
      }
      return 'T:作曲ガイド\n' + guideTones.join('|') + '|'
    },
    body: {
      get: function () {
        var target = []
        target = this.melody.replace(/".*?"/g, '').split('|')
        if (this.chords.length) {
          var length = Math.min(target.length, this.chords.length)
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
    guideTone: _.debounce(function () {
      abcjs.renderAbc('guide', this.guideTone, {
        staffwidth: 650,
        paddingright: 15,
        responsive: 'resize',
      })
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
    sortByKey: function (tones, keynote) {
      var target = []
      const index = tones.indexOf(keynote)
      target = tones.slice(index).concat(tones.slice(0, index))
      return target
    },

    availableNote: function (code, toneName) {
      var octaveUp = false
      const keynote = code.match(/[A-Z]/g).join('')
      const diatonic = this.sortByKey(this.sevenTones, this.keynote)
      const scales = this.sortByKey(diatonic, keynote).map(function (tone, i) {
        if (i > 0 && tone === 'C') octaveUp = true
        return octaveUp ? tone.toLowerCase() : tone
      })
      var availableNote = ''
      switch (toneName) {
        case 'chordTone':
          availableNote = `${scales[0]}${scales[2]}${scales[4]}${scales[6]}`
          break
        case '9th':
          availableNote = `${scales[1]}'`
          break
        case '11th':
          availableNote = `${scales[3]}'`
          break
        case '#11th':
          if (this.functionOfcode(code) !== 'subDominant')
            availableNote = `^${scales[3]}'`
          break
        case '13th':
          if (this.functionOfcode(code) !== 'subDominant')
            availableNote = `${scales[5]}'`
          break
        case 'artered':
          if (this.functionOfcode(code) === 'dominant')
            availableNote = `${scales[0]}_${scales[1]}^${scales[1]}${scales[2]}^${scales[3]}_${scales[5]}${scales[6]}${scales[0]}'`
          break
        case 'hmp5':
          if (this.isMinor() && this.functionOfcode(code) === 'dominant') {
            const before3rd = `${scales[0]}${scales[1]}`
            const after3rd = `${scales[3]}${scales[4]}${scales[5]}${scales[6]}${scales[0]}'`
            if (['F', 'Eb', 'Bb', 'C'].includes(this.keynote)) {
              availableNote = before3rd + `=${scales[2]}` + after3rd
            } else if (this.keynote === 'Ab') {
              availableNote = before3rd + `^^${scales[2]}` + after3rd
            } else {
              availableNote = before3rd + `^${scales[2]}` + after3rd
            }
          }
          break
        case 'semitoneToneDiminished':
          availableNote = `${scales[0]}_${scales[1]}^${scales[1]}${scales[2]}^${scales[3]}${scales[4]}${scales[5]}${scales[6]}${scales[0]}'`
          break
        case 'wholeTone':
          availableNote = `${scales[0]}${scales[1]}${scales[2]}^${scales[3]}_${scales[5]}${scales[6]}${scales[0]}'`
          break
      }
      return availableNote
    },
    isMajor: function () {
      return this.tonality === 'major'
    },
    isMinor: function () {
      return this.tonality === 'minor'
    },
    showGuide: function () {
      this.show = !this.show
    },
    functionOfcode: function (code) {
      if (this.isMajor()) {
        if (/.m7/.test(code)) {
          return 'subDominant'
        } else if (/^(?!.*maj).*$/.test(code)) {
          return 'dominant'
        } else {
          return 'tonic'
        }
      } else {
        if (/.m7\(b5\)/.test(code)) {
          return 'subDominant'
        } else if (/^(?!.*m)(.*7)/.test(code)) {
          return 'dominant'
        } else {
          return 'tonic'
        }
      }
    },

    async saveOrUpdate() {
      const self = this
      var id = ''
      var method = 'POST'
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
        noteLength: this.noteLength,
      })
    },

    test1() {
      this.$refs.dialog.showDialog()
    },
  },
}
</script>
