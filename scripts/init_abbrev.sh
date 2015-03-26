psql -c "create table if not exists abbrev (txt_long text, txt_court text); truncate abbrev;"
psql -c "\copy abbrev from ../data/abbreviations.csv with (format csv, header true);"

