<template lang="pug">
  .scores.box.mt-4
    table.table.is-narrow.is-hoverable.is-fullwidth
      thead
        tr
          th タイトル
          th 譜面
          th コード進行
      tbody
        tr.score(v-for="(paper, index) in papers")
          td.is-vcentered
            a.link(:href="'/scores/' + ids[index]")
              | {{ titles[index] }}
          td.paper(v-bind:id="paper")
          td.is-vcentered
            | {{ chordProgressions[index] }}
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
      abcjs.renderAbc(this.papers, this.abcString, {
        staffwidth: 650,
        paddingtop: 5,
        paddingbottom: 5,
        paddingright: 5,
      })
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
      let header = ''
      let body = ''
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
            case 'body':
              if (firstLine) {
                let lines = score[key].split('\n')
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
