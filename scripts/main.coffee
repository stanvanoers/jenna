# Dependencies
$ = require("jquery")
_  = require("underscore")
Base = require("backbone")

# Templates
projectsDesktopTemplate = require("./../structure/templates/projectsDesktop.pug")
projectsMobileTemplate = require("./../structure/templates/projectsMobile.pug")

# projectsCollection
class projectsCollection extends Base.Collection
  url: "./projects.json"

# projectsView
class projectsView extends Base.View

  el: "[projects]"
  breakpoint: 680

  initialize: ->
    @render()
    $(window).resize => @render()

  isMobile: =>
    if $(window).width() > @breakpoint then return false
    return true

  getDataColumns: (cols) =>
      array = {}
      i = 0
      while i < cols
        array["col#{i}"] = _.filter(app.projectsCollection.models, (item, index) -> index % cols == i)
        i++
      return array

  render: =>
    if @isMobile() then @$el.html(projectsMobileTemplate(@getDataColumns(2)))
    else @$el.html(projectsDesktopTemplate(@getDataColumns(3)))


app = window || {}

# On window Ready
$ ->
  app.projectsCollection = new projectsCollection()
  app.projectsCollection.fetch
    success: ->
      app.projectsView = new projectsView()
