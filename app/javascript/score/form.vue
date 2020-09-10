<template lang="pug">
  .form-score
    .form
      .title
        .label タイトル
        .input
          input(v-model='title')
      .key
        .label キー
          .keynote
            .label 主音
            .select
              select(v-model='keynote')
                option(v-for='keynote in allTones')
                  | {{ keynote }}
          .tonality
            .label メジャー or マイナー
            .select
              select(v-model='tonality')
                option(v-for='tonality in tonalities', v-bind:value='tonality.value')
                  | {{ tonality.text }}
      .chord-progression
        .label コード進行
        .select
          select(v-model='chordProgression')
            option(v-for='progression in chordProgressions', v-bind:value='progression.value')
              | {{ progression.text }}
      .meter
        .input
          input(v-model='meter')
          | 拍子
      .abc-setting
        .notelength
          .label 基本音符長
          .input
            input(v-model='noteLength')
            | 分音符
        .bpm
          .input
            input.bpm(v-model='bpm', @input='clearErrorMsg')
            | bpm
          .error-message
            span(style='color: red; margin-left: 20px;') {{ errorMsg }}
          .slider
            vue-slider(v-model='bpm', :min='min', :max='max', :tooltip="errorMsg ? 'none' : 'always'", :marks='[40, 350]', @error='error', @change='clearErrorMsg')
      .abc-paper
        textarea(readonly)#abc-source(v-model='tune')
        #paper
        #midi
      .melody
        .label メロディー
        .textarea
          textarea(v-model='melody')
      .memo
        .label メモ
          .textarea
            textarea(v-model='memo')
    .guide
      .label 作曲ガイド
      .check-boxes
        .code_tone
          input#chordTones(type='checkbox', value='ChordTone', v-model='checkedGuides')
          | コードトーン
        .seventh
          input#seventh(type='checkbox', value='Seventh', v-model='checkedGuides')
          | 7th
      .abc-guide
        #guide
    .submit
      button(@click="saveOrUpdate" type="button")
        | 保存
</template>

<script>
import 'font-awesome/css/font-awesome.min.css'
import 'abcjs/abcjs-midi.css'
import abcjs from 'abcjs/midi'
import _ from 'lodash'
import VueSlider from 'vue-slider-component'
import 'vue-slider-component/theme/default.css'

const ERROR_TYPE = {
  VALUE: 1,
  INTERVAL: 2,
  MIN: 3,
  MAX: 4,
  ORDER: 5,
}

