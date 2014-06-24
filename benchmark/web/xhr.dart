import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/application_factory.dart';
import 'package:angular/change_detection/ast_parser.dart';

import 'dart:convert';

import 'dart:html';
import 'dart:math';
import 'dart:js' as js;

@Component(
    selector: 'responseType',
    template: '<span> {{ctrl.output}} </span>',
    publishAs: 'ctrl')
class ResponseType {
	var output = "waiting";
	var watch = new Stopwatch();
	var read = new Stopwatch();
  ResponseType() {
  	watch.start();
  	HttpRequest.request('data.json', responseType: 'json').then((http) {
  		watch.stop();
  		read.start();
  		var len = http.response['list'].length;
  		read.stop();

  		output = "Done (fetch time: ${watch.elapsedMilliseconds} ms, read list time: ${read.elapsedMilliseconds} ms) [$len]";
  	});
  }
}

@Component(
    selector: 'parse',
    template: '<span> {{ctrl.output}} </span>',
    publishAs: 'ctrl')
class Parse {
	var output = "waiting";
	var watch = new Stopwatch();
	var read = new Stopwatch();
  Parse() {
  	watch.start();
  	HttpRequest.request('data.json').then((http) {
  		var json = JSON.decode(http.response);
  		watch.stop();
  		read.start();
  		var len = json['list'].length;
  		read.stop();

        output = "Done (fetch + parse time: ${watch.elapsedMilliseconds} ms, read list time: ${read.elapsedMilliseconds} ms) [$len]";
  	});
  }
}



// Main function runs the benchmark.
main() {
  var cleanup, createDom;

  var module = new Module()
      ..type(Parse)
      ..type(ResponseType)
      ..bind(CompilerConfig, toValue: new CompilerConfig.withOptions(elementProbeEnabled: false));

  var injector = applicationFactory().addModule(module).run();
  assert(injector != null);


  VmTurnZone zone = injector.get(VmTurnZone);
  Scope scope = injector.get(Scope);

  cleanup = (_) => zone.run(() {
    scope.context['running'] = false;
  });

  var count = 0;
  createDom = (_) => zone.run(() {
  	scope.context['running'] = true;
  });

  js.context['benchmarkSteps'].add(new js.JsObject.jsify({
      "name": "cleanup", "fn": new js.JsFunction.withThis(cleanup)
  }));
  js.context['benchmarkSteps'].add(new js.JsObject.jsify({
      "name": "createDom", "fn": new js.JsFunction.withThis(createDom)
  }));
}
