{CompositeDisposable} = require 'atom'
{View} = require 'atom-space-pen-views'
FileSystem = require 'fs'

module.exports =
class optionsView extends View

  @content: ->
    @div =>
      @div class: 'overlay from-top panel', outlet: 'optionsView', =>
        @div class: 'panel-heading', 'Configure Run Options'
        @div class: 'panel-body padded', =>
          @div class: 'block', =>
            @label 'Task name:'
            @select
              id: 'task-name-select'
          @div class: 'block', =>
            css = 'btn inline-block-tight'
            @button class: "btn #{css}", click: 'close', 'Save & Close'

  initialize: (@runOptions = {}) ->
    @readTasksFile()

    @runOptions.taskName = Object.keys(@tasks)[0]
    @runOptions.task = @tasks[@runOptions.taskName]

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace',
      'core:cancel': => @toggleOptions('hide')
      'core:close': => @toggleOptions('hide')
      'u2i-hackathon-teaser:close-options': => @toggleOptions('hide')
      'u2i-hackathon-teaser:configure': => @toggleOptions()
      'u2i-hackathon-teaser:save-options': => @saveOptions()
    atom.workspace.addTopPanel(item: this)
    @toggleOptions 'hide'

  toggleOptions: (command) ->
    switch command
      when 'show'
        @readTasksFile()
        @_updateSelectTag()
        @show()
      when 'hide'
        @optionsView.hide()
      else
        @readTasksFile()
        @_updateSelectTag()
        @optionsView.toggle()

  readTasksFile: ->
    @tasks = JSON.parse(FileSystem.readFileSync(process.env['HOME'] + "/u2i-hackathon-tasks.json", 'utf8')).tasks

  attached: ->
    @_updateSelectTag()

  saveOptions: ->
    @runOptions.taskName = @_getSelectTag().selectedOptions[0].value
    @runOptions.task = @tasks[@runOptions.taskName]

  close: ->
    @saveOptions()
    @toggleOptions('hide')

  destroy: ->
    @subscriptions?.dispose()

  workspaceView: ->
    atom.views.getView(atom.workspace)

  _getSelectTag: ->
    document.getElementById('task-name-select')

  _updateSelectTag: ->
    selectTag = @_getSelectTag()
    selectTag.innerHTML = ""

    for taskName in Object.keys(@tasks)
      optionElem = document.createElement('option')
      optionElem.value = taskName
      optionElem.appendChild(document.createTextNode(taskName))
      selectTag.appendChild(optionElem)
