<template lang="pug">
  .show-score
    #paper
</template>
<script>
import abcjs from 'abcjs'

export default {
  props: {
    scoreId: { type: String, required: true },
    firstLine: { type: Boolean, required: true },
  },
  data() {
    return {
      score: '',
    }
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
          abcjs.renderAbc('paper', this.score) // eslint-disable-line camelcase
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    toAbcString: function (score, firstLine = false) {
      var target = ''
      var body = ''
      Object.keys(score).forEach(function (key) {
        if (score[key]) {
          switch (key) {
            case 'title':
              target += `T:${score[key]}\n`
              break
            case 'key':
              target += `K:${score[key]}\n`
              break
            case 'body':
              if (firstLine) {
                var lines = score[key].split('\n')
                body = lines[0]
              } else {
                body = `${score[key]}\n`
              }
          }
        }
      })
      target += body
      return target
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
  },
}
</script>
