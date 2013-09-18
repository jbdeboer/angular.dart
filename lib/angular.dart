library angular;

import 'package:di/di.dart';
import 'package:di/dynamic_injector.dart';
import 'package:perf_api/perf_api.dart';

import 'dart:html' as dom; // TODO(misko): to be deleted
import 'controller.dart';

import 'zone.dart';                   export 'zone.dart';
import 'cache.dart';                  export 'cache.dart';
import 'interpolate.dart';            export 'interpolate.dart';
import 'dom/http.dart';               export 'dom/http.dart';
import 'scope.dart';                  export 'scope.dart';
import 'exception_handler.dart';      export 'exception_handler.dart';
import 'parser/parser_library.dart';  export 'parser/parser_library.dart';
import 'dom/all.dart';                export 'dom/all.dart';
import 'directives/all.dart';         export 'directives/all.dart';


class AngularModule extends Module {
  DirectiveRegistry _directives = new DirectiveRegistry();
  ControllerRegistry _controllers = new ControllerRegistry();

  AngularModule() {
    value(DirectiveRegistry, _directives);
    value(ControllerRegistry, _controllers);
    type(Compiler);
    type(ExceptionHandler);
    type(Scope);
    type(Parser, implementedBy: DynamicParser);
    type(DynamicParser);
    type(Lexer);
    type(ParserBackend);
    type(Interpolate);
    type(Http);
    type(UrlRewriter);
    type(HttpBackend);
    type(BlockCache);
    type(TemplateCache);
    type(GetterSetter);
    type(Profiler);
    type(ScopeDigestTTL);
    type(dom.NodeTreeSanitizer, implementedBy: NullTreeSanitizer);


    directive(NgTextMustacheDirective);
    directive(NgAttrMustacheDirective);

    directive(NgBindAttrDirective);
    directive(NgClassAttrDirective);
    directive(NgClickAttrDirective);
    directive(NgCloakAttrDirective);
    directive(NgControllerAttrDirective);
    directive(NgDisabledAttrDirective);
    directive(NgHideAttrDirective);
    directive(NgIfAttrDirective);
    directive(NgIncludeAttrDirective);
    directive(NgRepeatAttrDirective);
    directive(NgShowAttrDirective);
    directive(NgStyleAttrDirective);

    directive(InputTextDirective);
    directive(InputCheckboxDirective);
    directive(NgModel);
  }

  directive(Type directive) {
    _directives.register(directive);
    return this;
  }

  controller(String name, Type controllerType) {
    _controllers.register(name, controllerType);
    type(controllerType);
  }
}


// helper for bootstrapping angular
bootstrapAngular(modules, [rootElementSelector = '[ng-app]']) {
  var allModules = new List.from(modules);
  List<dom.Node> topElt = dom.query(rootElementSelector).nodes.toList();
  assert(topElt.length > 0);

  // The injector must be created inside the zone, so we create the
  // zone manually and give it back to the injector as a value.
  Zone zone = new Zone();
  allModules.add(new Module()..value(Zone, zone));

  zone.run(() {
    Injector injector = new DynamicInjector(modules: allModules);
    injector.get(Compiler)(topElt)(injector, topElt);
  });
}

