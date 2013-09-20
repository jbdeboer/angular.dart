library jamine;

import 'package:unittest/unittest.dart';
import 'package:js/js.dart' as js;
import 'package:angular/utils.dart' as utils;

it(name, fn) {
  if (currentDescribe.exclusive) {
    solo_test(name, fn);
  } else {
    test(name, fn);
  }
}
iit(name, fn) => solo_test(name, fn);
xit(name, fn) {}
xdescribe(name, fn) {}
ddescribe(name, fn) => describe(name, fn, true);


class Describe {
  Describe parent;
  String name;
  bool exclusive;
  List<Function> beforeEachFns = [];
  List<Function> afterEachFns = [];

  Describe(this.name, this.parent, [bool this.exclusive=false]) {
    if (parent != null && parent.exclusive) {
      exclusive = true;
    }
  }

  setUp() {
    if (parent != null) {
      parent.setUp();
    }
    beforeEachFns.forEach((fn) => fn());
  }

  tearDown() {
    afterEachFns.reversed.forEach((fn) => fn());
    if (parent != null) {
      parent.tearDown();
    }
  }
}

Describe currentDescribe = new Describe('', null);

describe(name, fn, [bool exclusive=false]) {
  var lastDescribe = currentDescribe;
  currentDescribe = new Describe(name, lastDescribe, exclusive);
  try {
    group(name, () {
      setUp(currentDescribe.setUp);
      fn();
      tearDown(currentDescribe.tearDown);
    });
  } finally {
    currentDescribe = lastDescribe;
  }
}

beforeEach(fn) => currentDescribe.beforeEachFns.add(fn);
afterEach(fn) => currentDescribe.afterEachFns.add(fn);

var jasmine = new Jasmine();

class SpyFunction {
  String name;
  List<List<dynamic>> invocations = [];
  List<List<dynamic>> invocationsWithoutTrailingNulls = [];
  var _andCallFakeFn;

  SpyFunction([this.name]);
  call([a0, a1, a2, a3, a4, a5]) {
    var args = [];
    args.add(a0);
    args.add(a1);
    args.add(a2);
    args.add(a3);
    args.add(a4);
    args.add(a5);
    invocations.add(args);

    var withoutNulls = new List.from(args);
    while (withoutNulls.last == null) {
      withoutNulls.removeLast();
    }
    invocationsWithoutTrailingNulls.add(withoutNulls);

    if (_andCallFakeFn != null) {
      utils.relaxFnApply(_andCallFakeFn, args);
    }
  }

  andCallFake(fn) {
    _andCallFakeFn = fn;
    return this;
  }

  reset() => invocations = [];

  num get count => invocations.length;
  bool get called => count > 0;

  num get callCount => count;
  get argsForCall => invocationsWithoutTrailingNulls;

  firstArgsMatch(a,b,c,d,e,f) {
    var fi = invocations.first;
    print("$fi ${fi.length} [$a] [$b] [$c] [$d] [$e] [$f]");
    assert(fi.length == 6);
    if ("${fi[0]}" != "$a") return false;
    if ("${fi[1]}" != "$b") return false;
    if ("${fi[2]}" != "$c") return false;
    if ("${fi[3]}" != "$d") return false;
    if ("${fi[4]}" != "$e") return false;
    if ("${fi[5]}" != "$f") return false;

    return true;
  }
}

class Jasmine {
  createSpy([String name]) {
    return new SpyFunction(name);
  }
}

main(){}
