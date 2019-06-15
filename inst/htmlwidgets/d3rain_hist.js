HTMLWidgets.widget({

  name: 'd3rain_hist',

  type: 'output',

  factory: function(el, width, height) {

    return {

      renderValue: function(opts) {

        let rm = opts.hasOwnProperty('annotations') ? 200 : 20;
        let dripSize = opts.hasOwnProperty('dripSize') ? opts.dripSize : 4;
        let fontFamily = opts.hasOwnProperty('fontFamily') ? opts.fontFamily : 'sans-serif';
        let margin = ({top: 100, right: rm, bottom: 100, left: 40});
        let titlePosition = opts.hasOwnProperty('titlePosition') ? opts.titlePosition : 'center';
        if (titlePosition === 'center'){
          if (opts.hasOwnProperty('annotations')) {
            titlePosition = (width - margin.right)/2;
          } else {
            titlePosition = width/2;
          }
        } else if (titlePosition === 'left') {
          titlePosition = margin.left;
        } else {
          titlePosition = width - (margin.right * 2);
        }
        let levels = opts.levels;
        let colors = opts.hasOwnProperty('colors') ? opts.colors : ['black', 'forestgreen', 'orange', 'firebrick', 'steelblue', 'pink', 'purple'];
        let yBuffer = 15;
        let levelLabelLocation = opts.hasOwnProperty('levelLabelLocation') ? opts.levelLabelLocation : 'center';
        let transitionIntervals = opts.hasOwnProperty('transitionIntervals') ? opts.transitionIntervals : 2500;
        let dripSpeed = opts.hasOwnProperty('dripSpeed') ? opts.dripSpeed : 300;
        let textAnchor;
        switch(levelLabelLocation) {
          case 'center':
            levelLabelLocation = (width - margin.right)/2;
            textAnchor = 'middle';
          break;
          case 'right':
            levelLabelLocation = width - margin.right;
            textAnchor = 'end';
          break;
          case 'left':
            levelLabelLocation = margin.left;
            textAnchor = 'start';
          break;
          default:
        }

        const data = HTMLWidgets.dataframeToD3(opts.data);
        //console.log(data);

        function getX(arr) {
          let al = arr.length;
          return Array(al).fill((arr.x0 + arr.x1) /2);
        }

        function getY(arr) {
          return Array.from({length: arr.length}, (x, i) => i);
        }

        let x = d3.scaleLinear()
            .domain(d3.extent(data, d => +d.xVar)).nice()
            .range([margin.left, width - margin.right]);

        let xAxis = g => g
           .attr("transform", `translate(0, ${height - (margin.bottom /2)})`)
           .call(d3.axisBottom(x)
            .tickPadding(15)
            .tickFormat(d3.format("d"))
            .ticks(5)
            .tickSize(0))
            .style("font-size","15px");
            //.tickValues([d3.min(coords, d => +d.x), d3.median(coords, d => +d.x), d3.max(coords, d => +d.x)])
            //.tickValues(d3.extent(coords, d => d.x))
            //.tickSize(0))
            //.call(g => g.select(".domain").remove());

        let nLevels = levels.length;
        let partition_heights = (height - margin.top) / nLevels;

        let yBins = [];
        for (let i = 0; i < levels.length; i++) {
              let col = levels[i];
              let colData = data.filter(d => d[col]).map(d => d.xVar);
              let b = d3.histogram()
                  .domain(x.domain())
                  .thresholds(x.ticks(opts.xBins))
                (colData);
              yBins.push(b.map(d => d.sort()));

        }

        let yDomains = [];

        for (let i = 0; i < levels.length; i++) {
              let rb = partition_heights * (i + 1);
              let rt = i === 0 ? yBuffer : (partition_heights * i) - yBuffer;
              let dom = d3.scaleLinear()
                          .domain([0, d3.max(yBins[0], d => d.length)]).nice()
                          .range([rb, rt]);
              yDomains.push(dom);

        }

        let yAxes = [];
        for (let i = 0; i < yDomains.length; i++) {
              let yax = g => g
                .attr("transform", `translate(${margin.left},0)`)
                .call(d3.axisLeft(yDomains[i]).ticks(1))
                .call(g => g.selectAll(".tick line").clone()
                    .attr("stroke-opacity", 0.3)
                    .attr("x2", width - margin.right))
                    .attr('transform', `translate(0, 5)`)
                .call(g => g.select(".domain").remove());
              yAxes.push(yax);

        }

        let coords = [];
        let yArr = [];
        let xArr = [];
        let lArr = [];

        for (let i = 0; i < levels.length; i++) {
              let y_scale_inds = yBins[i].map(d => getY(d)).flat();
              let x_scale_vals = yBins[i].map(d => getX(d)).flat();
              let l_vals = Array(y_scale_inds.length).fill(levels[i]);
              let g_vals = Array(y_scale_inds.length).fill(i);
              yArr.push(y_scale_inds);
              xArr.push(x_scale_vals);
              lArr.push(l_vals);
              yArr = yArr.flat();
              xArr = xArr.flat();
              lArr = lArr.flat();
          }

        for (let i = 0; i < yArr.length; i++) {
              let obj = {};
              obj.x = xArr[i];
              obj.y = yArr[i];
              obj.level = lArr[i];
              coords.push(obj);
        }

        let yRanges = yDomains.map(d => d.range()).map(d => d[0]);

        let y = d3.scaleBand()
              .domain(levels)
              .range(d3.extent(yRanges));

        let yAxis = g => g
              .attr("transform", `translate(${margin.left},0)`)
              .call(d3.axisLeft(y))
              .call(g => g.selectAll(".tick line").clone()
                  .attr("stroke-opacity", 0.2)
                  .attr("x2", width - margin.right))
                  .attr('transform', `translate(0, 0)`)
              .call(g => g.select(".domain").remove());

        function drop_group(selection, i) {
                  selection.filter(d => d.level === levels[i])
                        .transition()
                        .style("opacity", 1)
                        .ease(d3.easeLinear)
                        .delay(d => d.y * 30)
                        .duration(dripSpeed)
                        .attr('cy', d => yDomains[i](d.y * 0.85))
                        .transition()
                        .duration(5500)
                        .attr('fill', colors[i]);

          }
        const svg = d3.select(el)
                    .append("svg")
                    .style("width", width)
                    .style("height", height);

        svg.append("g").call(xAxis);

        svg.append("text")
                .attr("x", titlePosition)
                .attr("y", margin.top / 6)
                .attr("text-anchor", "middle")
                .style("font-family", `${fontFamily}`)
                .style("font-size", "20px")
                .style("font-weight", "bold")
                .text(opts.title);

        for (let i = 0; i < yAxes.length; i++) {
            svg.append("g")
              .call(yAxes[i])
                .selectAll(".tick:not(:first-of-type) line")
                .attr("opacity", "0");
        }


        for (let i = 0; i < levels.length; i++) {
            svg.append("text")
                .attr("x", levelLabelLocation)
                .attr("y", yRanges[i] + 20)
                .attr("text-anchor", textAnchor)
                .text(levels[i])
                .attr('fill', colors[i]);
        }

        let circles = svg.append("g")
              .attr("fill", "grey")
              //.style('opacity', 0.5)
            .selectAll("circle")
            .data(coords)
            .enter().append('circle')
              .attr("cx", d => x(d.x))
              .attr("cy", (margin.top / 6))
              .attr("r", dripSize)
              .style("opacity", 0);


        let i = 0;
        d3.interval(function() {
          drop_group(circles, i);

          if (opts.hasOwnProperty('annotations')) {
            svg.append("text")
            .attr("x", width - margin.right + 10)
            .attr("y", yRanges[i] - 20)
            .attr('fill', colors[i])
            .text(opts.annotations[i]);
          //draw_group(circles, i)
          }
        i++;
        }, transitionIntervals);

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
