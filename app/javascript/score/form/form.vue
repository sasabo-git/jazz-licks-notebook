<template lang="pug">
  .container
    router-view(:scoreId='scoreId' :userSignedIn='userSignedIn', :store='store')
</template>

<script>
export default {
  props: {
    scoreId: { type: String, required: true },
    userSignedIn: { type: Boolean, required: true },
  },

  data() {
    return {
      title: '',
      keynote: 'C',
      tonality: 'major',
      melody: '',
      meter: '4/4',
      chordProgression: 'free',
      bpm: 120,
      noteLength: '8',
      memo: '',
      tune: '',
      key: '',
      body: '',

      // scoreで状態を管理する。状態変更はstore内の関数を使って更新する。なんちゃってRedux。
      store: {
        states: {
          title: '',
          keynote: 'C',
          tonality: 'major',
          melody: '',
          meter: '4/4',
          chordProgression: 'free',
          bpm: 120,
          noteLength: '8',
          memo: '',
        },
        setBasicScoreInformations(states) {
          this.states.title = states.title
          this.states.keynote = states.keynote
          this.states.tonality = states.tonality
          this.states.chordProgression = states.chordProgression
          this.states.meter = states.meter
          this.states.noteLength = states.noteLength
          this.states.memo = states.memo
        },
        setScoreBody(states) {
          this.states.melody = states.melody
          this.states.bpm = states.bpm
        },
      },
    }
  },

  watch: {
    tune: function (value) {
      this.setTuneElements(value)
      this.setStore()
    },
    key: function (value) {
      this.keynote = value.replace(/m/, '')
      this.tonality = value.includes('m') ? 'minor' : 'major'
      this.setStore()
    },
    body: function (value) {
      this.melody = value.replace(/".*?"/g, '')
      this.setStore()
    },
  },

  async created() {
    // 編集のときはsetScore()で値をセットする
    if (this.scoreId !== 'new') await this.setScore()
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
          let header = ''
          let body = ''
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
                case 'memo':
                  self.memo = score[key]
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

    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },

    setTuneElements: function (abcjs) {
      const elements = abcjs.split('\n')
      let body = ''
      let newLineFlag = false
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

    setStore() {
      this.store.setBasicScoreInformations({
        title: this.title,
        keynote: this.keynote,
        tonality: this.tonality,
        chordProgression: this.chordProgression,
        meter: this.meter,
        noteLength: this.noteLength,
        memo: this.memo,
      })
      this.store.setScoreBody({
        melody: this.melody,
        bpm: this.bpm,
      })
    },
  },
}
</script>
