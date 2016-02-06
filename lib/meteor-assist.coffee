MeteorAssistView = require './meteor-assist-view'
{CompositeDisposable} = require 'atom'

module.exports = MeteorAssist =
  meteorAssistView: null
  modalPanel: null
  subscriptions: null
  config:
    precompInFolder:
      type: 'boolean'
      default: true
      title: 'Create template files in folder'
    stylesFormat:
      type: 'string'
      default: 'scss'
      enum: ['less','sass','css','scss']
    scriptFormat:
      type: 'string'
      default: 'javascript'
      enum: ['coffeescript', 'javascript']

  activate: (state) ->

    @meteorAssistView = new MeteorAssistView()

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add '.tree-view', 'meteor-assist:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @meteorAssistView.destroy()

  serialize: ->

  toggle: ->
    @meteorAssistView.show()
