# génération des exports BAN au format GML INSPIRE

OUT=ad_Address_$1.gml

echo '<?xml version="1.0" encoding="UTF-8"?>' > $OUT
echo -n '<gml:FeatureCollection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:gml="http://www.opengis.net/gml/3.2" xsi:schemaLocation="http://www.opengis.net/gml/3.2 http://schemas.opengis.net/gml/3.2.1/gml.xsd urn:x-inspire:specification:gmlas:Addresses:3.0 http://inspire.ec.europa.eu/schemas/ad/3.0/Addresses.xsd" timeStamp="' >> $OUT
echo -n `date -Iseconds` >> $OUT
echo '">' >> $OUT

psql -At -c "
select format('  <gml:member>
    <ad:Address xmlns:ad=\"urn:x-inspire:specification:gmlas:Addresses:3.0\" gml:id=\"AD_ADDRESS_FR_IGNF_BAN_%s\">
      <ad:inspireId>
        <base:Identifier xmlns:base=\"urn:x-inspire:specification:gmlas:BaseTypes:3.2\">
          <base:localId>%s</base:localId>
          <base:namespace>FR_IGNF_BDUniGE_Adresses_MET</base:namespace>
        </base:Identifier>
      </ad:inspireId>
      <ad:position>
        <ad:GeographicPosition>
          <ad:geometry owns=\"false\">
            <gml:MultiPoint gml:id=\"AD_ADDRESS_FR_IGNF_BAN_%s_AD_POSITION_0\" srsName=\"urn:ogc:def:crs:EPSG::4258\">
              <gml:pointMember>
                <gml:Point gml:id=\"GEOMETRY_%s\" srsName=\"urn:ogc:def:crs:EPSG::4258\">
                  <gml:pos>%s %s</gml:pos>
                </gml:Point>
              </gml:pointMember>
            </gml:MultiPoint>
          </ad:geometry>
          <ad:specification>parcel</ad:specification>
          <ad:method>fromFeature</ad:method>
          <ad:default>true</ad:default>
        </ad:GeographicPosition>
      </ad:position>
      <ad:status>current</ad:status>
      <ad:locator>
        <ad:AddressLocator>
          <ad:designator>
            <ad:LocatorDesignator>
              <ad:designator>%s</ad:designator>
              <ad:type>addressNumberExtension</ad:type>
            </ad:LocatorDesignator>
          </ad:designator>
          <ad:level>siteLevel</ad:level>
          <ad:withinScopeOf xmlns:xlink=\"http://www.w3.org/1999/xlink\" xlink:href=\"#AD_ADDRESSAREANAME_FR_IGNF_BAN_%s\"/>
        </ad:AddressLocator>
      </ad:locator>
      <ad:validFrom xsi:nil=\"true\" nilReason=\"unpopulated\"/>
      <ad:beginLifespanVersion xsi:nil=\"true\" nilReason=\"unpopulated\"/>
      <ad:parcel xsi:nil=\"true\"/>
      <ad:parentAddress/>
      <ad:building xsi:nil=\"true\"/>
      <ad:component xmlns:xlink=\"http://www.w3.org/1999/xlink\" xlink:href=\"#AD_ADMINUNITNAME_FR_IGNF_BAN_codeINSEE_FR\"/>
      <ad:component xmlns:xlink=\"http://www.w3.org/1999/xlink\" xlink:href=\"#AD_ADMINUNITNAME_FR_IGNF_BAN_codeINSEE_%s\"/>
      <ad:component xmlns:xlink=\"http://www.w3.org/1999/xlink\" xlink:href=\"#AD_ADDRESSAREANAME_FR_IGNF_BAN_%s\"/>
      <ad:component xmlns:xlink=\"http://www.w3.org/1999/xlink\" xlink:href=\"#AD_POSTALDESCRIPTOR_FR_IGNF_BAN_codepostal_%s\"/>
    </ad:Address>
  </gml:member>',
id,
id,
id,
ST_geohash(st_setsrid(st_makepoint(round(lon::numeric,6),round(lat::numeric,6)),4326)),
round(lat::numeric,6),
round(lon::numeric,6),
rep,
code_insee||'_'||regexp_replace(upper(unaccent(trim(nom_voie||' '||nom_ld))),'[^A-Z]','_','g'),
code_insee,
code_insee||'_'||regexp_replace(upper(unaccent(trim(nom_voie||' '||nom_ld))),'[^A-Z]','_','g'),
code_post

)
from ban_$1
order by id;
" >> $OUT
echo "</gml:FeatureCollection>" >> $OUT



