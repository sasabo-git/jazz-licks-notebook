<template lang="pug">
  body
    .form
      p タイトル
      input(v-model='title')
      p 主音
      select(v-model='keynote')
        option(v-for='keynote in allTones')
          | {{ keynote }}
      p メジャー or マイナー
      select(v-model='tonality')
        option(v-for='tonality in tonalities', v-bind:value='tonality.value')
          | {{ tonality.text }}
      p コード進行
      select(v-model='chordProgression')
        option(v-for='progression in chordProgressions', v-bind:value='progression.value')
          | {{ progression.text }}
      p 拍子
      input(v-model='meter')
      p 基本音符長
      input(v-model='noteLength')
      | 分音符
      template
        p bpm
          .box
            input(v-model='bpm', @input='clearErrorMsg')
            span(style='color: red; margin-left: 20px;') {{ errorMsg }}
          vue-slider(v-model='bpm', :min='min', :max='max', :tooltip="errorMsg ? 'none' : 'always'", :marks='[40, 350]', @error='error', @change='clearErrorMsg')

      br
      p 作曲ガイド
      input#chordTones(type='checkbox', value='ChordTone', v-model='checkedGuides')
      | コードトーン
      input#seventh(type='checkbox', value='Seventh', v-model='checkedGuides')
      | 7th
      #guide

      p メロディー
      textarea(v-model='melody')
      p ABC記譜法(表示のみで編集不可）
      textarea(readonly)#abc-source(v-model='tune')
      #paper
      #midi
      button(@click="createScore" type="button")
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
  data() {
    return {
      title: '',
      tonality: '',
      keynote: '',
      chordProgression: '',
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
      set: function () {
        this.keynote = this.key.replace(/m/, '')
        this.tonality = this.key.includes('m') ? 'minor' : 'major'
      },
    },
    chords: function () {
      var target = []
      switch (this.chordProgression) {
        case '2-5-1':
          target = this.twoFive
          break
      }
      return target
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
      if (this.twoFive.length && this.checkedGuides.length) {
        if (this.checkedGuides.some((guide) => guide === 'ChordTone')) {
          this.twoFive.forEach((code) => {
            body.push(code + this.diatonicCodeTone(code))
          })
        }
      }
      return `K:${this.key}\n` + body.join('|')
    },
    body: {
      get: function () {
        var target = []
        target = this.melody.replace(/".*"/g, '').split('|')
        if (this.chords.length) {
          var length = Math.min(target.length, this.chords.length)
          for (let i = 0; i < length; i++) {
            target[i] = this.chords[i] + target[i]
          }
          if (target.length < this.chords.length) {
            Array.prototype.push.apply(target, this.chords.slice(length))
          }
        }
        return target.join('|') + '|'
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
      // }
    },
    async createScore() {
      if (!this.title || !this.body) {
        return null
      }
      const params = {
        title: this.title,
        key: this.key,
        body: `M:${this.meter}\n` + this.body,
      }
      await fetch(`/api/scores`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.token(),
        },
        credentials: 'same-origin',
        redirect: 'manual',
        body: JSON.stringify(params),
      })
        .then((response) => {
          return response.json()
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
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
