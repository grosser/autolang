Autolang
========

Goal
====
 - Kick-start your translation!
 - Translate all your Gettext - msgids to another language using google-translate.
 - Provide a simple interface for other translation tasks


Install
=======
sudo gem install googletranslate gettext

Copy the rake task anywhere OR use git:
git clone git://github.com/grosser/autolang.git


Usage
=====
Translate your pot file to any other language:

    # to translate into spanish (=es), when current apps name is myapp (from myapp.pot)
    L=es POT_FILE=/app/po/my_app.pot rake autolang:translate

Translation examples
====================
 - Car|Engine -> Motor
 - hello %{name} -> hallo %{name}


TODO
====
 - Make the Autolang class usable on its own (no ENV dependencies)
 - Do not convert "& to "and", use something 'smarter'.