export default {
  components: {
    VueSlider,
  },
  props: {
    scoreId: { type: String, required: true },
  },
  data() {
    return {
      title: '',
      tonality: 'major',
      keynote: 'C',
      chordProgression: '',
      memo: '',
      melody: '',
      meter: '4/4',
      noteLength: '8',
      bpm: 120,
      min: 40,
      max: 350,
      errorMsg: '',
      tonalities: [
        { text: 'メジャー', value: 'major' },
        { text: 'マイナー', value: 'minor' },
      ],
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
      chordProgressions: [
        { text: '自由', value: 'free' },
        { text: '2-5-1', value: '2-5-1' },
      ],
      checkedGuides: [],
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
      set: function (value) {
        this.tuneElements(value)
      },
    },
    key: {
      get: function () {
        var target = ''
        if (this.keynote && this.tonality) {
          if (this.tonality === 'major') {
            target = this.keynote
          } else {
            target = `${this.keynote}m`
          }
        }
        return target
      },
      set: function (value) {
        this.keynote = value.replace(/m/, '')
        this.tonality = value.includes('m') ? 'minor' : 'major'
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
      var target = []
      if (this.keynote) target = this.sortByKey(this.allTones, this.keynote)
      return target
    },
    twoFive: function () {
      var target = []
      if (this.twelveTones.length) {
        target.push(`"${this.twelveTones[7]}7"`)
        if (this.tonality === 'major') {
          target.unshift(`"${this.twelveTones[2]}m7"`)
          target.push(`"${this.twelveTones[0]}maj"`)
        } else {
          target.unshift(`"${this.twelveTones[2]}m7(b5)"`)
          target.push(`"${this.twelveTones[0]}m7"`)
        }
      }
      return target
    },
    guideTones: function () {
      var body = []
      if (this.chords.length && this.checkedGuides.length) {
        if (this.checkedGuides.some((guide) => guide === 'ChordTone')) {
          this.chords.forEach((code) => {
            body.push(code + this.diatonicCodeTone(code))
          })
        }
      }
      return `K:${this.key}\n` + body.join('|')
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
      set: function (value) {
        this.melody = value.replace(/".*?"/g, '')
      },
    },
  },
  watch: {
    tune: _.debounce(function () {
      this.editor.fireChanged()
    }, 300),
    guideTones: _.debounce(function () {
      abcjs.renderAbc('guide', this.guideTones)
    }, 300),
  },
  async created() {
    if (this.scoreId !== 'new') await this.setScore()
  },
  mounted: function () {
    /* eslint-disable */
    this.editor = new abcjs.Editor('abc-source', {
      canvas_id: 'paper',
      generate_midi: true,
      midi_id: 'midi',
    })
    /* eslint-enable */
  },
  methods: {
    async setScore() {
      await fetch(`/api/scores/${this.scoreId}.json`, {
        method: 'GET',
        headers: {
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token(),
        },
        credentials: 'same-origin',
      })
        .then((response) => {
          return response.json()
        })
        .then((score) => {
          var header = ''
          var body = ''
          const self = this
          Object.keys(score).forEach(function (key) {
            if (score[key]) {
              switch (key) {
                case 'title':
                  header += `T:${score[key]}\n`
                  break
                case 'key':
                  header += `K:${score[key]}\n`
                  break
                case 'meter':
                  header += `M:${score[key]}\n`
                  break
                case 'bpm':
                  header += `Q:${score[key]}\n`
                  break
                case 'chord_progression':
                  self.chordProgression = score[key]
                  break
                case 'body':
                  body = `${score[key]}`
              }
            }
          })
          this.tune = header + body
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    sortByKey: function (tones, keynote) {
      var target = []
      if (keynote === 'C') {
        target = tones.concat()
      } else {
        const index = tones.indexOf(keynote)
        target = tones.slice(index).concat(tones.slice(0, index))
      }
      return target
    },
    tuneElements: function (abcjs) {
      const elements = abcjs.split('\n')
      var body = ''
      var newLineFlag = false
      const self = this
      elements.forEach(function (element) {
        if (/^T:.+/.test(element)) {
          self.title = element.replace(/T:/, '')
        } else if (/^K:.+/.test(element)) {
          self.key = element.replace(/K:/, '')
        } else if (/^M:.+/.test(element)) {
          self.meter = element.replace(/M:/, '')
        } else if (/^Q:.+/.test(element)) {
          self.bpm = element.replace(/Q:/, '')
        } else {
          if (newLineFlag) body += '\n'
          body += element
          newLineFlag = true
        }
      })
      self.body = body
    },
    diatonicCodeTone: function (code) {
      var octaveUp = false
      const keynote = code.match(/[A-Z]/g).join('')
      const diatonic = this.sortByKey(this.sevenTones, this.keynote)

      const scales = this.sortByKey(diatonic, keynote).map(function (tone, i) {
        if (i > 0 && tone === 'C') octaveUp = true
        return octaveUp ? tone.toLowerCase() : tone
      })
      return `${scales[0]}${scales[2]}${scales[4]}${scales[6]}`
    },
    async saveOrUpdate() {
      const self = this
      var id = ''
      var method = 'POST'
      if (self.scoreId !== 'new') {
        id = `/${self.scoreId}`
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
        body: self.body,
        bpm: self.bpm,
        chord_progression: self.chordProgression, // eslint-disable-line camelcase
        memo: self.memo,
      }
      await fetch(`/api/scores${id}`, {
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
    error(type, msg) {
      switch (type) {
        case ERROR_TYPE.MIN:
          break
        case ERROR_TYPE.MAX:
          break
        case ERROR_TYPE.VALUE:
          break
      }
      this.errorMsg = msg
    },
    clearErrorMsg() {
      this.errorMsg = ''
    },
  },
}
</script>
