# import de la liste des communes
# en attendant la mise à disposition officielle du COG de l'INSEE, c'est le fichier de la DGCL qui est utilisé (contenu identique)

cd ../data/
wget -nc http://www.collectivites-locales.gouv.fr/files/files/epcicom2015.csv

# extraction du code insee, du nom de la commune et de la population
csvcut -e iso-8859-1 -c 10,12,13 epcicom2015.csv -d ";" > cog_temp.csv

# import dans postgres
psql -c "drop table if exists cog_temp;create table cog_temp (insee text, nom text, population numeric);"
psql -c "\copy cog_temp from cog_temp.csv with (format csv, header true);"
psql -c "create index cog_temp_insee on cog_temp using spgist (insee);"

# COG 2014 de l'INSEE
wget -nc http://www.insee.fr/fr/methodes/nomenclatures/cog/telechargement/2014/txt/comsimp2014.zip
unzip -o comsimp2014.zip
# conversion en CSV UTF-8
cat comsimp2014.txt | iconv -f iso88591 -t utf8 | tr '\t' ',' > comsimp2014.csv

psql -c "drop table if exists insee_cog_2014;create table insee_cog_2014 (CDC text,CHEFLIEU text,REG text,DEP text,COM text,AR text,CT text,TNCC text,ARTMAJ text,NCC text,ARTMIN text,NCCENR text);"
psql -c "\copy insee_cog_2014 from comsimp2014.csv with (format csv, header true);"
psql -c "alter table insee_cog_2014 add column insee text; update insee_cog_2014 set insee=dep||com;"
psql -c "create index insee_cog_2014_insee on insee_cog_2014 using spgist(insee);"
psql -c "update insee_cog_2014 set nccenr='Fœil' where insee='22059';" # problème d'encodage dans le fichier source ?

# liste des départements (n° région, n° département, nom)
csvcut -e iso-8859-1 -c 1,2,6 -t depts2014.txt > depts2014.csv
psql -c "drop table if exists cog_dep;create table cog_dep (reg text, dep text, nom_dep text);"
psql -c "\copy cog_dep from depts2014.csv with (format csv, header true);"
psql -c "create index cog_dep_dep on cog_dep using spgist (dep);"

# liste des régions (n° région nom)
csvcut -e iso-8859-1 -c 1,5 -t reg2015.txt > reg2015.csv
psql -c "drop table if exists cog_reg;create table cog_reg (reg text, nom_reg text);"
psql -c "\copy cog_reg from reg2015.csv with (format csv, header true);"
psql -c "create index cog_reg_reg on cog_reg using spgist (reg);"

# COG 2015 de l'INSEE
wget -nc http://www.insee.fr/fr/methodes/nomenclatures/cog/telechargement/2015/txt/comsimp2015.zip
unzip -o comsimp2015.zip
# conversion en CSV UTF-8
cat comsimp2015.txt | iconv -f iso88591 -t utf8 | tr '\t' ',' > comsimp2015.csv

psql -c "drop table if exists insee_cog_2015;create table insee_cog_2015 (CDC text,CHEFLIEU text,REG text,DEP text,COM text,AR text,CT text,TNCC text,ARTMAJ text,NCC text,ARTMIN text,NCCENR text);"
psql -c "\copy insee_cog_2015 from comsimp2015.csv with (format csv, header true);"
psql -c "alter table insee_cog_2015 add column insee text; update insee_cog_2015 set insee=dep||com;"
psql -c "create index insee_cog_2015_insee on insee_cog_2015 using spgist(insee);"
psql -c "update insee_cog_2015 set nccenr='Fœil' where insee='22059';" # problème d'encodage dans le fichier source ?



# liste des régions 2016 (noms temporaires !)
wget -nc https://www.insee.fr/fr/statistiques/fichier/2114819/reg2016-txt.zip
unzip reg2016-txt.zip
cat reg2016.txt | iconv -f iso88591 -t utf8 | tr '\t' ',' > reg2016.csv
mv reg2016.csv ../data/insee/
rm reg2016*

psql -c "drop table if exists insee_regions_2016;create table insee_regions_2016 (REGION text,CHEFLIEU text,TNCC text,NCC text,NCCENR text);"
psql -c "\copy insee_regions_2016 from ../data/insee/reg2016.csv with (format csv, header true);"

# liste des départements 2016 (et appartenance aux régions)
wget -nc https://www.insee.fr/fr/statistiques/fichier/2114819/depts2016-txt.zip
unzip depts2016-txt.zip
cat depts2016.txt | iconv -f iso88591 -t utf8 | tr '\t' ',' > depts2016.csv
mv depts2016.csv ../data/insee/
rm depts2016*

psql -c "drop table if exists insee_depts_2016;create table insee_depts_2016 (REGION text ,DEP text,CHEFLIEU text,TNCC text,NCC text,NCCENR text);"
psql -c "\copy insee_depts_2016 from ../data/insee/depts2016.csv with (format csv, header true);"
