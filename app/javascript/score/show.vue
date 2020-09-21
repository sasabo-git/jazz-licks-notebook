<template lang="pug">
  .container
    .key-controle
      .columns
        .column
          .buttons
            button.button(v-on:click='transpose -= 1') キーを下げる
            button.button(v-on:click='transpose = 0') 原曲キー
            button.button(v-on:click='transpose += 1') キーを上げる
    .box.mt-4
      .score
        .columns.is-centered
          .column.is-10
            #paper
      .midi
        .columns.is-centered
          .column.is-10
            #midi-id
</template>

<script>
import 'font-awesome/css/font-awesome.min.css'
import 'abcjs/abcjs-midi.css'
import abcjs from 'abcjs/midi'
import _ from 'lodash'

export default {
  props: {
    scoreId: { type: String, required: true },
    firstLine: { type: Boolean, required: true },
  },
  data() {
    return {
      score: '',
      transpose: 0,
    }
  },
  watch: {
    transpose: _.debounce(function () {
      this.renderScore(this.score, this.transpose)
    }, 100),
  },
  async created() {
    await this.setScore()
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
        .then((json) => {
          this.score = this.toAbcString(json, this.firstLine)
          this.renderScore(this.score, this.transpose)
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    renderScore: function (score, transpose) {
      abcjs.renderAbc('paper', score, {
        visualTranspose: transpose,
        responsive: 'resize',
        paddingbottom: 0,
      })
      abcjs.renderMidi('midi-id', score, {
        midiTranspose: transpose,
        inlineControls: {
          loopToggle: true,
          tempo: true,
        },
      })
    },
    toAbcString: function (score, firstLine = false) {
      var header = ''
      var body = ''
      header += 'X:1\n'
      Object.keys(score).forEach(function (key) {
        if (score[key]) {
          switch (key) {
            case 'title':
              if (!firstLine) header += `T:${score[key]}\n`
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
            case 'body':
              if (firstLine) {
                var lines = score[key].split('\n')
                body = lines[0]
              } else {
                body = `${score[key]}`
              }
          }
        }
      })
      return header + body
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
  },
}
</script>
