library angular;

import "dart:collection";
import "dart:mirrors";
import "dart:async" as async;
import "dart:json" as json;
import 'dart:html' as dom;
import 'package:di/di.dart';
import 'debug.dart';

part 'block.dart';
part 'block_list.dart';
part 'block_type.dart';
part 'compiler.dart';
part 'directive.dart';
part 'directives/ng_bind.dart';
part 'directives/ng_mustache.dart';
part 'directives/ng_repeat.dart';
part 'dom_utilities.dart';
part 'exception_handler.dart';
part 'http.dart';
part 'interface_typing.dart';
part 'interpolate.dart';
part 'mirrors.dart';
part 'node_cursor.dart';
part 'parser.dart';
part 'scope.dart';
part 'selector.dart';

ASSERT(condition) {
  if (!condition) {
    throw new AssertionError();
  }
}

num id = 0;

nextUid() {
  return '_${id++}';
}

noop() {}

toJson(obj) {
  try {
    return json.stringify(obj);
  } catch(e) {
    return "NOT-JSONABLE (see toJson(obj) in angular.dart)";
  }
}


typedef FnWith0Args();
typedef FnWith1Args(a0);
typedef FnWith2Args(a0, a1);
typedef FnWith3Args(a0, a1, a2);
typedef FnWith4Args(a0, a1, a2, a3);
typedef FnWith5Args(a0, a1, a2, a3, a4);

relaxFnApply(Function fn, List args) {
  // Check the args.length to support functions with optional parameters.
  var argsLen = args.length;
  if (fn is Function && fn != null) {
    if (fn is FnWith5Args && argsLen > 4) {
      return fn(args[0], args[1], args[2], args[3], args[4]);
    } else if (fn is FnWith4Args && argsLen > 3) {
      return fn(args[0], args[1], args[2], args[3]);
    } else if (fn is FnWith3Args&& argsLen > 2 ) {
      return fn(args[0], args[1], args[2]);
    } else if (fn is FnWith2Args && argsLen > 1 ) {
      return fn(args[0], args[1]);
    } else if (fn is FnWith1Args && argsLen > 0) {
      return fn(args[0]);
    } else if (fn is FnWith0Args) {
      return fn();
    } else {
      throw "Unknown function type, expecting 0 to 5 args.";
    }
  } else {
    throw "Missing function.";
  }
}

_relaxFnArgs(Function fn) {
  return ([a0, a1, a2, a3, a4]) {
    if (fn is FnWith5Args) {
      return fn(a0, a1, a2, a3, a4);
    } else if (fn is FnWith4Args) {
      return fn(a0, a1, a2, a3);
    } else if (fn is FnWith3Args) {
      return fn(a0, a1, a2);
    } else if (fn is FnWith2Args) {
      return fn(a0, a1);
    } else if (fn is FnWith1Args) {
      return fn(a0);
    } else if (fn is FnWith0Args) {
      return fn();
    } else {
      throw "Unknown function type, expecting 0 to 5 args.";
    }
  };
}



class AngularModule extends Module {
  DirectiveRegistry _directives = new DirectiveRegistry();

  AngularModule() {
    value(DirectiveRegistry, _directives);
    type(Compiler, Compiler);
    type(BlockFactory, BlockFactory);
    type(BlockTypeFactory, BlockTypeFactory);
    type(BlockListFactory, BlockListFactory);
    type(ExceptionHandler, ExceptionHandler);
    type(Scope, Scope);
    type(Parser, Parser);
    type(Interpolate, Interpolate);
    type(Http, Http);
  }

  directive(Type directive) {
    _directives.register(directive);
    return this;
  }
}

angularModule(AngularModule module) {
  module.value(ScopeDigestTTL, new ScopeDigestTTL(5));

  module.directive(NgTextMustacheDirective);
  module.directive(NgAttrMustacheDirective);

  module.directive(NgBindAttrDirective);
  module.directive(NgRepeatAttrDirective);
}
