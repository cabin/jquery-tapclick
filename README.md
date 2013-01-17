A jQuery plugin that creates a new `tapclick` special event. `tapclick` is
like like a normal `click` event, but avoids the 300ms click delay on touch
devices. This plugin was based on Google's [Fast Buttons][], but with some
extra smarts to handle delegated events.

Elements listening for `tapclick` events will have the `tapclick` CSS class
applied to them; useful for avoiding the default tap highlight on the context
element for delegated events:

    .tapclick {
      -webkit-tap-highlight-color: transparent;
    }

[jQuery tapclick][] is copyright 2013 [Cabin][] and released under an
MIT-style [license][].

[jQuery tapclick]: http://github.com/cabin/jquery-tapclick
[Cabin]: http://madebycabin.com/
[license]: http://github.com/cabin/jquery-tapclick/blob/master/LICENSE.md
[Fast Buttons]: https://developers.google.com/mobile/articles/fast_buttons
