import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/application_factory.dart';

import 'package:benchmark_harness/benchmark_harness.dart';


import 'dart:html';
import 'dart:math';
import 'dart:js' as js;

/* Gen 100 different directives */
/*@Component(
  selector: 'tree',
  template: '<span> {{ctrl.data.value}}'
  '<span ng-if="ctrl.data.right != null"><tree data=ctrl.data.right></span>'
  '<span ng-if="ctrl.data.left != null"><tree data=ctrl.data.left></span>'
  '</span>',
  publishAs: 'ctrl')
class TreeComponent {
  @NgOneWay('data')
  var data;

  hello() { print "hello tree"; }
}*/

@Component(
  selector: 'tree-click',
  template: '<span ng-click="ctrl.data.value = \'.\'"> {{ctrl.data.value}}'
  '<span ng-if="ctrl.data.right != null"><tree-click data=ctrl.data.right></span>'
  '<span ng-if="ctrl.data.left != null"><tree-click data=ctrl.data.left></span>'
  '</span>',
  publishAs: 'ctrl')
class TreeComponentWithClick {
  @NgOneWay('data')
  var data;
}

@Component(
  selector: 'heavy-tree',
  template: '<span> {{ctrl.data.value}}'
  '<span ng-if="ctrl.data.right != null"><heavy-tree data=ctrl.data.right a1="1+1" a2=0 a3=0 a4=0 a5=0 a6=0 a7=0 a8=0 a9=0 a10=0 '
  'b1=0 b2=0 b3=0 b4=0 b5=0 b6=0 b7=0 b8=0 b9=0 b10=0 '
  'c1=0 c2=0 c3=0 c4=0 c5=0 c6=0 c7=0 c8=0 c9=0 c10=0 ' 
  'd1=0 d2=0 d3=0 d4=0 d5=0 d6=0 d7=0 d8=0 d9=0 d10=0 '
  'e1=0 e2=0 e3=0 e4=0 e5=0 e6=0 e7=0 e8=0 e9=0 e10=0  ></span>'
  '<span ng-if="ctrl.data.left != null"><heavy-tree data=ctrl.data.left   a1=0 a2=0 a3=0 a4=0 a5=0 a6=0 a7=0 a8=0 a9=0 a10=0 '
  'b1=0 b2=0 b3=0 b4=0 b5=0 b6=0 b7=0 b8=0 b9=0 b10=0 '
  'c1=0 c2=0 c3=0 c4=0 c5=0 c6=0 c7=0 c8=0 c9=0 c10=0 ' 
  'd1=0 d2=0 d3=0 d4=0 d5=0 d6=0 d7=0 d8=0 d9=0 d10=0 ' 
  'e1=0 e2=0 e3=0 e4=0 e5=0 e6=0 e7=0 e8=0 e9=0 e10=0></span>'
  '</span>',
  publishAs: 'ctrl')
class HeavyTreeComponent {
  @NgOneWay('data')
  var data;

  

  @NgOneWay('a1') var a1;
  @NgOneWay('a2') var a2;
  @NgOneWay('a3') var a3;
  @NgOneWay('a4') var a4;
  @NgOneWay('a5') var a5;
  @NgOneWay('a6') var a6;
  @NgOneWay('a7') var a7;
  @NgOneWay('a8') var a8;
  @NgOneWay('a9') var a9;
  @NgOneWay('a10') var a10;
  @NgOneWay('a11') var a11;
  @NgOneWay('a12') var a12;
  @NgOneWay('a13') var a13;
  @NgOneWay('a14') var a14;
  @NgOneWay('a15') var a15;
  @NgOneWay('a16') var a16;
  @NgOneWay('a17') var a17;
  @NgOneWay('a18') var a18;
  @NgOneWay('a19') var a19;
  @NgOneWay('a20') var a20;




  @NgOneWay('e1') var e1;
  @NgOneWay('e2') var e2;
  @NgOneWay('e3') var e3;
  @NgOneWay('e4') var e4;
  @NgOneWay('e5') var e5;
  @NgOneWay('e6') var e6;
  @NgOneWay('e7') var e7;
  @NgOneWay('e8') var e8;
  @NgOneWay('e9') var e9;
  @NgOneWay('e10') var e10;
  @NgOneWay('e11') var e11;
  @NgOneWay('e12') var e12;
  @NgOneWay('e13') var e13;
  @NgOneWay('e14') var e14;
  @NgOneWay('e15') var e15;
  @NgOneWay('e16') var e16;
  @NgOneWay('e17') var e17;
  @NgOneWay('e18') var e18;
  @NgOneWay('e19') var e19;
  @NgOneWay('e20') var e20;

  @NgOneWay('d1') var d1;
  @NgOneWay('d2') var d2;
  @NgOneWay('d3') var d3;
  @NgOneWay('d4') var d4;
  @NgOneWay('d5') var d5;
  @NgOneWay('d6') var d6;
  @NgOneWay('d7') var d7;
  @NgOneWay('d8') var d8;
  @NgOneWay('d9') var d9;
  @NgOneWay('d10') var d10;
  @NgOneWay('d11') var d11;
  @NgOneWay('d12') var d12;
  @NgOneWay('d13') var d13;
  @NgOneWay('d14') var d14;
  @NgOneWay('d15') var d15;
  @NgOneWay('d16') var d16;
  @NgOneWay('d17') var d17;
  @NgOneWay('d18') var d18;
  @NgOneWay('d19') var d19;
  @NgOneWay('d20') var d20;

