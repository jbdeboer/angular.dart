window.benchmarkSteps = [];

window.addEventListener('DOMContentLoaded', function() {
  var container = document.querySelector('#benchmarkContainer');

  // Add links to everything
  var linkDiv = document.createElement('div');
  linkDiv.style['margin-bottom'] = "1.5em";
  var linkHtml = [
    '<style>',
    '.bpLink { background: lightblue; padding: 1em }',
    '</style>',
    '<span class=bpLink>Benchmark Versions: </span>'
  ].join('\n');

  [
    ['/bp/angularjs.html', 'AngularJS 1.2'],
   // ['/bp/angularjs-nodebugging.html', 'AngularJS 1.3++'],
    ['/bp/angulardart.html', 'AngularDart'],
    ['/bp/angular20/temp/examples/tree-runner.html', 'Angular 2.0'] 
  ].forEach((function (link) {
    linkHtml += [
      '<a class=bpLink href=',
      link[0],
      '>',
      link[1],
      '</a>'
    ].join('');
  }));

  linkDiv.innerHTML = linkHtml;
  container.appendChild(linkDiv);


  // Benchmark runner
  var btn = document.createElement('button');
  btn.innerText = "Loop";
  var running = false;
  btn.addEventListener('click', loopBenchmark);
  
  container.appendChild(btn);

  function loopBenchmark() {
    if (running) {
      btn.innerText = "Loop";
      running = false;
    } else {
      window.requestAnimationFrame(function() {
       btn.innerText = "Pause";
        running = true;
        var loopB;
        loopB = function() {
          if (running) {
            window.requestAnimationFrame(function() {
              if (running)
              runBenchmarkSteps(loopB);
            });  
          }
        };
        loopB();  
      });
    }
  }


  var onceBtn = document.createElement('button');
  onceBtn.innerText = "Once";
  onceBtn.addEventListener('click', function() {
    window.requestAnimationFrame(function() {
      onceBtn.innerText = "...";
      window.requestAnimationFrame(function() {
        runBenchmarkSteps(function() {
          onceBtn.innerText = "Once";
        });
      });  
    });
  });
  container.appendChild(onceBtn);

  var infoDiv = document.createElement('div');
  infoDiv.style['font-family'] = 'monospace';
  container.appendChild(infoDiv);

  function runBenchmarkSteps(done) {
    // Run all the steps;
    var times = {};
    window.benchmarkSteps.forEach(function(bs) {
      var startTime = window.performance.now();
      bs.fn();
      var delta = window.performance.now() - startTime;
      times[bs.name] = delta;
    });
    calcStats(times);

    done();
  }

  var timesPerAction = {};
 
  function calcStats(times) {
    var iH = '';
    window.benchmarkSteps.forEach(function(bs) {
      var tpa = timesPerAction[bs.name];
      if (!tpa) {
        tpa = timesPerAction[bs.name] =  {
          times: [], // circular buffer
          fmtTimes: [],
          nextEntry: 0
        }
      }
      tpa.fmtTimes[tpa.nextEntry] = ('' + times[bs.name]).substr(0,6);
      tpa.times[tpa.nextEntry++] = times[bs.name];
      tpa.nextEntry %= 5;
      var avg = 0;
      tpa.times.forEach(function(x) { avg += x; });
      avg /= Math.min(5, tpa.times.length);
      avg = ('' + avg).substr(0,6);
      iH += '<div>' + ('         ' + bs.name).slice(-10).replace(/ /g, '&nbsp;') + ': avg-5:<b>' + avg + 'ms</b> [' + tpa.fmtTimes.join(', ') + ']ms</div>';
    });
    infoDiv.innerHTML = iH;
  }
});
