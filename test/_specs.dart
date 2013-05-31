library ng_specs;


import 'dart:html';
import 'package:unittest/unittest.dart' as unit;
import 'package:angular/debug.dart';
import 'dart:mirrors' as mirror;
import 'package:angular/angular.dart';
import 'jasmine_syntax.dart';
import 'package:di/di.dart';
import 'package:unittest/mock.dart';

export 'package:unittest/unittest.dart';
export 'package:angular/debug.dart';
export 'package:angular/angular.dart';
export 'dart:html';
export 'jasmine_syntax.dart';
export 'package:di/di.dart';
export 'package:unittest/mock.dart';

es(String html) {
  var div = new DivElement();
  div.innerHtml = html;
  return div.nodes;
}

e(String html) => es(html).first;

Expect expect(actual, [unit.Matcher matcher]) {
  if (?matcher) {
    unit.expect(actual, matcher);
  }
  return new Expect(actual);
}

class Expect {
  var actual;
  var not;
  Expect(this.actual) {
    not = new NotExpect(this);
  }

  toEqual(expected) => unit.expect(actual, unit.equals(expected));
  toBe(expected) => unit.expect(actual,
      unit.predicate((actual) => identical(expected, actual), '$expected'));
  toThrow(exception) => unit.expect(actual, unit.throwsA(unit.contains(exception)));
  toBeFalsy() => unit.expect(actual, (v) => v is false || !(v is Object));
  toBeTruthy() => unit.expect(actual, (v) => v is Object);
  toBeDefined() => unit.expect(actual, (v) => v is Object);
  toBeNull() => unit.expect(actual, unit.isNull);
  toBeNotNull() => unit.expect(actual, unit.isNotNull);

  toHaveBeenCalled() => unit.expect(actual.called, true, reason: 'method not called');
  toHaveBeenCalledOnce() => unit.expect(actual.count, 1, reason: 'method invoked ${actual.count} expected once');
}

class NotExpect {
  Expect expect;
  get actual => expect.actual;
  NotExpect(this.expect);

  toHaveBeenCalled() => unit.expect(actual.called, false, reason: 'method called');
  toThrow() => actual();
}

$(selector) {
  return new JQuery(selector);
}

class JQuery implements List<Node> {
  List<Node> _list = [];

  JQuery([selector]) {
    if (!?selector) {
      // do nothing;
    } else if (selector is String) {
      _list.addAll(es(selector));
    } else if (selector is Node) {
      add(selector);
    } else {
      throw new ArgumentError();
    }
  }

  noSuchMethod(Invocation invocation) => mirror.reflect(_list).delegate(invocation);

  _toHtml(node, [bool outer = false]) {
    if (node is Comment) {
      return '<!--${node.text}-->';
    } else {
      return outer ? node.outerHtml : node.innerHtml;
    }
  }

  accessor(Function getter, Function setter, [value]) {
    // TODO(dart): ?value does not work, since value was passed. :-(
    var setterMode = ?value && value != null;
    var result = setterMode ? this : '';
    _list.forEach((node) {
      if (setterMode) {
        setter(node, value);
      } else {
        result = '$result${getter(node)}';
      }
    });
    return result;
  }

  html([String html]) => accessor((n) => _toHtml(n), (n, v) => n.innerHtml = v, html);
  text([String text]) => accessor((n) => n.text, (n, v) => n.text = v, text);
  contents() => fold(new JQuery(), (jq, node) => jq..addAll(node.nodes));
  toString() => fold('', (html, node) => '$html${_toHtml(node, true)}');
  eq(num childIndex) => $(this[childIndex]);
}

class Logger implements List {
  List<Node> _list = [];

  noSuchMethod(Invocation invocation) => mirror.reflect(_list).delegate(invocation);
}

class SpecInjector {
  Injector injector;
  List<Module> modules = [new Module()..value(Expando, new Expando('specExpando'))];

  module(Function fn) {
    Module module = new Module();
    modules.add(module);
    fn(module);
  }

  inject(Function fn, declarationStack) {
    if (injector == null) {
      injector = new Injector(modules);
    }
    try {
      injector.invoke(fn);
    } catch (e, s) {
      var msg;
      if (e is mirror.MirroredUncaughtExceptionError) {
        msg = e.exception_string + "\n ORIGINAL Stack trace:\n" + e.stacktrace.toString();
      } else {
        msg = e.toString();
      }
      var frames = declarationStack.toString().split('\n');
      frames.removeAt(0);
      var declaredAt = frames.join('\n');
      throw msg + "\n DECLARED AT:\n" + declaredAt;
    }
  }

  reset() { injector = null; }
}

SpecInjector currentSpecInjector = null;
inject(Function fn) {
  var stack = null;
  try {
    throw '';
  } catch (e, s) {
    stack = s;
  }
  if (currentSpecInjector == null ) {
    return () {
      return currentSpecInjector.inject(fn, stack);
    };
  } else {
    return currentSpecInjector.inject(fn, stack);
  }
}
module(Function fn) {
  if (currentSpecInjector == null ) {
    return () {
      return currentSpecInjector.module(fn);
    };
  } else {
    return currentSpecInjector.module(fn);
  }
}

main() {
  beforeEach(() => currentSpecInjector = new SpecInjector());
  beforeEach(module(angularModule));
  afterEach(() => currentSpecInjector = null);
}