  @NgOneWay('c1') var c1;
  @NgOneWay('c2') var c2;
  @NgOneWay('c3') var c3;
  @NgOneWay('c4') var c4;
  @NgOneWay('c5') var c5;
  @NgOneWay('c6') var c6;
  @NgOneWay('c7') var c7;
  @NgOneWay('c8') var c8;
  @NgOneWay('c9') var c9;
  @NgOneWay('c10') var c10;
  @NgOneWay('c11') var c11;
  @NgOneWay('c12') var c12;
  @NgOneWay('c13') var c13;
  @NgOneWay('c14') var c14;
  @NgOneWay('c15') var c15;
  @NgOneWay('c16') var c16;
  @NgOneWay('c17') var c17;
  @NgOneWay('c18') var c18;
  @NgOneWay('c19') var c19;
  @NgOneWay('c20') var c20;

  @NgOneWay('b1') var b1;
  @NgOneWay('b2') var b2;
  @NgOneWay('b3') var b3;
  @NgOneWay('b4') var b4;
  @NgOneWay('b5') var b5;
  @NgOneWay('b6') var b6;
  @NgOneWay('b7') var b7;
  @NgOneWay('b8') var b8;
  @NgOneWay('b9') var b9;
  @NgOneWay('b10') var b10;
  @NgOneWay('b11') var b11;
  @NgOneWay('b12') var b12;
  @NgOneWay('b13') var b13;
  @NgOneWay('b14') var b14;
  @NgOneWay('b15') var b15;
  @NgOneWay('b16') var b16;
  @NgOneWay('b17') var b17;
  @NgOneWay('b18') var b18;
  @NgOneWay('b19') var b19;
  @NgOneWay('b20') var b20;

}



class ViewBenchmark extends BenchmarkBase {
  ViewBenchmark(this.numDirs, this.numElements) : super("ViewBenchmark");

  num numDirs;
  num numElements;
  Injector _injector;
  Compiler _compiler;
  DirectiveMap _dm;
  VmTurnZone _zone;
  Scope _scope;
  var _ts;
  var _viewFactory;
  var _linkArgs;

  var _baseNum = 0;

  var html;

  var cleanup, createDom;


  // Run a single Angular expression inside of the Angular Zone.
  void eval(String exp) {
    _zone.run(() {

    });
  }

  // Run all the expressions.
  void run() => eval('');

  void setup() {

    
    var module = new Module()
      ..type(TreeComponent)
      ..type(TreeComponentWithClick)
      ..type(HeavyTreeComponent)
      ..factory(ScopeDigestTTL, (i) => new ScopeDigestTTL.value(15))
      
    ;
    
    

    var injector = applicationFactory().addModule(module).run();
    assert(injector != null);
    _injector = injector;
    _zone = injector.get(VmTurnZone);
    _dm = injector.get(DirectiveMap);
    _ts = injector.get(NodeTreeSanitizer);
    _compiler = injector.get(Compiler);
    _scope = injector.get(Scope);

    _scope.context['initData'] = {
      "value": "top",
      "right": {
        "value": "right"
      },
      "left": {
        "value": "left"
      }
    };

    buildTree(maxDepth, values, curDepth) {
      if (maxDepth == curDepth) return {};
      return {
        "value": values[curDepth],
        "right": buildTree(maxDepth, values, curDepth+1),
        "left": buildTree(maxDepth, values, curDepth+1)
         
      };
    }
      cleanup = (_) => _zone.run(() {
        _scope.context['initData'] = {};
      });

      var count = 0;
      createDom = (_) => _zone.run(() {
        var maxDepth = 9;
        var values = count++ % 2 == 0 ?
            ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '*'] :
            ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', '-'];
        _scope.context['initData'] = buildTree(maxDepth, values, 0);
      });

      js.context['benchmarkSteps'].add(new js.JsObject.jsify({
        "name": "cleanup", "fn": new js.JsFunction.withThis(cleanup)
        }));
      js.context['benchmarkSteps'].add(new js.JsObject.jsify({
        "name": "createDom", "fn": new js.JsFunction.withThis(createDom)
        }));

    

  }

  void teardown() { }
}

// Main function runs the benchmark.
main() {
 var query = window.location.search;
  var args = query.split(',');

  var numElements = args.length > 2 ? int.parse(args[2]) : 30;
  var numDirs = args.length > 1 ? int.parse(args[1]) : 30;

  var benchmark = new ViewBenchmark(numDirs, numElements);

  
  var evalCmds = ['a', 'b'];
  // Use the continuous animated runner if for '?show'
  if (args.length > 0 && args[0] == '?show') {
      benchmark.setup();
      var cmdPos = 0;
      var cmdLen = evalCmds.length;
      var rAFCallback;
      rAFCallback = (timer) {
        var cmd = evalCmds[cmdPos++];
        if (cmdPos == cmdLen) cmdPos = 0;

        benchmark.eval(cmd);
        // Add a tick to the console so we know which expression
        // was run in the requestAnimationFrame.
        window.console.timeStamp(cmd);
        
        window.requestAnimationFrame(rAFCallback);
      };
      window.requestAnimationFrame(rAFCallback);
  } else {
    benchmark.setup();
    //new TimingZone('outer').run(() => benchmark.setup());

    
  }
}
