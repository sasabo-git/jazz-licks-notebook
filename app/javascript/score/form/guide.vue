<template lang="pug">
  article.guide.message.is-light
    .message-header
      | 作曲ガイド
      button.button.is-warning.is-light.is-small(v-on:click='showGuide')
        | {{ showOrHide }}
    .message-body(v-show='show')
      .columns
        .column.is-4
          .check-boxes
            .columns.is-multiline
              label(v-for='guide in guides')
                .column
                  .check-box.is-fullwidth
                    input.guides(type='checkbox', :value='guide.value', v-model='checkedGuides')
                    | {{ guide.text }}
        .column
          p.abc-guide
            #guide
</template>

<script>
import config from './form_const'
import formMixin from './form_mixin'
import 'font-awesome/css/font-awesome.min.css'
import 'abcjs/abcjs-midi.css'
import abcjs from 'abcjs/midi'
import _ from 'lodash'

export default {
  mixins: [formMixin],

  // mixinで使うので必要
  props: {
    chordProgression: { type: String, required: true },
    keynote: { type: String, required: true },
    tonality: { type: String, required: true },
  },

  data() {
    return {
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
      show: false,
      showOrHide: '表示',
      guide: {},
    }
  },

  computed: {
    guideTone: function () {
      let guideTones = []
      if (this.chordProgression.length !== '' && this.checkedGuides.length) {
        this.chords.forEach((code) => {
          let guideTone = code
          this.checkedGuides.forEach((guide) => {
            guideTone += this.availableNote(code, guide)
          })
          guideTones.push(guideTone)
        })
      }
      return `K:${this.key}\n` + guideTones.join('|') + '|'
    },
  },

  watch: {
    guideTone: _.debounce(function () {
      abcjs.renderAbc('guide', this.guideTone, {
        staffwidth: 650,
        paddingright: 15,
        responsive: 'resize',
      })
    }, 300),
  },

  methods: {
    availableNote: function (code, toneName) {
      let octaveUp = false
      const keynote = code.match(/[A-Z]/g).join('')
      const diatonic = this.sortByKey(config.SEVENTONES, this.keynote)
      const scales = this.sortByKey(diatonic, keynote).map(function (tone, i) {
        if (i > 0 && tone === 'C') octaveUp = true
        return octaveUp ? tone.toLowerCase() : tone
      })
      let availableNote = ''
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

    showGuide: function () {
      this.show = !this.show
      this.showOrHide = this.show ? '非表示' : '表示'
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
  },
}
</script>
