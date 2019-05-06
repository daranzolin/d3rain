HTMLWidgets.widget({

  name: 'd3rain',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(opts) {

        margin = ({top: 50, right: 10, bottom: 20, left: 25});

        const data = HTMLWidgets.dataframeToD3(opts.data);

        let groups = data.map(d => d.group)
                    .filter(function(item, i, ar){ return ar.indexOf(item) === i; });

        const svg = d3.select(el)
                    .append("svg")
                    .style("width", "100%")
                    .style("height", "100%");

        let x = d3.scaleLinear()
                .domain([0, d3.max(data, d => +d.ind)])
                .range([margin.left, width - margin.right]);

        let xAxis = g => g
                .style("font", "18px times")
                .call(d3.axisTop(x)
                    .tickPadding(15)
                    .tickValues(d3.extent(data, d => +d.ind))
                    .tickSize(0))
                .call(g => g.select(".domain").remove());

        let y = d3.scaleBand()
                .domain(groups)
                .range([margin.top, height - margin.bottom]);

        let yAxis = g => g
                .attr("transform", `translate(${margin.left},0)`)
                .call(d3.axisLeft(y))
                .call(g => g.selectAll(".tick line").clone()
                  .attr("stroke-opacity", 0.2)
                  .attr("x2", width - margin.right))
                  .attr('transform', 'translate(0, 10)')
                .call(g => g.select(".domain").remove());

        svg.append("g")
              .attr('transform', `translate(0, ${margin.top/2 + 5})`)
              .call(xAxis);

        svg.append("g")
                .call(yAxis)
                .selectAll("text")
                .attr("x", width / 2)
                .attr('transform', 'translate(0, 10)')
                .style("font", "18px times");

        let circles = svg.selectAll('circle')
            .data(data)
              .enter().append('circle')
                .attr('cx', d => x(d.ind))
                .attr('cy', margin.top / 2)
                .attr('r', 5)
                .attr('fill', 'firebrick')
                .style('opacity', 0.5);

          d3.timeout(_ => {
            circles.transition()
            .delay((d, i) => 100 * i)
            .duration(500)
            .ease(d3.easeLinear)
            .attr('cy', d => y(d.group) + y.bandwidth() / 2);
            }, 1500);

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
