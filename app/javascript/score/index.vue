<template lang="pug">
  table.scores
    thead
      tr
        th タイトル
        th コード進行
        th 譜面
        th
    tbody
      tr.score(v-for="(paper, index) in papers" )
        td.title
          | {{ titles[index] }}
        td.chord-progression
          | {{ chordProgressions[index] }}
        td.paper(v-bind:id="paper")
        td
          a.link(:href="'/scores/' + ids[index]")
            | 詳細
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
      ids: [],
      titles: [],
      chordProgressions: [],
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
            this.$set(this.ids, i, score.id)
            this.$set(this.titles, i, score.title)
            this.$set(this.chordProgressions, i, score.chord_progression)
            this.papers.push(`paper${i}`)
            this.abcString += this.toAbcString(score, this.firstLine)
          })
        })
        .catch((error) => {
          console.warn('Failed to parsing', error)
        })
    },
    toAbcString: function (score, firstLine = false) {
      var header = ''
      var body = ''
      header += 'X:1\n'
      Object.keys(score).forEach(function (key) {
        if (score[key]) {
          switch (key) {
            case 'key':
              header += `K:${score[key]}\n`
              break
            case 'meter':
              header += `M:${score[key]}\n`
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
      return header + body + '\n'
    },
    token() {
      const meta = document.querySelector('meta[name="csrf-token"]')
      return meta ? meta.getAttribute('content') : ''
    },
  },
}
</script>
