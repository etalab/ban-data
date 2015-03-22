# import de la liste des communes
# en attendant la mise à disposition officielle du COG de l'INSEE, c'est le fichier de la DGCL qui est utilisé (contenu identique)

cd ../data/
wget -nc http://www.collectivites-locales.gouv.fr/files/files/epcicom2015.csv

# extraction du code insee, du nom de la commune et de la population
csvcut -e iso-8859-1 -c 10,12,13 epcicom2015.csv -d ";" > cog_temp.csv

# import dans postgres
psql -c "
drop table if exists cog_temp;

create table cog_temp (insee text, nom text, population numeric);
\copy cog_temp from cog_temp.csv with (format csv, header true);

create index cog_temp_insee on cog_temp using spgist (insee);
"

