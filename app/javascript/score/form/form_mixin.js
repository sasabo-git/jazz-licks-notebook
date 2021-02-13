import config from './form_const'

export default {
  computed: {
    chords: function () {
      let chords = []
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

    twoFive: function () {
      let target = []
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

    twelveTones: function () {
      return this.keynote ? this.sortByKey(config.ALLTONES, this.keynote) : []
    },

    key: {
      get: function () {
        let key = ''
        if (this.keynote && this.tonality) {
          if (this.isMajor()) {
            key = this.keynote
          } else {
            key = `${this.keynote}m`
          }
        }
        return key
      },
    },
  },

  methods: {
    sortByKey: function (tones, keynote) {
      let target = []
      const index = tones.indexOf(keynote)
      target = tones.slice(index).concat(tones.slice(0, index))
      return target
    },

    isMajor: function () {
      return this.tonality === 'major'
    },

    isMinor: function () {
      return this.tonality === 'minor'
    },
  },
}