OUT=ad_AddressAreaName_$1.gml

echo '<?xml version="1.0" encoding="UTF-8"?>' > $OUT
echo -n '<gml:FeatureCollection xmlns:gml="http://www.opengis.net/gml/3.2" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.opengis.net/gml/3.2 http://schemas.opengis.net/gml/3.2.1/gml.xsd urn:x-inspire:specification:gmlas:Addresses:3.0 http://inspire.ec.europa.eu/schemas/ad/3.0/Addresses.xsd" timeStamp="' >> $OUT
echo -n `date -Iseconds` >> $OUT
echo '">' >> $OUT

psql -At -c "
select format('  <gml:member>
    <ad:AddressAreaName xmlns:ad=\"urn:x-inspire:specification:gmlas:Addresses:3.0\" gml:id=\"AD_ADDRESSAREANAME_FR_IGNF_BAN_%s\">
      <ad:inspireId>
        <base:Identifier xmlns:base=\"urn:x-inspire:specification:gmlas:BaseTypes:3.2\">
          <base:localId>%s</base:localId>
          <base:namespace>FR_IGNF_BAN</base:namespace>
        </base:Identifier>
      </ad:inspireId>
      <ad:beginLifespanVersion xsi:nil=\"true\" nilReason=\"unpopulated\"/>
      <ad:status>current</ad:status>
      <ad:validFrom xsi:nil=\"true\" nilReason=\"unpopulated\"/>
      <ad:situatedWithin xmlns:xlink=\"http://www.w3.org/1999/xlink\" xlink:href=\"#AD_ADMINUNITNAME_FR_IGNF_BAN_codeINSEE_%s\"/>
      <ad:name>
        <gn:GeographicalName xmlns:gn=\"urn:x-inspire:specification:gmlas:GeographicalNames:3.0\">
          <gn:language>fra</gn:language>
          <gn:nativeness>endonym</gn:nativeness>
          <gn:nameStatus>official</gn:nameStatus>
          <gn:sourceOfName>BAN</gn:sourceOfName>
          <gn:pronunciation xsi:nil=\"true\" nilReason=\"unpopulated\"/>
          <gn:spelling>
            <gn:SpellingOfName>
              <gn:text>%s</gn:text>
              <gn:script xsi:nil=\"false\">Latn</gn:script>
              <gn:transliterationScheme xsi:nil=\"true\"/>
            </gn:SpellingOfName>
          </gn:spelling>
          <gn:grammaticalGender xsi:nil=\"true\" nilReason=\"unpopulated\"/>
          <gn:grammaticalNumber xsi:nil=\"true\" nilReason=\"unpopulated\"/>
        </gn:GeographicalName>
      </ad:name>
      <ad:namedPlace xsi:nil=\"true\"/>
    </ad:AddressAreaName>
  </gml:member>',
code_insee||'_'||regexp_replace(upper(unaccent(nom_ld)),'[^A-Z]','_','g'),
code_insee||'_'||regexp_replace(upper(unaccent(nom_ld)),'[^A-Z]','_','g'),
code_insee,
nom_ld
 )
from ban_$1
where nom_ld != ''
group by code_insee, nom_ld
order by code_insee;
" >> $OUT
echo "</gml:FeatureCollection>" >> $OUT


