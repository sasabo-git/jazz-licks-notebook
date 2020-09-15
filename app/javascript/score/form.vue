<template lang="pug">
  .score-form
    .music-form
      .side-form
        .key
          .music-form__label キー
          .keynote
            select(v-model='keynote')
              option(v-for='keynote in allTones')
                | {{ keynote }}
          .tonality
            select(v-model='tonality')
              option(v-for='tonality in tonalities', v-bind:value='tonality.value')
                | {{ tonality.text }}
        .chord-progression
          .music-form__label コード進行
          select(v-model='chordProgression')
            option(v-for='progression in chordProgressions', v-bind:value='progression.value')
              | {{ progression.text }}
        .meter
          .music-form__label 拍子記号
          input(v-model='meter').music-form__input-short
          | 拍子
        .bpm
          .music-form__label テンポ (40 ~ 350)
          input.bpm(v-model='bpm', @input='clearErrorMsg').music-form__input-short
          | bpm
          //- .error-message
          //-   span(style='color: red; margin-left: 20px;') {{ errorMsg }}
        //- .bpm-slider
        //-   vue-slider(v-model='bpm', :min='min', :max='max', :tooltip="errorMsg ? 'none' : 'always'", :marks='[40, 350]', @error='error', @change='clearErrorMsg')
        .notelength
          .music-form__label 基本音符長
          input(v-model='noteLength').music-form__input-short
          | 分音符
        .guide
          .music-form__label 作曲ガイド
          //- input(type='checkbox', v-model='show')
          //- button(@click='showGuide') ガイド項目の表示を切替
          .check-boxes(v-show='show')
            label(v-for='guide in guides')
              input.guides(type='checkbox', :value='guide.value', v-model='checkedGuides')
              | {{ guide.text }}
      .main-form
        .title
          .music-form__label タイトル
          input(v-model='title').music-form__input
        .melody
          .music-form__label メロディー
          textarea(v-model='melody').music-form__textarea
        .memo
          .music-form__label メモ
          textarea(v-model='memo').music-form__textarea
        .how-to-write-abc
          .music-form__label abc記譜法の書き方
            .how-to-write-abc__text
              | {{ descriptionAbc }}
        .abc-paper
          .hidden-text
            textarea(readonly)#abc-source(v-model='tune')
          #paper
          #midi
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
      set: function (value) {
        this.tuneElements(value)
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
      return 'T:作曲ガイド\n' + `K:${this.key}\n` + guideTones.join('|') + '|'
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
    guideTone: _.debounce(function () {
      abcjs.renderAbc('guide', this.guideTone)
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
      const index = tones.indexOf(keynote)
      target = tones.slice(index).concat(tones.slice(0, index))
      return target
    },
    tuneElements: function (abcjs) {
      const elements = abcjs.split('\n')
      var body = ''
      var newLineFlag = false
      const self = this
      elements.forEach(function (element) {
        // ここは関数化できそう
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
