import '../stylesheets/application'
require('@rails/ujs').start()
require('@rails/activestorage').start()
require('channels')

require('score/index.js')
require('score/show.js')
require('score/form/form.js')

require('private_score/show.js')
