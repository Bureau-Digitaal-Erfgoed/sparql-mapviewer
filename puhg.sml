Prefix xsd:<http://www.w3.org/2001/XMLSchema#>
Prefix dcterms:<http://purl.org/dc/terms/>
Prefix dbpedia:<http://dbpedia.org/resource/>
Prefix ogcgs:<http://www.opengis.net/ont/geosparql#>
Prefix rdfs:<http://www.w3.org/2000/01/rdf-schema#>

Create View all_structure_descriptions AS
    Construct { 
        ?structure a <http://data.bureaudigitaalerfgoed.nl/def/Archaeological_structure>, ?primarytype ;
            <http://data.bureaudigitaalerfgoed.nl/def/Secondary_use> ?secondarytype ;
            <http://data.bureaudigitaalerfgoed.nl/def/Excavated_in_year> ?excavationyear;
            dcterms:partOf ?projectcode, ?projectname, ?project_normalized ;
            dcterms:subject ?structure_as_reported, ?structurenumber_as_reported ;
            ogcgs:hasGeometry ?structureGeometry ;
            dcterms:source ?source ;
            <http://schema.org/startDate> ?startdate ;
            <http://schema.org/endDate> ?enddate ;
            dcterms:spatial ?stad .
    }
    With
        ?structure = uri(concat('http://data.bureaudigitaalerfgoed.nl/def/Archaeological_structure/', ?complex))
        ?primarytype = uri(concat('http://data.bureaudigitaalerfgoed.nl/def/', ?Functie_structuur_primair))
        ?secondarytype = uri(concat('http://data.bureaudigitaalerfgoed.nl/def/', ?Functie_structuur_secundair))
        ?excavationyear = typedLiteral(?Jaar, xsd:gYear)
        ?projectcode = plainLiteral(?Projectcode)
        ?projectname = plainLiteral(?Project)
        ?project_normalized = plainLiteral(?Projectaanduiding_genormaliseerd)
        ?structureGeometry = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/Geometry/', ?Geometrie_koppeling))
        ?structure_as_reported = plainLiteral(?Oorspronkelijke_benaming_structuur)
        ?structurenumber_as_reported = plainLiteral(?Structuur_NR)
        ?source = plainLiteral(?Rapportage)
        ?startdate = typedLiteral(?DATV, xsd:gYear)
        ?enddate = typedLiteral(?DATL, xsd:gYear)
        ?stad = uri(concat('http://dbpedia.org/resource/', ?Stad))
    From 
    [[SELECT *
    FROM alle_structuurbeschrijvingen_view WHERE "Functie_structuur_primair" != 'nvt';]]


Create View all_structure_geometries As
    Construct {
        ?structure a ?type ;
            a ogcgs:Feature, ?type ;
            rdfs:label ?label ;
            dcterms:subject ?structuurtype ;
            dcterms:creator "Roos van Oosten", "Rein van t Veer", "Eefke Jacobs" ;
            dcterms:contributor "Team Archeologie Haarlem", "Fenno Noij", "Svenja de Bruin" ;
            dcterms:date ?date ;
            dcterms:isPartOf ?project, ?source ;
            dcterms:rights <https://creativecommons.org/licenses/by-sa/3.0/> ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?structure = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/Geometry/', ?id))
        ?source = plainLiteral(?bron)
        ?type = uri(?structuurtypeuri)
        ?structuurtype = plainLiteral(?structuurtype)
        ?date = plainLiteral(?date)
        ?project = plainLiteral(?projectnaam)
        ?label = plainLiteral(concat(?projectnaam, ", ", ?structuurnaam))
        ?geometry = typedliteral(?geometry, ogcgs:wktLiteral)
    From
        [[SELECT 
            alle_structuren_view.id, 
            alle_structuren_view.bron, 
            alle_structuren_view.nummer, 
            alle_structuren_view.structuurtype, 
            alle_structuren_view.structuurtypeuri, 
            alle_structuren_view.structuurnaam, 
            alle_structuren_view.date, 
            alle_structuren_view.creator, 
            alle_structuren_view.projectnaam, 
            ST_AsText(ST_transform(alle_structuren_view.the_geom, 4326)) As geometry 
        FROM alle_structuren_view;]]


Create View cadastral_parcels As
    Construct {
        ?cadastral_parcel a <http://data.bureaudigitaalerfgoed.nl/def/Cadastral_parcel>;
            rdfs:label "Kadastraal perceel" ;
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
            #dcterms:created ?created ;
            dcterms:subject ?projectnaam ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?id = plainLiteral(?id)
        ?project = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/project/', ?id))
        #?created = typedLiteral('2014-11-19T17:00:29', xsd:datetime)
        ?projectnaam = plainLiteral(?project)
        ?geometry = typedliteral(?wktgeom, ogcgs:wktLiteral)
    From
        [[SELECT microstation_projecten.*, ST_AsText(ST_transform(microstation_projecten.the_geom, 4326)) As wktgeom FROM microstation_projecten WHERE microstation_projecten.the_geom is not null;]]
