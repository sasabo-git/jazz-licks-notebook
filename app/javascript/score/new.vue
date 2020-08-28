<template lang="pug">
  body
    .form
      p タイトル
      input(v-model='title')
      p メジャー or マイナー
      select(v-model='tonality')
        option(v-for='tonality in tonalities', v-bind:value='tonality.value')
          | {{ tonality.text }}
      p 主音
      select(v-model='keynote')
        option(v-for='keynote in keynotes')
          | {{ keynote }}
      p コード進行
      select(v-model='chordProgression')
        option(v-for='progression in chordProgressions', v-bind:value='progression.value')
          | {{ progression.text }}
      p {{ chords }}
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

export default {
  data() {
    return {
      title: '',
      tonality: '',
      keynote: '',
      chordProgression: '',
      melody: '',
      tonalities: [
        { text: 'メジャー', value: 'major' },
        { text: 'マイナー', value: 'minor' },
      ],
      keynotes: [
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
      editor: {},
    }
  },
  computed: {
    tune: {
      get: function () {
        return this.toAbcString(this.tuneHash())
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
    twelveTone: function () {
      if (this.keynote) {
        var target = []
        if (this.keynote === 'C') {
          target = this.keynotes
        } else {
          const index = this.keynotes.indexOf(this.keynote)
          target = this.keynotes
            .slice(index)
            .concat(this.keynotes.slice(0, index))
        }
      }
      return target
    },
    twoFive: function () {
      var target = []
      if (this.twelveTone) {
        target.push(`"${this.twelveTone[7]}7"`)
        if (this.tonality === 'major') {
          target.unshift(`"${this.twelveTone[2]}m7"`)
          target.push(`"${this.twelveTone[0]}maj"`)
        } else {
          target.unshift(`"${this.twelveTone[2]}m7(b5)"`)
          target.push(`"${this.twelveTone[0]}m"`)
        }
      }
      return target
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
    toAbcString: function (tune) {
      var target = ''
      var newLineFlag = false
      Object.keys(tune).forEach(function (key) {
        if (tune[key]) {
          switch (key) {
            case 'title':
              target += `T:${tune[key]}`
              newLineFlag = true
              break
            case 'key':
              if (newLineFlag) target += '\n'
              target += `K:${tune[key]}`
              newLineFlag = true
              break
            case 'body':
              if (newLineFlag) target += '\n'
              target += tune[key]
              break
          }
        }
      })
      return target
    },
    tuneHash: function () {
      return {
        title: this.title,
        key: this.key,
        body: this.body,
      }
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
    async createScore() {
      if (!this.title || !this.body) {
        return null
      }
      const params = {
        title: this.title,
        key: this.key,
        body: this.body,
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
  },
}
</script>
