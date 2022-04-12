var width = window.innerWidth * 0.8 - 20;
// var width = document.getElementById("daily_case_bars").offsetWidth;
if (width > 800) {
  var width = 800;
}
var width_margin = width * 0.15;
var height = window.innerHeight * .75;

// ! Arc data

var male_arc_data = $.ajax({
  url: './Outputs/male_le_arc_data.json',
  dataType: "json",
  success: console.log("Male arc data successfully loaded."),
  error: function (xhr) {
    alert(xhr.statusText);
  },
});

var female_arc_data = $.ajax({
  url: './Outputs/female_le_arc_data.json',
  dataType: "json",
  success: console.log("Male arc data successfully loaded."),
  error: function (xhr) {
    alert(xhr.statusText);
  },
});

$.when(male_arc_data, female_arc_data).done(function () {

// List of node names
var arc_svg = d3.select("#arc_vis")
.append("svg")
.attr("width", width)
.attr("height", height)
.append("g")

var arc_labels =  [0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95]

// A linear scale to position the nodes on the X axis
var x_arc = d3.scaleLinear()
  .range([50, width -50])
  .domain([0, 95])

// Life years labels give them a label
 arc_svg
 .selectAll("life_years_labels")
 .data(arc_labels)
 .enter()
 .append("text")
 .attr("x", function(d){ return(x_arc(d))})
 .attr("y", (height/2))
 .text(function(d){ return(d)})
 .style("text-anchor", "middle")
 .attr("class", "arc_axis")

 arc_svg
 .append("text")
 .attr("text-anchor", "right")
 .attr("y", height/2 + 20 )
 .attr("x", width * 0.95)
 .attr("opacity", 1)
 .style("font-weight", "bold")
 .text("years");

 arc_svg
 .append("text")
 .attr("text-anchor", "right")
 .attr('class', 'arc_chart_caption')
 .attr("y", height *.95)
 .attr("x", width * 0.75)
 .attr("opacity", 1)
 .text("Hover over a dot or line to see more");

// ! Arcs
// Add arcs between nodes. This is tricky.

// Links are provided between nodes -id-, NOT between node names so we have to do a link between this id and the name
var idToNode_male = {};
male_arc_data.responseJSON.nodes.forEach(node =>
  idToNode_male[node.id] = node
  );

// Links are provided between nodes -id-, NOT between node names so we have to do a link between this id and the name
var idToNode_female = {};
female_arc_data.responseJSON.nodes.forEach(node =>
  idToNode_female[node.id] = node
  );

// Variables denoting starting y position of the labels
 arc_text_1_position = .24; 
 arc_text_2_position = .64; 

// Define a function to extract the area a user has chosen (by hovering on a line and hopefully a node).
// We want to highlight the area for both males and females, as well as grab the LE values, displaying some text on the plot 
function arc_mouseover_function(){
chosen_area = this.getAttribute('class').replace('arc_', '') // we can strip out the area from the given class
chosen_class = '.arc_' + chosen_area

arc_svg.selectAll(chosen_class).attr("class", function(d) {return('arc_' + chosen_area + " arc_selected")}) // We need to add a class, but maintain the old class too

chosen_area_male_data = male_arc_data.responseJSON.links.filter(function(d,i){
  return d.Area_Code === chosen_area})
male_chosen_LE_value = chosen_area_male_data[0].Value;

chosen_area_name = chosen_area_male_data[0].msoa11hclnm
chosen_area_name_official = chosen_area_male_data[0].Area_Name

chosen_area_female_data = female_arc_data.responseJSON.links.filter(function(d,i){
  return d.Area_Code === chosen_area})
female_chosen_LE_value = chosen_area_female_data[0].Value;

arc_svg
    .append("text")
    .attr("text-anchor", "left")
    .attr("class", "arc_chart_text")
    .attr("y", height * arc_text_1_position)
    .attr("x", width * 0.2)
    .attr("opacity", 0)
    .transition()
    .duration(1000)
    .attr("opacity", 1)
    .style("font-weight", "bold")
    .text("Life expectancy at birth: ");

arc_svg
  .append("text")
  .attr("text-anchor", "left")
  .attr("class", "arc_chart_text")
  .attr("y", height * arc_text_1_position + 20)
  .attr("x", width * 0.2)
  .attr("opacity", 0)
  .transition()
  .duration(1000)
  .attr("opacity", 1)
  .text(chosen_area_name + ' (' + chosen_area_name_official + ', '+ chosen_area + ')');

arc_svg
  .append("text")
  .attr("text-anchor", "left")
  .attr("class", "arc_chart_text")
  .attr("y", height * arc_text_1_position + 40)
  .attr("x", width * 0.2)
  .attr("opacity", 0)
  .transition()
  .duration(1000)
  .attr("opacity", 1)
  .text("Males: " + d3.format(',.1f')(male_chosen_LE_value) + ' years');

arc_svg
  .append("text")
  .attr("text-anchor", "left")
  .attr("class", "arc_chart_text")
  .attr("y", height * arc_text_1_position + 60)
  .attr("x", width * 0.2)
  .attr("opacity", 0)
  .transition()
  .duration(1000)
  .attr("opacity", 1)
  .text("Females: " + d3.format(',.1f')(female_chosen_LE_value) + ' years');

arc_svg
  .append("text")
  .attr("text-anchor", "left")
  .attr("class", "arc_chart_text")
  .attr("y", height * arc_text_2_position)
  .attr("x", width * 0.3)
  .attr("opacity", 0)
  .transition()
  .duration(1000)
  .attr("opacity", 1)
  .text("In this neighbourhood, there is a " + d3.format(',.1f')(female_chosen_LE_value - male_chosen_LE_value) + ' year gap');

  arc_svg
  .append("text")
  .attr("text-anchor", "left")
  .attr("class", "arc_chart_text")
  .attr("y", height * arc_text_2_position + 20)
  .attr("x", width * 0.3)
  .attr("opacity", 0)
  .transition()
  .duration(1000)
  .attr("opacity", 1)
  .text("in life expectancy between females and males");

}

// Define a function which returns the selected element back to its original class and remove any elements with the class 'arc_chart_text'
function arc_mouseout_function() {
    d3.select(this).classed("arc_selected", false);
    arc_svg.selectAll('.arc_selected').classed("arc_selected", false);

    arc_svg.selectAll(".arc_chart_text")
    .transition()
    .duration(1000)
    .attr("opacity", 0)
    .remove();
}

// Add the male arcs
arc_svg
.selectAll('male_arcs')
.data(male_arc_data.responseJSON.links)
.enter()
.append('path')
.attr("class", function(d) {
  return (d) ? "arc_" + d.Area_Code : null;
})
.attr('d', function (d) {
  start = x_arc(idToNode_male[d.source].name)    // X position of start node on the X axis
  end = x_arc(idToNode_male[d.target].name)      // X position of end node
  return ['M', start, (height/2)-30,    // the arc starts at the coordinate x=start, y=height-30 (where the starting node is)
    'A',                            // This means we're gonna build an elliptical arc
    (start - end)/2, ',',    // Next 2 lines are the coordinates of the inflexion point. Height of this point is proportional with start - end distance
    (start - end)/4, 0, 0, ',',
    start < end ? 1 : 0, end, ',', (height/2)-30] // We always want the arc on top. So if end is before start, putting 0 here turn the arc upside down.
    .join(' ');
})
.style("fill", "none")
.attr("stroke", "#ff9169")
.on('mouseover', arc_mouseover_function)
.on('mouseout', arc_mouseout_function)

// Add the female arcs
arc_svg
  .selectAll('female_arcs')
  .data(female_arc_data.responseJSON.links)
  .enter()
  .append('path')
  .attr("class", function(d) {
    return (d) ? "arc_" + d.Area_Code : null;
})
  .attr('d', function (d) {
    start = x_arc(idToNode_female[d.source].name)    // X position of start node on the X axis
    end = x_arc(idToNode_female[d.target].name)      // X position of end node
    return ['M', start, (height/2)+30,    // the arc starts at the coordinate x=start, y=height-30 (where the starting node is)
      'A',                            // This means we're gonna build an elliptical arc
      (start - end)/2, ',',    // Next 2 lines are the coordinates of the inflexion point. Height of this point is proportional with start - end distance
      (start - end)/4, 0, 0, ',',
      start < end ? 0 : 1, end, ',', (height/2)+30] // We always want the arc on top. So if end is before start, putting 0 here turn the arc upside down.
      .join(' ');
   })
   .style("fill", "none")
   .attr("stroke", "#94e2ff")
   .on('mouseover', arc_mouseover_function)
   .on('mouseout', arc_mouseout_function)

// Add the male circles for the nodes
// ! I actually want to use the links array within this json file rather than nodes because it has more info in it (such as area name) and this will allow us to add the same functionality to hover over a dot/node to show and highlight more information.
arc_svg
.selectAll("male_nodes")
.data(male_arc_data.responseJSON.links)
.enter()
.append("circle")
.attr("class", function(d) {
  return (d) ? "arc_" + d.Area_Code : null;
})
.attr("cx", function(d){ return(x_arc(d.Value))})
.attr('cy', height/2 - 20)
.attr("r", 4)
.style("fill", '#ff9169')
.on('mouseover', arc_mouseover_function)
.on('mouseout', arc_mouseout_function)

// Add the male circles for the nodes
arc_svg
.selectAll("female_nodes")
.data(female_arc_data.responseJSON.links)
.enter()
.append("circle")
.attr("class", function(d) {
  return (d) ? "arc_" + d.Area_Code : null;
})
.attr("cx", function(d){ return(x_arc(d.Value))})
.attr('cy', height/2 + 20)
.attr("r", 4)
.style("fill", '#94e2ff')
.on('mouseover', arc_mouseover_function)
.on('mouseout', arc_mouseout_function)

// Add West Sussex and England nodes 
male_wsx_eng_data = male_arc_data.responseJSON.links.filter(function(d,i){
  return d.Area_Name === 'West Sussex' || d.Area_Name === 'England'})

female_wsx_eng_data = female_arc_data.responseJSON.links.filter(function(d,i){
    return d.Area_Name === 'West Sussex' || d.Area_Name === 'England'})

big_area_colours =   d3.scaleOrdinal()
.domain(['West Sussex', 'England'])
.range(['#800080','#000000']);

big_area_size = d3.scaleOrdinal()
.domain(['West Sussex', 'England'])
.range([6,4])

arc_svg
.selectAll("wsx_nodes")
.data(male_wsx_eng_data)
.enter()
.append("circle")
.attr("class", function(d) {
  return (d) ? "arc_" + d.Area_Code : null;
})
.attr("cx", function(d){ return(x_arc(d.Value))})
//  .attr("cy", function(d){ return(sex_arc(d.Sex))})
.attr('cy', height/2 - 20)
.attr("r", function(d){ return(big_area_size(d.Area_Name))})
.style("fill", function(d){ return(big_area_colours(d.Area_Name))})
.on('mouseover', arc_mouseover_function)
.on('mouseout', arc_mouseout_function)

arc_svg
.selectAll("wsx_nodes")
.data(female_wsx_eng_data)
.enter()
.append("circle")
.attr("class", function(d) {
  return (d) ? "arc_" + d.Area_Code : null;
})
.attr("cx", function(d){ return(x_arc(d.Value))})
//  .attr("cy", function(d){ return(sex_arc(d.Sex))})
.attr('cy', height/2 + 20)
.attr("r", function(d){ return(big_area_size(d.Area_Name))})
.style("fill", function(d){ return(big_area_colours(d.Area_Name))})
.on('mouseover', arc_mouseover_function)
.on('mouseout', arc_mouseout_function)

// ! Deprivation scatter plot

var dep_data = male_arc_data.responseJSON.links.concat(female_arc_data.responseJSON.links).filter(function(d){
  return d.Area_Name != 'West Sussex' && d.Area_Name != 'England'}) // Join male and female arc data and exclude wsx and england (as they wont have a population weighted deprivation score)

ltla_area_scatter_areas = ['Adur', 'Arun', 'Chichester', 'Crawley','Horsham', 'Mid_Sussex', 'Worthing']

var ltla_scatter_colour_func = d3
  .scaleOrdinal()
  .domain(ltla_area_scatter_areas)
  .range([
    "#0E2F6A",
    "#490B2F",
    "#880D2A",
    "#B02C1A",
    "#FD7726",
    "#FDD147",
    "#8CC216",
  ]);

var svg_scatter = d3
  .select("#dep_le_scatter_vis")
  .append("svg")
  .attr("width", width)
  .attr("height", height)
  .append("g")
  .attr("transform", "translate(" + 60 + "," + 30 + ")");

var tooltip_scatter_dep_le = d3
  .select("#dep_le_scatter_vis")
  .append("div")
  .style("opacity", 0)
  .attr("class", "tooltip_outside_box")
  .style("position", "absolute")
  .style("z-index", "10")
  .style("background-color", "white")
  .style("border", "solid")
  .style("border-width", "1px")
  .style("border-radius", "5px")
  .style("font-size", ".6rem")
  .style("padding", "10px");

var showTooltip_scatter_dep_le = function (d) {
  tooltip_scatter_dep_le
    .html(
      "<p><b>" +
        d.Area_Name +
        " in  " +
        d.Laname +
        "</b></p><p>"+
        d.Sex + 
        " life expectancy at birth in this neighbourhood is <b> " +
        d3.format(",.1f")(
          d.Value) +
        " years</b>.<p>This MSOA has a population weighted deprivation score of <b>" +
        d3.format(",.1f")(d.Pop_weighted_imd_score) +
        "</b> and a rank of <b>" +
        d3.format(",.0f")(d.Pop_weighted_rank) +
        "</b> out of 6,790 neighbourhoods nationally, with 1 being most deprived.</p> "
    )
    .style("opacity", 1)
    .style("opacity", 1)
    .style("font-size", ".8rem")
    .style("visibility", "visible");

  selected_MSOA_scatter = d.Laname_ns;

  d3.selectAll(".dot." + selected_MSOA_scatter)
    .transition()
    .duration(200)
    .style("stroke", "maroon")
    .attr("r", 9);
};

var Mouseleave_scatter_dep_le = function (d) {
  tooltip_scatter_dep_le.style("opacity", 0).style("visibility", "hidden");

  d3.selectAll(".dot." + selected_MSOA_scatter)
    .transition()
    .duration(200)
    .style('stroke', '#ffffff')
    // .style("fill", function (d) { return sex_colour_function(d.Sex)})
    .attr("r", 6);
};

// Add X axis
var x_dep_le = d3
  .scaleLinear()
  .domain([
    0,
    d3.max(dep_data, function (d) {
      return +d.Pop_weighted_imd_score;
    }),
  ])
  .range([0, width - 120])
  .nice();

xAxis_dep_le = svg_scatter
  .append("g")
  .attr("transform", "translate(0," + (height - 60) + ")") 
  .call(d3.axisBottom(x_dep_le).tickFormat(d3.format(",.0f")));

xAxis_dep_le.selectAll("text").style("font-size", ".8rem");

// Add Y axis
var y_dep_le = d3
  .scaleLinear()
  .domain([65, 95])
  .range([height - 60, 0])
  .nice()

var yAxis_dep_le = svg_scatter
  .append("g")
  .attr("transform", "translate(0,0)")
  .call(d3.axisLeft(y_dep_le).tickFormat(d3.format(",.0f")));

yAxis_dep_le
  .selectAll("text")
  .attr("transform", "translate(0,0)")
  .style("text-anchor", "end")
  .style("font-size", ".8rem");

svg_scatter
  .append("text")
  .attr("x", function (d) {
    return x_dep_le(2);
  })
  .attr("y", height - 90)
  .attr("id", "less_deprived_label")
  .text("Less deprived")
  .attr("text-anchor", "start")
  .style("font-weight", "bold")
  .style("font-size", ".8rem");

svg_scatter
  .append("text")
  .attr("x", function (d) {
    return x_dep_le(
      d3.max(dep_data, function (d) {
        return +d.Pop_weighted_imd_score;
      })
    );
  })
  .attr("y", height - 90)
  .attr("id", "more_deprived_label")
  .text("More deprived")
  .attr("text-anchor", "end")
  .style("font-weight", "bold")
  .style("font-size", ".8rem");

svg_scatter
  .append("text")
  .attr("x", function (d) {
    return x_dep_le(
      d3.max(dep_data, function (d) {
        return +d.Pop_weighted_imd_score;
      })
    );
  })
  .attr("y", 10)
  .attr("id", "hover_label_1")
  .text("Hover over a dot")
  .attr("text-anchor", "end")
  .style("font-size", ".8rem");

svg_scatter
  .append("text")
  .attr("x", function (d) {
    return x_dep_le(
      d3.max(dep_data, function (d) {
        return +d.Pop_weighted_imd_score;
      })
    );
  })
  .attr("y", 25)
  .attr("id", "hover_label_2")
  .text("to highlight other")
  .attr("text-anchor", "end")
  .style("font-size", ".8rem");

svg_scatter
  .append("text")
  .attr("x", function (d) {
    return x_dep_le(
      d3.max(dep_data, function (d) {
        return +d.Pop_weighted_imd_score;
      })
    );
  })
  .attr("y", 40)
  .attr("id", "hover_label_3")
  .text("neighbhourhoods in")
  .attr("text-anchor", "end")
  .style("font-size", ".8rem");

svg_scatter
  .append("text")
  .attr("x", function (d) {
    return x_dep_le(
      d3.max(dep_data, function (d) {
        return +d.Pop_weighted_imd_score;
      })
    );
  })
  .attr("y", 55)
  .attr("id", "hover_label_4")
  .text("the same local authority")
  .attr("text-anchor", "end")
  .style("font-size", ".8rem");

sex_colour_function = d3
.scaleOrdinal()
.domain(['Male', 'Female'])
.range(['#ff9169', '#94e2ff'])

var dep_uptake_points = svg_scatter
    .selectAll("circle")
    .data(dep_data);

  dep_uptake_points
    .enter()
    .append("circle")
    .merge(dep_uptake_points)
    .attr("class", function (d) {
      return "dot " + d.Laname_ns;
    })
    .attr("cx", function (d) {
      return x_dep_le(d.Pop_weighted_imd_score);
    })
    .attr("cy", function (d) {
      return y_dep_le(
        d.Value)})
    .attr("r", 6)
    .attr("fill", function (d) { return sex_colour_function(d.Sex)})
    .style("stroke", "#ffffff")
    .on("mousemove", showTooltip_scatter_dep_le)
    .on("mouseout", Mouseleave_scatter_dep_le);

  dep_uptake_points.exit().remove();

}) // This is the end of the when data loaded scope

// TODO add legend
// TODO add wsx values to legend

// ! Map
// L. is leaflet
var tileUrl = "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png";
var attribution =
  '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Contains Ordnance Survey data © Crown copyright and database right 2022';

// Add AJAX request for data
var msoa_le = $.ajax({
  url: "./Outputs/msoa_local_health_latest.geojson",
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
