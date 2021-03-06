/*jshint es3: false, maxerr: 10000, jquery: true*/
var feature;

// QueryString IIFE function assignes parameters to QueryString var
// Thanks to http://stackoverflow.com/questions/979975/how-to-get-the-value-from-url-parameter
// http://stackoverflow.com/users/19068/quentin
var QueryString = function () {
	'use strict';
	var query_string = {};
	var query = window.location.search.substring(1);
	var vars = query.split("&");
	for (var i=0;i<vars.length;i++) {
		var pair = vars[i].split("=");
		// If first entry with this name
		if (typeof query_string[pair[0]] === "undefined") {
			query_string[pair[0]] = pair[1];
			// If second entry with this name
		} else if (typeof query_string[pair[0]] === "string") {
			var arr = [ query_string[pair[0]], pair[1] ];
			query_string[pair[0]] = arr;
			// If third or later entry with this name
		} else {
			query_string[pair[0]].push(pair[1]);
		}
	}
	console.log("QueryString: " + QueryString);
	return query_string;
}();

//Global config object for GeoJSON vector layer - sparql query data set
var datasources = {};
datasources["sparql-query"] = {
    layer: "", //OpenLayers layer name
    queryElementId: "sparql-query-text",
    JSONResultElementId: "sparql-results-json-result",
    GeoJSONResultElementId: "geojson-result"
};

if (QueryString.query) { datasources["sparql-query"].query = decodeURIComponent(QueryString.query); }
else { datasources["sparql-query"].query = "SELECT DISTINCT * WHERE { ?Subject <http://www.opengis.net/ont/geosparql#asWKT> ?wkt } LIMIT 5000"; }

if (QueryString.endpoint) { datasources["sparql-query"].endpoint = decodeURIComponent(QueryString.endpoint); }
else { datasources["sparql-query"].endpoint = "http://bureaudigitaalerfgoed.nl/sparql"; }

function init() {
	'use strict';
	$("#tabs").tabs();
	$("#accordion1").accordion({heightStyle: "content"});
    $("#" + datasources["sparql-query"].queryElementId).val(datasources["sparql-query"].query);

	var map = new OpenLayers.Map('map', {
		// Resoluties (pixels per meter) van de zoomniveaus:
		//resolutions: [6.72, 3.36, 1.68, 0.84, 0.42, 0.21],
		//units: 'm',
		numZoomLevels: null,
		minZoomLevel: 13, //This is one touch nut to crack.
		maxZoomLevel: 16, //The level should be limited to 16 at most, to not stress the spatial back end beyond capacity.
		controls: [
			new OpenLayers.Control.TouchNavigation({
				dragPanOptions: {
					enableKinetic: true
				}
			}),
			new OpenLayers.Control.MousePosition({
				prefix: '<a target="_blank" ' +
					'href="http://spatialreference.org/ref/epsg/4326/">' +
					'EPSG:4326</a> coordinates: ',
				separator: ' | ',
				numDigits: 2
			}),
			new OpenLayers.Control.PanZoom(),
			new OpenLayers.Control.Navigation({'zoomWheelEnabled': true})
		],
		projection: new OpenLayers.Projection("EPSG:3857"),
		displayProjection: new OpenLayers.Projection("EPSG:4326") //Is used for displaying coordinates in appropriate CRS by MousePosition control
	});

	//OpenStreetMap base layer
	var osm = new OpenLayers.Layer.OSM("Simple OSM Map");

	var vector_style = OpenLayers.Util.extend({}, OpenLayers.Feature.Vector.style['default']);
	vector_style.strokeWidth = 3;
	vector_style.fillOpacity = 0;
	vector_style.strokeColor = 'red';

	datasources["sparql-query"].layer = new OpenLayers.Layer.Vector("Archaeological structures (in red)", {
		format: new OpenLayers.Format.GeoJSON({
			internalProjection: new OpenLayers.Projection("EPSG:3857"),
			externalProjection: new OpenLayers.Projection("EPSG:4326")
		}),
		styleMap: new OpenLayers.StyleMap(vector_style),
		eventListeners: {
			'featureselected': function (evt) {
				//fill feature popup with attributes, except the geometry (which is far too large anyway)
				var feature = evt.feature;
				var featuretext = "";
				$.each(feature.attributes, function(key, value) {
					if (feature.attributes[key].datatype !== "http://www.opengis.net/ont/geosparql#wktLiteral") {
						featuretext = featuretext +
						key + ": " +
						feature.attributes[key].value + " "  + "<br>";
					}
				});
				var popup = new OpenLayers.Popup.FramedCloud(
					"popup",
					feature.geometry.getBounds().getCenterLonLat(),
					null,
					featuretext,
					null,
					true
				);
				feature.popup = popup;
				map.addPopup(popup);
			},
			'featureunselected': function (evt) {
				feature = evt.feature;
				map.removePopup(feature.popup);
				feature.popup.destroy();
				feature.popup = null;
			}
		}
	});

	// Tab 1
	var p1 = $("<div id='tab-1'>").css('height', '100%');

	map.addLayers([osm, datasources["sparql-query"].layer]);

	var selector = new OpenLayers.Control.SelectFeature([datasources["sparql-query"].layer],{
		hover:false,
		autoActivate:true
	});

	var ctlLayerSwitcher = new OpenLayers.Control.LayerSwitcher();

	map.addControls([selector, ctlLayerSwitcher]);
	ctlLayerSwitcher.maximizeControl();

	map.setCenter(
        new OpenLayers.LonLat(4.635, 52.38).transform(
            new OpenLayers.Projection("EPSG:4326"),
            map.getProjectionObject()
        ),
        15
	);

    executeSPARQL(datasources["sparql-query"].endpoint, datasources["sparql-query"].query)
}

