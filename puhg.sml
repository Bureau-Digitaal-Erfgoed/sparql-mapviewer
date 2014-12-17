Prefix xsd:<http://www.w3.org/2001/XMLSchema#>
Prefix dcterms:<http://purl.org/dc/terms/>
Prefix dbpedia:<http://dbpedia.org/resource/>
Prefix ogcgs:<http://www.opengis.net/ont/geosparql#>
Prefix rdfs:<http://www.w3.org/2000/01/rdf-schema#>
Prefix skos:<http://www.w3.org/2004/02/skos/core#>
Prefix time:<http://www.w3.org/2006/time#> 
Prefix crm:<http://www.cidoc-crm.org/cidoc-crm/>
Prefix dicom:<http://purl.org/healthcarevocab/v1#>
Prefix bdedef: <http://data.bureaudigitaalerfgoed.nl/def/>

Create View cesspit_foundation_defs AS
    Construct {
        ?definition a skos:Concept ;
            skos:prefLabel ?description ;
            skos:altLabel ?alias, ?typedesignation ;
            dcterms:creator ?creator ;
            dcterms:created ?created ;
            dcterms:rights <https://creativecommons.org/licenses/by-sa/3.0/> .
    }
    With
        ?definition = uri(?URI)
        ?description = plainLiteral(?Omschrijving)
        ?alias = plainLiteral(?Alias)
        ?typedesignation = plainLiteral(?Type_aanduiding)
        ?creator = plainLiteral(?creator)
        ?created = plainLiteral(?created)
    From
        [[SELECT * FROM typologie_beerputonderkant;]]
            
Create View pit_defs AS
    Construct {
        ?definition a skos:Concept ;
            skos:prefLabel ?description ;
            skos:altLabel ?alias ;
            dcterms:creator ?creator ;
            dcterms:created ?created ;
            dcterms:rights <https://creativecommons.org/licenses/by-sa/3.0/> .
    }
    With
        ?definition = uri(?URI)
        ?description = plainLiteral(?definitie)
        ?alias = plainLiteral(?type)
        ?creator = plainLiteral(?creator)
        ?created = plainLiteral(?timestamp)
    From
        [[SELECT * FROM structuurtype;]]
        
