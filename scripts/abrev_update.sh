
# suppression des mot doublés
psql -c "UPDATE libelles SET court=regexp_replace(court,' ([A-Z0-9]+) \1 ',' \1 ','g') WHERE court ~ ' ([A-Z0-9]+) \1 ';"

# génération et exécution de requêtes UPDATE
psql -Atc "select format(E'UPDATE libelles SET court=regexp_replace(court,\'%s\',\'%s\') WHERE court ~ \'%s \';', '(^| )'||txt_long||' ', '\1'||txt_court||' ',txt_long) from abbrev WHERE txt_long!=txt_court order by length(txt_long) desc;" | psql

# suppression des articles
psql -c "UPDATE libelles SET court=regexp_replace(court,' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ',' ','g') WHERE court ~ ' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ';"
psql -c "UPDATE libelles SET court=regexp_replace(court,' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ',' ','g') WHERE court ~ ' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ';"
psql -c "UPDATE libelles SET court=regexp_replace(court,' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ',' ','g') WHERE court ~ ' (DE|DU|DE LA|DE L|D|L|DES|AU|AUX|A|ET|DIT|DITE|EN) ';"

# simplification des XXième, ème, er...
psql -c "UPDATE libelles SET court=regexp_replace(court,' ([0-9]+)(IE|E)[A-Z]+ ',' \1E ','g') WHERE court ~ ' ([0-9]+)(IE|E)[A-Z]+ ';"
psql -c "UPDATE libelles SET court=regexp_replace(court,' ([0-9]+)(IE|E)[A-Z]+ ',' \1E ','g') WHERE court ~ ' ([0-9]+)(IE|E)[A-Z]+ ';"
