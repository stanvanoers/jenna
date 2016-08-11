# Dependencies
$ = require("jquery")
_  = require("underscore")
Base = require("backbone")
animate = require("gsap")

# Templates
projectsDesktopTemplate = require("./../structure/templates/projectsDesktop.pug")
projectsMobileTemplate = require("./../structure/templates/projectsMobile.pug")
singleTemplate = require("./../structure/templates/singleTemplate.pug")

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
    if @isMobile() then $("[projects='container']").html(projectsMobileTemplate(@getDataColumns(2)))
    else $("[projects='container']").html(projectsDesktopTemplate(@getDataColumns(3)))

  onAboutAnimation: =>
    animate.fromTo @el, .6, {x: "0%", alpha: 1}, {x: "20%", alpha: .4, delay: .1, ease: Power3.easeOut}

  onSingleAnimation: =>
    animate.fromTo @el, .6, {x: "0%", alpha: 1}, {x: "-20%", alpha: .4, delay: .1, ease: Power3.easeOut}

  resetAnimation: =>
    animate.to @el, .4, {x: "0%", alpha: 1, ease: Power3.easeOut}



# About
class aboutView extends Base.View

  el: "[about]"
  initialize: ->
    animate.set @el, {alpha: 0, pointerEvents: "none"}

  transOut: ->

    for elem in $("[aboutSlideUp]")
      animate.to $(elem), .2, {alpha: 0, delay: 0}

    for elem in $("[aboutFadeIn]")
      animate.to $(elem), .2, {alpha: 0, delay: 0}

    animate.fromTo $("[about='background']"), .4, {x: "0%"}, {x: "-100%", ease: Power4.easeOut, onComplete: =>
      animate.set @el, {alpha: 0, pointerEvents: "none"}
    }

  transIn: =>
    animate.set @el, {alpha: 1, pointerEvents: "all"}
    animate.fromTo $("[about='background']"), .5, {x: "-100%"}, {x: "0%", ease: Power4.easeOut}
    for fadeIn in $("[aboutFadeIn]")
      animate.fromTo $(fadeIn), .6, {alpha: 0}, {alpha: 1, delay: $(fadeIn).attr("aboutFadeIn")}
    for slideUp in $("[aboutSlideUp]")
      animate.fromTo $(slideUp), .6, {alpha: 0, y: "100%"}, {alpha: 1, y: "0%", delay: $(slideUp).attr("aboutSlideUp"), ease: Power4.easeOut}

class singleView extends Base.View

  el: "[single]"

  initialize: ->
    animate.set @el, {alpha: 0, pointerEvents: "none"}

  transIn: (id) ->
    @$el.html(singleTemplate({"project": app.projectsCollection.models[id]}))
    animate.set @el, {alpha: 1, pointerEvents: "all"}
    animate.fromTo $("[single='background']"), .5, {x: "100%"}, {x: "0%", ease: Power4.easeOut}
    animate.fromTo $("[single='picture']"), .5, {x: "100%"}, {x: "0%", alpha: 1, ease: Power3.easeOut}

    for slideUp in $("[singleSlideUp]")
      animate.fromTo $(slideUp), .6, {alpha: 0, y: "100%"}, {alpha: 1, y: "0%", delay: $(slideUp).attr("aboutSlideUp"), ease: Power4.easeOut}

  transOut: ->

    for elem in $("[singleSlideUp]")
      animate.to $(elem), .2, {alpha: 0, delay: 0}
    animate.fromTo $("[single='background']"), .4, {x: "0%"}, {x: "100%", delay: .1, ease: Power4.easeOut, onComplete: =>
      animate.set @el, {alpha: 0, pointerEvents: "none"}
    }
    animate.fromTo $("[single='picture']"), .4, {x: "0%", alpha: 1}, {x: "100%", alpha: 0, ease: Power4.easeOut}

# Header
class headerView extends Base.Router
  el: "[header]"
  backButton: =>
    animate.fromTo $("[header='backbutton']"), .4, {y: "0%", alpha: 1}, {alpha: 0, y: "20%", onComplete: =>
      $("[header='backbutton']").html("<img src='./assets/icons/left-arrow.png', class='icon' /><p class='icon-text'> Go back</p>").attr("href", "/#/home")
      animate.fromTo $("[header='backbutton']"), .4, {y: "-20%", alpha: 0}, {alpha: 1, y: "0%"}
    }

  aboutButton: =>
    animate.fromTo $("[header='backbutton']"), .4, {y: "0%", alpha: 1}, {alpha: 0, y: "-20%", onComplete: =>
      $("[header='backbutton']").html("About").attr("href", "/#/about")
      animate.fromTo $("[header='backbutton']"), .4, {y: "20%", alpha: 0}, {alpha: 1, y: "0%"}
    }

# Router
class Router extends Base.Router
  goHome: ->
    @navigate("home", true)
  routes:

    "about": ->
      app.aboutView.transIn()
      app.projectsView.onAboutAnimation()
      app.headerView.backButton()

    "single/:id": (id) ->
      app.projectsView.onSingleAnimation()
      app.singleView.transIn(id)
      app.headerView.backButton()


    "home": ->
      app.aboutView.transOut()
      app.singleView.transOut()
      app.projectsView.resetAnimation()
      app.headerView.aboutButton()

    "*path": -> @goHome()

app = window || {}

# On window Ready
$ ->
  app.projectsCollection = new projectsCollection()
  app.projectsCollection.fetch
    success: ->
      app.projectsView = new projectsView()
      app.singleView = new singleView()
      app.aboutView = new aboutView()
      app.headerView = new headerView()

      app.router = new Router()
      Base.history.start()
