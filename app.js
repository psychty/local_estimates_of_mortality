
// ! Arcs







// ! Map

// L. is leaflet
var tileUrl = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
var attribution =
  '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Contains Ordnance Survey data © Crown copyright and database right 2022';

// Add AJAX request for data
var msoa_le = $.ajax({
  url: "./msoa_local_health_latest.geojson",
  dataType: "json",
  success: console.log("MOSA boundary data successfully loaded."),
  error: function (xhr) {
    alert(xhr.statusText);
  },
});

function leColour(feature) {
  return {
    // fillColor: setleColour(feature.properties.PCN),
    // color: setleColour(feature.properties.PCN),
    fillColor: "yellow",
    weight: 1,
    fillOpacity: 0.5,
  };
}

// Specify that this code should run once the county data request is complete
$.when(msoa_le).done(function () {
  var map = L.map("map_1_id").setView([50.8379, -0.7827], 10);

  var basemap = L.tileLayer(tileUrl, { attribution }).addTo(map);

  var msoa_boundary = L.geoJSON(msoa_le.responseJSON, { style: leColour })
    .addTo(map)
    .bindPopup(function (layer) {
      return (
        "<Strong>" +
        layer.feature.properties.Msoa_name +
        "</Strong><br><br>Male life expectancy: "
      );
    });

  map.fitBounds(msoa_boundary.getBounds());
});
