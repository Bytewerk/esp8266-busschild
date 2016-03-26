Eine Busabfahrtszeitenanzeige für das bytewerk!
===============================================

Man nehme:
----------

1. Einen ESP8266 mit nodemcu-Firmware
2. Ein BA66-Kassendisplay
3. Stromversorgung, Pegelwandlung und sonstigen Feenstaub auf einem Stück Lochraster
4. ???
5. Profit!

Die Quelle der Daten
--------------------

Von der INVG wird [eine Haltestellensuche](http://invg.de/echtzeit) mit Echtzeit-Abfahrtszeitenanzeige angegeben.
Mittels der Entwicklungswerkzeuge eines modernen Webbrowsers kann die URL der JSON-Echtzeitdaten
aus [einer Ergebnisseite](http://www.invg.de/rt/showMultiple.action?station=IN-Klini&stopPoint=2&menuId=593&sid=273) extrahiert werden.
