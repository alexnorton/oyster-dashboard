d3.json("data.json", function(error, data) {

  var tableBody = d3.select('table').select('tbody');

  // Add rows to table body
  var rows = tableBody.selectAll('tr')
    .data(data.journeys)
    .enter()
    .append('tr');

  // Add cells to rows
  rows.selectAll('td')
    .data(function(journey) {
      return [
        d3.time.format('%H:%M, %A %e %b')(new Date(journey.start_time)),
        getLocationById(data.locations, journey.from_id).name,
        getLocationById(data.locations, journey.to_id).name,
        '£' + d3.format('.2f')(journey.cost)
      ];
    })
    .enter()
    .append('td')
    .text(function(text) { return text; });

});

var getLocationById = function(locations, id) {
  return locations.filter(function(location) {
    return location.id == id;
  })[0] || null;
};