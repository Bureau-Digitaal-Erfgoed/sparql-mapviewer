#!/bin/bash
NOW=$(date '+%d-%m-%Y_%H:%M:%S')
sparqlify -D -h localhost:5432 -d puhg -u $1 -p $2 -m ./puhg.sml > /opt/virtuoso/puhg_$NOW.n3 
if [ $? -eq 0 ] 
then 
/usr/local/virtuoso-opensource/bin/isql 1111 dba dba "EXEC=SPARQL CLEAR GRAPH <http://data.bureaudigitaalerfgoed.nl/puhg/>;"
/usr/local/virtuoso-opensource/bin/isql 1111 dba dba "EXEC=ld_dir('/opt/virtuoso/', 'puhg_$NOW.n3', 'http://data.bureaudigitaalerfgoed.nl/puhg/')"
/usr/local/virtuoso-opensource/bin/isql 1111 dba dba "EXEC=rdf_loader_run()"
fi
