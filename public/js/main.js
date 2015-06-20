var locations, journeys;

d3.json("data.json", function(error, data) {
  processData(data);
  renderBarChart();
  renderTable();
});

var processData = function(data) {
  locations = data.locations;

  journeys = data.journeys.map(function(journey) {
    return {
      id: journey.id,
      from: getLocationById(journey.from_id),
      to: getLocationById(journey.to_id),
      startTime: new Date(journey.start_time),
      endTime: journey.end_time ? new Date(journey.end_time) : null,
      route: journey.route,
      cost: journey.cost,
      type: journey.end_time ? 'rail' : 'bus'
    };
  })
  // Sort by start date, newest first
  .sort(function(a, b) {
    return a.startTime - b.startTime;
  });
};

var getLocationById = function(id) {
  return locations.filter(function(location) {
    return location.id == id;
  })[0] || null;
};

var renderBarChart = function() {
  var div = d3.select('#barchart');

  var margin = {top: 20, right: 20, bottom: 30, left: 40};

  var width = 700 - margin.left - margin.right,
    height = 300 - margin.top - margin.bottom;

  var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

  var y = d3.scale.linear()
    .range([height, 0]);

  var xAxis = d3.svg.axis()
    .scale(x)
    .orient('bottom');

  var yAxis = d3.svg.axis()
    .scale(y)
    .orient('left')
    .tickSize(10);

  var svg = div.append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  var groups = d3.nest()
    .key(function(journey) { return d3.time.format('%b %Y')(journey.startTime);})
    .rollup(function(journeys) { return journeys.length })
    .entries(journeys);

  x.domain(groups.map(function(group) { return group.key; }));
  y.domain([0, d3.max(groups, function(group) { return group.values; })]);

  svg.append('g')
    .attr('class', 'x axis')
    .attr('transform', 'translate(0, ' + height + ')')
    .call(xAxis);

  svg.append('g')
    .attr('class', 'y axis')
    .call(yAxis)
    .append('text')
    .attr('transform', 'rotate(-90)')
    .attr('y', 6)
    .attr('dy', '.71em')
    .style('text-anchor', 'end')
    .text('Journeys');

  svg.selectAll('.bar')
    .data(groups)
    .enter()
    .append('rect')
    .attr('class', 'bar')
    .attr('x', function(group) { return x(group.key); })
    .attr('width', x.rangeBand())
    .attr('y', function(group) { return y(group.values); } )
    .attr('height', function(group) { return height - y(group.values) });
};

var renderTable = function() {
  var tableBody = d3.select('table').select('tbody');

  // Add rows to table body
  var rows = tableBody.selectAll('tr')
    .data(journeys)
    .enter()
    .append('tr');

  // Add cells to rows
  rows.selectAll('td')
    .data(function(journey) {
      return [
        (function(type){
          switch(type) {
            case 'rail':
              return '&#128647;';
            case 'bus':
              return '&#128652;';
          }
        })(journey.type),
        d3.time.format('%H:%M, %e %b %y')(journey.startTime),
        journey.from ? journey.from.name : null,
        journey.to ? journey.to.name : null,
        journey.route,
        '£' + d3.format('.2f')(journey.cost)
      ];
    })
    .enter()
    .append('td')
    .html(function(text) { return text; });
};