//function for custom query execution, here is still some work to do, refactor analogous to function zoomSPARQL
function executeSPARQL(endpoint, query) {
	var d = new Date();
	var timer = d.getTime();

	$('#resultstotal').innerHTML = "Loading...";
	$.ajax({
		url: endpoint,
		dataType: 'json',
		data: {
			//queryLn: 'SPARQL', //Particular to OpenRDF Sesame for as far as I know
			query: query,
            //limit: $('#limit').val(), //this is not working at the moment
			//infer: 'false', //Particular to OpenRDF Sesame for as far as I know
			Accept: 'application/sparql-results+json'
		},
		success: function(response) {
			d = new Date();
			console.log((d.getTime() - timer)/1000 + " seconds for result set to return");
            console.log("response: ");
            console.log(response);
            //window.history.pushState({URL: window.location + query});
			displayData(response);
		},
		error: displayError()
	});
}

function displayError(xhr, textStatus, errorThrown) {
	console.log("Error status: " + textStatus);
	console.log("Error description: " + errorThrown + "\r\n" + xhr);
}

//Fill Html table with sparql results
var displayData = function(data) {
	var geometries = [];
	var geojson = {};
	var resulttable = document.getElementById(datasources["sparql-query"].JSONResultElementId);

	//empty result table rows, somehow this is the only sure method known to me
	while (resulttable.rows.length > 0) { resulttable.deleteRow(0); }
	//populate table header

	if (resulttable.tHead) {
		resulttable.deleteTHead();
		var header=resulttable.createTHead();
		var row=header.insertRow(0);

		$.each(data.head.vars, function (key, value) {
			var cell=row.insertCell(-1);
			cell.innerHTML = "<b>" + value + "</b>";
		});
	}

	//populate result table
	$.each(data.results.bindings, function (index, bs) {
		var row = $('<tr/>');

		$.each(data.head.vars, function (key, varname) {
			//recast datatype for WKT cast as literal
			if (bs[varname]	&& bs[varname].value) {
				if (bs[varname].value.substr(0, 10) == "LINESTRING") {
					bs[varname].datatype = "http://www.opengis.net/ont/geosparql#wktLiteral";
				}
			}

			if (bs[varname] && bs[varname].datatype) {
				if (bs[varname].datatype == "http://www.opengis.net/ont/geosparql#wktLiteral") {
					geometries.push(bs[varname].value);
				}
				row.append("<td>" + bs[varname].value + "</td>");
			}
		});
		$("#sparql-table-result tbody").after(row);
	});

	document.getElementById('resultstotal').innerHTML = geometries.length + " results on current map viewport";

	//supplied by sparql-geojson on https://github.com/erfgoed-en-locatie/sparql-geojson
	geojson = sparqlToGeoJSON(data);

	//$('#' + source.GeoJSONResultElementId).val(JSON.stringify(geojson));
	//$('#' + source.JSONResultElementId).val(JSON.stringify(data));
	datasources["sparql-query"].layer.destroyFeatures();
	var geojson_format = new OpenLayers.Format.GeoJSON({
		internalProjection: new OpenLayers.Projection("EPSG:3857"),
		externalProjection: new OpenLayers.Projection("EPSG:4326")
	});

	datasources["sparql-query"].layer.addFeatures(geojson_format.read(geojson));
    //Icon made by <a href="http://www.unocha.org" title="OCHA">OCHA</a> from <a href="http://www.flaticon.com" title="Flaticon">www.flaticon.com</a> is licensed under <a href="http://creativecommons.org/licenses/by/3.0/" title="Creative Commons BY 3.0">CC BY 3.0</a></div>
};
