Autolang
========

 - Kick-start your translation!
 - Translate all your Gettext - msgids / json to another language using google-translate.

Usage
=====

`gem install autolang`

```Bash
autolang API_KEY /path/to/app.pot <language-code>
autolang API_KEY /path/to/app.pot es
autolang API_KEY /path/to/app.json es
```

language-code are 2 letter [ISO 639](http://en.wikipedia.org/wiki/List_of_ISO_639-1_codes) codes<br/>
if you have no .pot file, use gettext and updatepo first (google helps...)

Translation examples
====================
 - `Car|Engine` -> `Motor`
 - `hello %{name}` -> `hallo %{name}`

TODO
====
 - Do not convert "& to "and", use something 'smarter'.

Authors
=======
Original by [Chris Blackburn](cbciweb.com) released under MIT license

Enhanced by

 - [Michael Grosser](http://grosser.it)
 - [Hans Engel](http://engel.uk.to/)
