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
  url: "//api.jenna-arts.com"

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
    if app.projectsView.isMobile()

      for slideUp in $("[aboutSlideUp]")
        animate.fromTo $(slideUp), .6, {alpha: 0, y: "0%"}, {alpha: 1, y: "0%", delay: $(slideUp).attr("aboutSlideUp"), ease: Power4.easeOut}
    else
      for slideUp in $("[aboutSlideUp]")
        animate.fromTo $(slideUp), .6, {alpha: 0, y: "100%"}, {alpha: 1, y: "0%", delay: $(slideUp).attr("aboutSlideUp"), ease: Power4.easeOut}

class singleView extends Base.View

  el: "[single]"

  initialize: ->
    animate.set @el, {alpha: 0, pointerEvents: "none"}

  transIn: (id) ->
    image = new Image()

    $("[single='picture']").removeClass "active"
    animate.set $("[single='zoom']"), {alpha: 1}
    @$el.html(singleTemplate({"project": app.projectsCollection.models[id]}))
    animate.set @el, {alpha: 1, pointerEvents: "all"}

    for slideUp in $("[singleSlideUp]")
      animate.fromTo $(slideUp), .6, {alpha: 0, y: "100%"}, {alpha: 1, y: "0%", delay: $(slideUp).attr("aboutSlideUp"), ease: Power4.easeOut}

    if app.projectsView.isMobile()
      $("[single='picture']").addClass "active"
      animate.fromTo $("[single='background']"), .4, {x: "100%"}, {x: "0%", ease: Power2.easeOut}
      animate.fromTo $("[single='picture']"), .4, {alpha: 0}, {alpha: 1, ease: Power2.easeOut}

    else
      animate.fromTo $("[single='background']"), .5, {x: "100%"}, {x: "0%", ease: Power4.easeOut}
      animate.fromTo $("[single='picture']"), .5, {x: "100%"}, {x: "0%", alpha: 1, ease: Power3.easeOut}

      $(image).on("load", =>

        if $("[single='picture']").get(0).clientHeight / $("[single='picture']").get(0).scrollHeight is 1
          animate.to $("[single='zoom']"), .4, {alpha: 0 }
        else
          $("[single='zoom']").text "Scroll down"
          $("[single='picture']").scroll -> animate.to $("[single='zoom']"), .4, {alpha: 0 }

        $("[single='picture']").addClass "active"
      )


    image.src = app.projectsCollection.models[id].get("imageLarge")

  onScrollImage: ->
    alert "test"
    animate.to $("[single='zoom']"), 4, {alpha: 0 }





  transOut: ->


    for elem in $("[singleSlideUp]")
      animate.to $(elem), .2, {alpha: 0, delay: 0}
    if app.projectsView.isMobile()
        animate.fromTo $("[single='background']"), .1, {alpha: 1}, {alpha: 0, delay: .1, ease: Power4.easeOut, onComplete: =>
          animate.set @el, {alpha: 0, pointerEvents: "none"}
        }
        animate.fromTo $("[single='picture']"), .4, {alpha: 1}, {alpha: 0, ease: Power4.easeOut}
    else
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

      length = app.projectsCollection.models.length
      perc = 100 / parseInt(length)
      preloadBar = $("[preloader='bar']")
      for project, val in app.projectsCollection.models
        image = new Image()
        image.src = project.get("image")
        $(image).on("load", =>
          animate.to preloadBar, .4, {width: val * perc + perc + "%"}
          if val is length then $("[preloader]").addClass "hide"
        )


      app.router = new Router()
      Base.history.start()