Create View all_structure_descriptions AS
    Construct { 
        ?structure 
            a <http://data.bureaudigitaalerfgoed.nl/def/Archaeological_structure>, ?structuretype ;
            dcterms:creator "Roos van Oosten", "Rein van t Veer", "Eefke Jacobs" ;
            dcterms:contributor "Team Archeologie Haarlem", "Fenno Noij", "Svenja de Bruin" ;
            dcterms:rights <https://creativecommons.org/licenses/by-sa/3.0/> ;
            <http://data.bureaudigitaalerfgoed.nl/def/Primary_use> ?structuretype ;
            <http://data.bureaudigitaalerfgoed.nl/def/Secondary_use> ?secondarytype ;
            <http://data.bureaudigitaalerfgoed.nl/def/Excavated_in_year> ?excavationyear ;
            dcterms:spatial ?city, ?projectname ;
            dcterms:partOf ?projectcode, ?projectNormalized ;
            dcterms:subject ?structureAsReported, ?structureNumberAsReported, ?structureNameAsReported ;
            dcterms:source ?source ;
            crm:E57_material ?material ;
            dbpedia:Shape ?shape ;
            <http://dbpedia.org/resource/Foundation_(engineering)> ?foundation, ?foundationDescription ;
            dbpedia:Floor ?floortype ;
            dicom:InnerDiameter ?diameter ;
            time:intervalStarts ?startyear ;
            time:intervalFinishes ?endyear ;
            bdedef:Top_level ?measurementOfTopLevel ;
            bdedef:Bottom_level ?measurementOfBottomLevel ;
            bdedef:Reference_level dbpedia:Amsterdam_Ordnance_Datum ;
            bdedef:Smallest_brick_size ?smallestBrickSize ;
            bdedef:Largest_brick_size ?largestBrickSize ;
            dbpedia:Depth_in_a_well ?depth ;
            bdedef:Wealth ?wealth ;
            ogcgs:sfWithin ?parcel ;
            ogcgs:hasGeometry ?structureGeometry .
        ?structureGeometry 
            a ogcgs:Feature ;
            dcterms:date ?date ;
            dcterms:creator ?creator ;
            dcterms:source ?geometrySource ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?structure = uri(concat('http://data.bureaudigitaalerfgoed.nl/Archaeological_structure/', ?complex))
        ?structuretype = uri(?structuurtype_uri)
        ?secondarytype = uri(?structuurtype_secundair_uri)
        ?city = uri(concat('http://dbpedia.org/resource/', ?Stad))
        ?excavationyear = typedLiteral(?Jaar, xsd:integer)
        ?projectcode = plainLiteral(?Projectcode)
        ?projectname = plainLiteral(?Project)
        ?projectNormalized = plainLiteral(?Projectaanduiding_genormaliseerd)
        ?structureAsReported = plainLiteral(?Oorspronkelijke_benaming_structuur)
        ?structureNumberAsReported = plainLiteral(?Structuur_NR)
        ?structureNameAsReported = plainLiteral(?Structuurnaam_Haarlem)
        ?source = plainLiteral(?Rapportage)
        ?material = uri(concat('http://dbpedia.org/resource/', ?1_MATERIAAL))
        ?shape = plainLiteral(?1_VORM)
        ?foundation = uri(?fundering_uri)
        ?foundationDescription = plainLiteral(?2_Type_onderkant)
        ?floortype = uri(concat('http://data.bureaudigitaalerfgoed.nl/def/beerput/vloer/', ?1_Type_Vloer))
        ?diameter = typedLiteral(?diameter, xsd:integer)
        ?startyear = typedLiteral(?DATV, xsd:integer)
        ?endyear = typedLiteral(?DATL, xsd:integer)
        ?measurementOfBottomLevel = typedLiteral(?1_NAP_OK, xsd:decimal)
        ?measurementOfTopLevel = typedLiteral(?1_NAP_BK, xsd:decimal)
        ?smallestBrickSize = plainLiteral(?1_BS_formaat_kleinste)
        ?largestBrickSize = plainLiteral(?1_BS_formaat_grootste)
        ?depth = typedLiteral(?diepte, xsd:double)
        ?structureGeometry = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/Geometry/', ?Geometrie_koppeling))
        ?date = plainLiteral(?date)
        ?geometrySource = plainLiteral(?bron)
        ?creator = plainLiteral(?creator)
        ?wealth = plainLiteral(?welstand)
        ?parcel = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/cadastral_parcel_1832/', ?perceel_id))
        ?geometry = typedliteral(?wktgeom, ogcgs:wktLiteral)
    From 
        [[SELECT * FROM alle_structuurbeschrijvingen_view WHERE alle_structuurbeschrijvingen_view."Functie_structuur_primair" != 'nvt';]]

Create View cadastral_parcels As
    Construct {
        ?cadastral_parcel 
            a <http://data.bureaudigitaalerfgoed.nl/def/Cadastral_parcel> ;
            a ogcgs:Feature ;
            rdfs:label "Kadastraal perceel" ;
            bdedef:Wealth ?wealth ;
            dcterms:creator "Rein van t Veer" ;
            dcterms:created ?created ;
            dcterms:rights <https://creativecommons.org/licenses/by-sa/3.0/> ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?cadastral_parcel = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/cadastral_parcel_1832/', ?id))
        ?wealth = plainLiteral(?welstand)
        ?geometry = typedliteral(?wktgeom, ogcgs:wktLiteral)
        ?created = plainLiteral(?timestamp)
    From
        [[SELECT "percelen_1832_sociale_differentiatie_1629_view".*, ST_AsText(ST_transform(the_geom, 4326)) As wktgeom FROM "percelen_1832_sociale_differentiatie_1629_view";]]
       
Create View hbo_projects As
    Construct {
        ?project a <http://data.bureaudigitaalerfgoed.nl/def/Archaeological_project> ;
            a ogcgs:Feature ;
            rdfs:label ?id ;
            dcterms:creator ?creator ;
            dcterms:rights <https://creativecommons.org/licenses/by-sa/3.0/> ;
            dcterms:subject ?projectnaam ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?project = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/project/hbo/', ?id))
        ?id = plainLiteral(?id)
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
            dcterms:creator "Rein van t Veer", "Team Archeologie Haarlem" ;
            #dcterms:created ?created ;
            dcterms:subject ?projectnaam ;
            dcterms:rights <https://creativecommons.org/licenses/by-sa/3.0/> ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?id = plainLiteral(?id)
        ?project = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/project/microstation/', ?id))
        #?created = typedLiteral('2014-11-19T17:00:29', xsd:datetime)
        ?projectnaam = plainLiteral(?project)
        ?geometry = typedliteral(?wktgeom, ogcgs:wktLiteral)
    From
        [[SELECT microstation_projecten.*, ST_AsText(ST_transform(microstation_projecten.the_geom, 4326)) As wktgeom FROM microstation_projecten WHERE microstation_projecten.the_geom is not null;]]

Create View neighborhoods As
    Construct {
        ?neighborhood 
            a dbpedia:Neighborhood ;
            rdfs:label ?label ;
            dcterms:rights <https://creativecommons.org/licenses/by-sa/3.0/> ;
            dcterms:creator "Rein van t Veer" ;
            ogcgs:asWKT ?geometry .
    }
    With
        ?neighborhood = uri(concat('http://data.bureaudigitaalerfgoed.nl/puhg/buurt/', ?id))
        ?label = plainLiteral(concat('Wijk ', ?wijknaam))
        ?geometry = typedliteral(?wktgeom, ogcgs:wktLiteral)
    From
        [[SELECT haarlem_wijk.*, ST_AsText(ST_transform(haarlem_wijk.the_geom, 4326)) As wktgeom from haarlem_wijk;]]
        
