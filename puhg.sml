Prefix xsd:<http://www.w3.org/2001/XMLSchema#>
Prefix dcterms:<http://purl.org/dc/terms/>
Prefix dbpedia:<http://dbpedia.org/resource/>
Prefix ogcgs:<http://www.opengis.net/ont/geosparql#>

Create View microstation_structures As
    Construct {
        ?pit a ?type ;
            a ogcgs:Feature, <http://data.bureaudigitaalerfgoed.nl/def/Amenity>, ?type;
            dcterms:subject ?structuurtype ;
            dcterms:creator "Roos van Oosten", "Rein van t Veer" ;
            dcterms:source "Team Archeologie Haarlem", "Microstation-bestand" ;
            dcterms:isPartOf ?project ;
            dcterms:identifier ?identifier ;
            dcterms:rights <https://creativecommons.org/licenses/by-sa/3.0/> ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?pit = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/', ?structuurtype, '/', ?gid))
        ?type = uri(?URI)
        ?structuurtype = plainLiteral(?structuurtype)
        ?project = plainLiteral(?project)
        ?identifier = plainLiteral(concat(?project, ?text))
        ?geometry = typedliteral(?geometry, ogcgs:wktLiteral)
    From
        [[SELECT "microstation_putten".*, ST_AsText(ST_transform(the_geom, 4326)) As geometry FROM "microstation_putten";]]

Create View hbo_kron_structures As
    Construct {
        ?pit a ?type ;
            a ogcgs:Feature, <http://data.bureaudigitaalerfgoed.nl/def/Amenity>, ?type;
            dcterms:subject ?structuurtype ;
            dcterms:creator "Roos van Oosten", "Rein van t Veer", "Eefke Jacobs" ;
            dcterms:source ?source ;
            dcterms:isPartOf ?project ;
            dcterms:identifier ?identifier ;
            dcterms:rights <https://creativecommons.org/licenses/by-sa/3.0/> ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?pit = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/', ?type_genormaliseerd, '/', ?id))
        ?type = uri(?URI)
        ?structuurtype = plainLiteral(?type_genormaliseerd)
        ?project = plainLiteral(?project)
        ?identifier = plainLiteral(concat(?project, ?structuurnaam))
        ?geometry = typedliteral(?geometry, ogcgs:wktLiteral)
        ?source = plainLiteral(?source)
    From
        [[SELECT "hbo_kron_structuren".*, ST_AsText(ST_transform(geometry, 4326)) As geometry FROM "hbo_kron_structuren";]]

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
