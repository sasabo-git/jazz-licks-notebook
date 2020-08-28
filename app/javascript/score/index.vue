<template lang="pug">
  .scores
    template(v-for="paper in papers")
      div(v-bind:id="paper")
</template>
<script>
import abcjs from 'abcjs'

export default {
  props: {
    firstLine: { type: Boolean, required: true },
  },
  data() {
    return {
      papers: [],
      abcString: '',
    }
  },
  async created() {
    await this.setScores()
  },
  updated() {
    this.$nextTick(() => {
      abcjs.renderAbc(this.papers, this.abcString)
    })
  },
  methods: {
    async setScores() {
      await fetch(`/api/scores.json`, {
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
        .then((scores) => {
          scores.forEach((score, i) => {
            this.papers.push(`paper${i}`)
            this.abcString += this.toAbcString(score, this.firstLine)
          })
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    toAbcString: function (score, firstLine = false) {
      var target = ''
      var body = ''
      target += 'X:1\n'
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
      target += body + '\n'
      return target
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
  },
}
</script>
