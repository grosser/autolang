Autolang
========

Goal
====
 - Kick-start your translation!
 - Translate all your Gettext - msgids to another language using google-translate.
 - Provide a simple interface for other translation tasks


Install
=======
Copy the rake task anywhere OR use git:
git clone git://github.com/grosser/autolang.git


Usage
=====
Translate your pot file to any other language:

    # to translate into spanish (=es), when current apps name is myapp (from myapp.pot)
    L=es APP_NAME=myapp rake autolang:translate

    # use something other than the default po folder:
    L=es APP_NAME=myapp PO_FOLDER=/apps/xy/l/po rake autolang:translate


Translation examples
====================
 - Car|Engine -> Motor
 - hello %{name} -> hallo %{name}


TODO
====
 - Make the Autolang class usable on its own (no ENV dependencies)
 - Convert output to UTF8 (for now, copy output in normal view to UTF8 editor -> problems solved)
 - Do not convert "& to &quot;&amp;.