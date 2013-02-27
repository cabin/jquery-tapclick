# A jQuery plugin that creates a new `tapclick` special event. `tapclick` is
# like like a normal `click` event, but avoids the 300ms click delay on touch
# devices. This plugin was based on Google's [Fast Buttons][], but with some
# extra smarts to handle delegated events.
#
# Elements listening for `tapclick` events will have the `tapclick` CSS class
# applied to them; useful for avoiding the default tap highlight on the context
# element for delegated events:
#
#     .tapclick {
#       -webkit-tap-highlight-color: transparent;
#     }
#
# [jQuery tapclick][] is copyright 2013 [Cabin][] and released under an
# MIT-style [license][].
#
# [jQuery tapclick]: http://github.com/cabin/jquery-tapclick
# [Cabin]: http://madebycabin.com/
# [license]: http://github.com/cabin/jquery-tapclick/blob/master/LICENSE.md
# [Fast Buttons]: https://developers.google.com/mobile/articles/fast_buttons

(($) ->
  EVENT_NAME = 'tapclick'

  # Save a reference to the `touchstart` coordinate and start listening to
  # `touchmove` and `touchend` events.
  onTouchStart = (event) ->
    $(this)
      .on("touchend.#{EVENT_NAME}", onClick)
      .on("touchmove.#{EVENT_NAME}", onTouchMove)
    touch = event.originalEvent.touches[0]
    @startX = touch.screenX
    @startY = touch.screenY

  # When a `touchmove` event is invoked, reset if the user has dragged past the
  # threshold of 10px.
  onTouchMove = (event) ->
    touch = event.originalEvent.touches[0]
    movedX = Math.abs(touch.screenX - @startX)
    movedY = Math.abs(touch.screenY - @startY)
    reset(this) if movedX > 10 or movedY > 10

  # Invoke the actual click handler and prevent ghost clicks if this was a
  # `touchend` event on an element with a handler for the special event. The
  # latter check is necessary to handle event delegation; we don't want to
  # absorb clicks on children of the delegated context element that aren't
  # receiving the special event.
  # `jQuery.event.dispatch` will set `event.currentTarget` to each handled
  # element, so to detect whether any handler was called, set it to `null`
  # before dispatching.
  onClick = (event) ->
    reset(this)
    wasTouch = event.type is 'touchend'
    event.type = EVENT_NAME
    event.currentTarget = null
    jQuery.event.dispatch.apply(this, arguments)
    if wasTouch and event.currentTarget
      event.stopPropagation()
      clickbuster.preventGhostClick(@startX, @startY)

  reset = (el) ->
    $(el).off("touchend.#{EVENT_NAME} touchmove.#{EVENT_NAME}")

  ## Clickbuster

  # Tracks touched coordinates and consumes matching click events within a
  # distance/time threshold.
  clickbuster =
    coordinates: []

    # Call `preventGhostClick` to bust all click events that happen within 25px
    # of the provided (x, y) coordinates in the next 2.5s.
    preventGhostClick: (x, y) ->
      clickbuster.coordinates.push([x, y])
      setTimeout(clickbuster.pop, 2500)

    pop: ->
      clickbuster.coordinates.shift()

    # If we catch a click event inside the given radius and time threshold then
    # we call `stopPropagation` and `preventDefault`, which will stop links
    # from being activated.
    onClick: (event) ->
      for [x, y] in clickbuster.coordinates
        movedX = Math.abs(event.screenX - x)
        movedY = Math.abs(event.screenY - y)
        if movedX < 25 and movedY < 25
          event.stopPropagation()
          event.preventDefault()

  # Ignore old browsers, since clickbusting is only necessary for touch events
  # and we need `useCapture`.
  if document.addEventListener
    document.addEventListener('click', clickbuster.onClick, true)

  ## Custom event

  # Adds/removes listeners and `tapclick` class.
  jQuery.event.special[EVENT_NAME] =
    setup: ->
      $(this).addClass(EVENT_NAME)
        .on("touchstart.#{EVENT_NAME}", onTouchStart)
        .on("click.#{EVENT_NAME}", onClick)
    teardown: ->
      $(this).removeClass(EVENT_NAME)
        .off(".#{EVENT_NAME}")
)(jQuery)
