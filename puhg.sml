Prefix xsd:<http://www.w3.org/2001/XMLSchema#>
Prefix dcterms:<http://purl.org/dc/terms/>
Prefix dbpedia:<http://dbpedia.org/resource/>
Prefix ogcgs:<http://www.opengis.net/ont/geosparql#>

Create View microstation_cesspits As
    Construct {
        ?pit a ?type ;
            a ogcgs:Feature ;
            a <http://data.bureaudigitaalerfgoed.nl/def/Cesspit>;
            dcterms:subject ?structuurtype ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?pit = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/cesspit/', ?gid))
        ?type = uri(?URI)
        ?structuurtype = plainLiteral(?structuurtype)
        ?geometry = typedliteral(?geometry, ogcgs:wktLiteral)
    From
        [[SELECT "Haarlem_putten".*, ST_AsText(ST_transform(the_geom, 4326)) As geometry FROM "Haarlem_putten" WHERE "Haarlem_putten".structuurtype='Beerput';]]

Create View cadastral_parcels As
    Construct {
        ?cadastral_parcel a <http://data.bureaudigitaalerfgoed.nl/def/Cadastral_parcel>;
            a ogcgs:Feature;
            ogcgs:asWKT ?geometry .
    }
    With
        ?cadastral_parcel = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/cadastral_parcel_1832/', ?id))
        ?geometry = typedliteral(?geometry, ogcgs:wktLiteral)
    From
        [[SELECT "kadastrale_percelen_1832".*, ST_AsText(ST_transform(the_geom, 4326)) As geometry FROM "kadastrale_percelen_1832";]]
       
Create View hbo_projects As
    Construct {
        ?project a <http://data.bureaudigitaalerfgoed.nl/def/Archaeological_project> ;
            a ogcgs:Feature ;
            dcterms:creator ?creator ;
            dcterms:subject ?projectnaam ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?project = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/project/', ?id))
        ?creator = plainLiteral(?creator)
        ?projectnaam = plainLiteral(?project)
        ?geometry = typedliteral(?wktgeom, ogcgs:wktLiteral)
    From
        [[SELECT "projectlocaties".*, ST_AsText(ST_transform(geometry, 4326)) As wktgeom FROM "projectlocaties";]]
