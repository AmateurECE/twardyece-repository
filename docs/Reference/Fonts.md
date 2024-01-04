# Fonts

Dealing with fonts on Linux is not intuitive. To view installed system fonts,
the application `gucharmap` is extremely helpful. This is part of the GNOME
project, and it is a graphical application.

To view fonts provided by an icon package, such as Font Awesome, select "View
by Unicode Block" in `gucharmap` and navigate to the `Private Use Area` block.

Other useful applications:

1. `fc-query`: Query the fonts that `fontconfig` knows about
2. `pango-view`: This appears to be a graphical application that can be used to
   view glyphs provided by a font, but it isn't compatible with Wayland.
3. `fc-list`: List fonts and styles available on the system for applications
   using fontconfig.
4. `fc-match`: Test a pattern against the fontconfig matching rules to figure
   out which fonts would be selected by an application (e.g. waybar).
