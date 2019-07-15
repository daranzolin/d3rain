HTMLWidgets.widget({

  name: 'd3rain',

  type: 'output',

  factory: function(el, width, height) {

    return {

      renderValue: function(opts) {

        margin = ({top: 100, right: 25, bottom: 20, left: 25});

        const data = HTMLWidgets.dataframeToD3(opts.data);
        //console.log(data);

        const svg = d3.select(el)
                    .append("svg")
                    .style("width", "100%")
                    .style("height", "100%");

        svg.append("rect")
            .attr("width", "100%")
            .attr("height", "100%")
            .attr("fill", opts.hasOwnProperty('backgroundFill') ? opts.backgroundFill : 'white');

        let yAxisTickLocation = opts.hasOwnProperty('yAxisTickLocation') ? opts.yAxisTickLocation : 'center';
        let textAnchor;
        switch(yAxisTickLocation) {
          case 'center':
            yAxisTickLocation = width/2;
            textAnchor = 'middle';
          break;
          case 'right':
            yAxisTickLocation = width - margin.right;
            textAnchor = 'end';
          break;
          case 'left':
            yAxisTickLocation = margin.right;
            textAnchor = 'start';
          break;
          default:
        }

        let fontSize = opts.hasOwnProperty('fontSize') ? opts.fontSize : 18;
        let dripSize = opts.hasOwnProperty('dripSize') ? opts.dripSize : 4;
        let fontFamily = opts.hasOwnProperty('fontFamily') ? opts.fontFamily : 'sans-serif';
        let jitterWidth = opts.hasOwnProperty('jitterWidth') ? opts.jitterWidth : 0;
        let dripSequence = opts.hasOwnProperty('dripSequence') ? opts.dripSequence : 'iterate';
        let reverseX = opts.hasOwnProperty('reverseX') ? opts.reverseX : false;

        function drop_group(selection, i) {
            selection.filter(d => d.group == opts.y_domain[i])
            .transition()
            .duration(opts.hasOwnProperty('dripSpeed') ? opts.dripSpeed : 1000)
            .ease(opts.hasOwnProperty('ease') ? ease(opts.ease) : d3.easeBounce)
            .attr('cy', d => y(d.group) + y.bandwidth() / 2 - Math.random() * jitterWidth);
          }

        function ease(o) {
            return o === 'bounce' ? d3.easeBounce : d3.easeLinear;
        }

        let x;
        if (reverseX) {
          x = d3.scaleLinear()
                .domain([d3.max(data, d => +d.ind), d3.min(data, d => +d.ind)])
                .range([margin.left, width - margin.right]);
        } else {
          x = d3.scaleLinear()
                .domain([d3.min(data, d => +d.ind), d3.max(data, d => +d.ind)])
                .range([margin.left, width - margin.right]);
        }

        let xAxis = g => g
                .style("font", `${opts.fontSize}px ${opts.fontFamily}`)
                .call(d3.axisTop(x)
                    .tickPadding(15)
                    .tickValues(d3.extent(data, d => +d.ind))
                    .tickSize(0))
                .call(g => g.select(".domain").remove());

        let y = d3.scaleBand()
                .domain(opts.y_domain)
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
                .attr("x", yAxisTickLocation)
                .attr("text-anchor", textAnchor)
                .attr('transform', 'translate(0, 10)')
                .style("font", `${opts.fontSize}px ${opts.fontFamily}`);

        svg.append("text")
                .attr("x", (width / 2))
                .attr("y", margin.top / 6)
                .attr("text-anchor", "middle")
                .style("font-family", `${fontFamily}`)
                .style("font-size", "20px")
                .style("font-weight", "bold")
                .text(opts.title);

        let tip = d3.tip()
              .attr('class', 'd3-tip')
              .offset([7, 7])
              .html(function(d) {
                return `<span style = "color:${opts.toolTipTextColor}">${opts.toolTipName}: ${d.toolTip}</span>`;
              });

        svg.call(tip);

        let circles = svg.selectAll('circle')
            .data(data)
              .enter().append('circle')
                .attr('cx', d => x(d.ind))
                .attr('cy', margin.top / 2)
                .attr('r', dripSize)
                .attr('fill', opts.hasOwnProperty('dripFill') ? opts.dripFill : 'firebrick')
                .style('opacity', opts.hasOwnProperty('dripOpacity') ? opts.dripOpacity : 0.5)
                .on('mouseover', tip.show)
                .on('mouseout', tip.hide);

        if (dripSequence === 'iterate') {

          d3.timeout(_ => {
            circles = circles.transition()
            .delay((d, i) => opts.hasOwnProperty('iterationSpeedX') ? opts.iterationSpeedX * i : 100 * i)
            .duration(opts.hasOwnProperty('dripSpeed') ? opts.dripSpeed : 1000)
            .ease(opts.hasOwnProperty('ease') ? ease(opts.ease) : d3.easeBounce)
            .attr('cy', d => y(d.group) + y.bandwidth() / 2 - Math.random() * jitterWidth);
            }, 1500);

        } else if (dripSequence == 'together') {

          d3.timeout(_ => {
            circles = circles.transition()
            .duration(opts.hasOwnProperty('dripSpeed') ? opts.dripSpeed : 1000)
            .ease(opts.hasOwnProperty('ease') ? ease(opts.ease) : d3.easeBounce)
            .attr('cy', d => y(d.group) + y.bandwidth() / 2 - Math.random() * jitterWidth);
          }, 1500);

        } else {

          let i = 0;
          d3.timeout(_ => {
            d3.interval(function(elapsed) {
              drop_group(circles, i);
              i++;
            }, 2500);
          }, 500);
        }
      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
