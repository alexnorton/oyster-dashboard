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
  var container = d3.select('#barchart');

  var margin = {top: 20, right: 20, bottom: 30, left: 40};

  var width = 900 - margin.left - margin.right,
    height = 300 - margin.top - margin.bottom;

  var x = d3.scale.ordinal()
    .rangeRoundBands([0, width], .1);

  var y = d3.scale.linear()
    .range([height, 0]);

  var xAxis = d3.svg.axis()
    .scale(x)
    .orient('bottom')
    .tickFormat(d3.time.format("%b %Y"));

  var yAxis = d3.svg.axis()
    .scale(y)
    .orient('left');

  var svg = container.append('svg')
    .attr('width', width + margin.left + margin.right)
    .attr('height', height + margin.top + margin.bottom)
    .append('g')
    .attr('transform', 'translate(' + margin.left + ',' + margin.top + ')');

  var groups = d3.nest()
    .key(function(journey) { return d3.time.month(journey.startTime);})
    .rollup(function(journeys) { return journeys.length })
    .entries(journeys);

  var extent = d3.extent(groups, function(group) { return new Date(group.key); });

  x.domain(d3.time.months(extent[0], extent[1]).concat(extent[1]));

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
    .attr('x', function(group) {
      return x(new Date(group.key))
    })
    .attr('width', x.rangeBand())
    .attr('y', function(group) { return y(group.values); } )
    .attr('height', function(group) { return height - y(group.values) });
};

var renderTable = function() {

  var container = d3.select('#table');

  var table = container.append('table')
    .attr('class', 'table');

  table.append('thead')
    .append('tr')
    .selectAll('th')
    .data(['Type', 'Date', 'From', 'To', 'Route', 'Price'])
    .enter()
    .append('th')
    .text(function(heading) { return heading; });

  // Add rows to table body
  var rows = table.append('tbody')
    .selectAll('tr')
    .data(journeys.reverse())
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