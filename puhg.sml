Prefix xsd:<http://www.w3.org/2001/XMLSchema#>
Prefix dcterms:<http://purl.org/dc/terms/>
Prefix dbpedia:<http://dbpedia.org/resource/>
Prefix ogcgs:<http://www.opengis.net/ont/geosparql#>
Prefix rdfs:<http://www.w3.org/2000/01/rdf-schema#>

Create View microstation_structures As
    Construct {
        ?pit a ?type ;
            a ogcgs:Feature, <http://data.bureaudigitaalerfgoed.nl/def/Amenity>, ?type;
            rdfs:label ?identifier ;
            dcterms:subject ?structuurtype ;
            dcterms:created ?created ;
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
        ?created = typedLiteral('2014-11-17T16:34:22', xsd:datetime)
        ?structuurtype = plainLiteral(?structuurtype)
        ?project = plainLiteral(?project)
        ?identifier = plainLiteral(concat(?project, ?text))
        ?geometry = typedliteral(?geometry, ogcgs:wktLiteral)
    From
        [[SELECT "microstation_putten".*, ST_AsText(ST_transform("microstation_putten".the_geom, 4326)) As geometry FROM "microstation_putten";]]

Create View hbo_kron_structures As
    Construct {
        ?pit a ?type ;
            a ogcgs:Feature, <http://data.bureaudigitaalerfgoed.nl/def/Amenity>, ?type;
            rdfs:label ?identifier ;
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
        ?source = plainLiteral(?bron)
    From
        [[SELECT "hbo_kron_structuren".*, ST_AsText(ST_transform("hbo_kron_structuren".the_geom, 4326)) As geometry FROM "hbo_kron_structuren";]]

Create View cadastral_parcels As
    Construct {
        ?cadastral_parcel a <http://data.bureaudigitaalerfgoed.nl/def/Cadastral_parcel>;
            rdfs:label 'Kadastraal perceel'@nl ;
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
            rdfs:label ?id ;
            dcterms:creator ?creator ;
            dcterms:subject ?projectnaam ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?id = plainLiteral(?id)
        ?project = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/project/', ?id))
        ?creator = plainLiteral(?creator)
        ?projectnaam = plainLiteral(?project)
        ?geometry = typedliteral(?wktgeom, ogcgs:wktLiteral)
    From
        [[SELECT hbo_projecten.*, ST_AsText(ST_transform(hbo_projecten.the_geom, 4326)) As wktgeom FROM hbo_projecten;]]

Create View microstation_projects As
    Construct {
        ?project a <http://data.bureaudigitaalerfgoed.nl/def/Archaeological_project> ;
            a ogcgs:Feature ;
            rdfs:label ?id ;
            dcterms:creator "Rein van t Veer" ;
            dcterms:created ?created ;
            dcterms:subject ?projectnaam ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?id = plainLiteral(?gid)
        ?project = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/project/', ?gid))
        ?created = typedLiteral('2014-11-19T17:00:29', xsd:datetime)
        ?projectnaam = plainLiteral(?project)
        ?geometry = typedliteral(?wktgeom, ogcgs:wktLiteral)
    From
        [[SELECT microstation_projecten.*, ST_AsText(ST_transform(microstation_projecten.the_geom, 4326)) As wktgeom FROM microstation_projecten;]]