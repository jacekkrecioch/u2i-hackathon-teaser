ConsoleRuntimeObserver = require './console-runtime-observer'
OptionsView = require './options-view'

{CompositeDisposable} = require 'atom'

module.exports =
  subscriptions: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @observer = new ConsoleRuntimeObserver()

    @runOptions = {}
    @optionsView = new OptionsView(@runOptions)

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'u2i-hackathon-teaser:run':
      => @run()

  deactivate: ->
    @subscriptions.dispose()
    @optionsView.close()


  consumeBlankRuntime: (runtime) ->
    @blankRuntime = runtime
    @blankRuntime.addObserver(@observer)

  activatePackage: (packageName) ->
    return if atom.packages.activePackages[packageName]?

    # There's no easy way to use PackageManager to force activate a package
    # As of 9.09.2015 this is the way to go
    pakage = atom.packages.loadPackage(packageName)

    throw new Error("Packaged not installed: '#{packageName}'") unless pakage?

    pakage.activateNow()

  run: ->
    @activatePackage('script')

    task = @runOptions.task
    if (task == undefined)
      atom.notifications.addError('Wrong task name!')
      return

    @observer.expectedOutput = task.output
    @blankRuntime.execute("File Based", task.input)
