import 'package:di/di.dart';
import 'package:angular/angular.dart';
import 'package:angular/core_dom/module_internal.dart';
import 'package:angular/application_factory.dart';
import 'package:angular/change_detection/ast_parser.dart';
import 'package:angular/change_detection/watch_group.dart';


import 'dart:html';
import 'dart:math';
import 'dart:js' as js;
import 'dart:async';

@Component(
    selector: 'tree',
    template: '<span> {{ctrl.data.value}}'
    '<span ng-if="ctrl.data.right != null"><tree data=ctrl.data.right></span>'
    '<span ng-if="ctrl.data.left != null"><tree data=ctrl.data.left></span>'
    '</span>',
    publishAs: 'ctrl')
class TreeComponent {
  @NgOneWay('data')
  var data;
}

@Component(
    selector: 'tree-url',
    templateUrl: 'tree-tmpl.html',
    publishAs: 'ctrl')
class TreeUrlComponent {
  @NgOneWay('data')
  var data;
}


// This is a baseline implementation of TreeComponent.
// It assumes the data never changes and simply throws elements on the DOM
@Component(
  selector: 'ng-free-tree',
  template: ''
  )
class NgFreeTree implements ShadowRootAware {
  var _data;

  @NgOneWay('data')
  set data(v) {
    _data = v;
    if (sroot != null)
    updateElement(sroot, _data);
  }

  ShadowRoot sroot;

  void onShadowRoot(root) {
    sroot = root;
    if (_data != null) updateElement(sroot, _data);
  }

  Element newFreeTree(tree) {
    var elt = new Element.tag('ng-fre-tree');
    var root = elt.createShadowRoot();

    var s = new SpanElement();
    root.append(s);
    var value = tree['value'];
    if (value != null) {
      s.text = " $value";
    }
    if (tree.containsKey('right')) {
      s.append(new SpanElement()
          ..append(newFreeTree(tree['right'])));
    }
    if (tree.containsKey('left')) {
      s.append(new SpanElement()
        ..append(newFreeTree(tree['left'])));
    }
    return elt;
  }

  updateElement(root, tree) {
    // Not quite acurate
    root.innerHtml = '';
    root.append(newFreeTree(tree));
  }
}

var treeValueAST, treeRightNotNullAST, treeLeftNotNullAST, treeRightAST, treeLeftAST, treeAST;
/**
 *  A baseline version of TreeComponent which uses Angular's Scope to
 *  manage data.  This version is setting up data binding so arbitrary
 *  elements in the tree can change.
 *
 *  Note that removing subtrees is not implemented as that feature
 *  is never exercised in the benchmark.
 */
@Component(
  selector: 'ng-free-tree-scoped',
  template: ''
  )
class NgFreeTreeScoped implements ShadowRootAware {
  var _data;

  @NgOneWay('data')
  set data(v) {
    _data = v;
    if (sroot != null)
    updateElement(sroot, _data);
  }

  ShadowRoot sroot;
  Scope scope;
  NgFreeTreeScoped(Scope this.scope);

  void onShadowRoot(root) {
    sroot = root;
    if (_data != null) updateElement(sroot, _data);
  }

  Element newFreeTree(parentScope, treeExpr) {
    var elt = new Element.tag('ng-fre-tree');
    var root = elt.createShadowRoot();
    var scope = parentScope.createChild({});

    parentScope.watchAST(treeExpr, (v, _) {
      scope.context['tree'] = v;
    });

    var s = new SpanElement();
    root.append(s);
    scope.watchAST(treeValueAST, (v, _) {
      if (v != null) {
        s.text = " $v";
      }
    });

    scope.watchAST(treeRightNotNullAST, (v, _) {
      if (v != true) return;
      s.append(new SpanElement()
          ..append(newFreeTree(scope, treeRightAST)));
    });

    scope.watchAST(treeLeftNotNullAST, (v, _) {
      if (v != true) return;
      s.append(new SpanElement()
        ..append(newFreeTree(scope, treeLeftAST)));
    });

    return elt;
  }

  Scope treeScope;
  updateElement(root, tree) {
    // Not quite acurate
    if (treeScope != null) {
      treeScope.destroy();
    }
    treeScope = scope.createChild({});
    treeScope.context['tree'] = tree;
    root.innerHtml = '';
    root.append(newFreeTree(treeScope, treeAST));
  }
}


/**
 * A scope-backed baseline that data-binds through a Dart object.
 * This is the pattern that we are using in Components.
 *
 * The benchmark does not show this approach as any slower than
 * binding to the model directly.
 */
class FreeTreeClass {
  // One-way bound
  var tree;
  Scope parentScope;

  FreeTreeClass(this.parentScope, treeExpr) {
    parentScope.watchAST(treeExpr, (v, _) {
      tree = v;
    });
  }

  Element element() {
    var elt = new Element.tag('ng-fre-tree');
    var root = elt.createShadowRoot();
    var scope = parentScope.createChild(this);

    var s = new SpanElement();
    root.append(s);
    scope.watchAST(treeValueAST, (v, _) {
      if (v != null) {
        s.text = " $v";
      }
    });
    
    scope.watchAST(treeRightNotNullAST, (v, _) {
      if (v != true) return;
      s.append(new SpanElement()
          ..append(new FreeTreeClass(scope, treeRightAST).element()));
    });
    
    scope.watchAST(treeLeftNotNullAST, (v, _) {
      if (v != true) return;
      s.append(new SpanElement()
        ..append(new FreeTreeClass(scope, treeLeftAST).element()));
    });
    
    return elt;
  }
}

@Component(
  selector: 'ng-free-tree-class',
  template: ''
  )
class NgFreeTreeClass implements ShadowRootAware {
  var _data;

  @NgOneWay('data')
  set data(v) {
    _data = v;
    if (sroot != null)
    updateElement(sroot, _data);
  }

  ShadowRoot sroot;
  Scope scope;
  NgFreeTreeClass(Scope this.scope);

  void onShadowRoot(root) {
    sroot = root;
    if (_data != null) updateElement(sroot, _data);
  }


  var treeScope;
  updateElement(root, tree) {
    // Not quite acurate
    if (treeScope != null) {
      treeScope.destroy();
    }
    treeScope = scope.createChild({});
    treeScope.context['tree'] = tree;
    root.innerHtml = '';
    root.append(new FreeTreeClass(treeScope, treeAST).element());
  }
}

class FakeContext implements Map {
  var initData;
  var useDefault;
  var scope;

  FakeContext(this.scope);

  operator [](k) {
    if (k == "useDefault") {
      return scope.useDefault;
    }
  }

  operator []=(k, v) {
    if (k == "useDefault") {
      scope.useDefault = v;
    }
    if (k == "initData") {
      if (v == null) { throw []; }
      scope.initData = v;
    }
  }
}

@Injectable()
class FakeScope implements Scope {

  RootScope rootScope;
  var children = [];

  var onDestory;

  FakeScope(this.rootScope, VmTurnZone zone) {
    zone.onTurnDone = rootScope.apply;
    zone.onScheduleMicrotask = rootScope.runAsync;
    context = new FakeContext(this);
  }

  FakeScope._child(this.context, this.rootScope, this._initData, this.onDestory);

  var context;
  var isAttached = true;

  var _useDefault;
  get useDefault => _useDefault;
  void set useDefault(x) {
    _useDefault = x;
    scheduleMicrotask(() => useDefaultRF.forEach((f) => f(x, null)));
  }
  var useDefaultRF = [];

  var _initData;

  void set initData(x) {
    _initData = x;
    rootScope.initDataRF.forEach((f) => f(x, null));

    //children.forEach((c) => c.gotData());
    gotData(true);
  }

  var destoryStream;
  var destoryCompleter;

  var onData = [];
  var _data;
  var hasData = false;

  dataFn(fn) {
    if (_data != null) {
      fn(_data);
      onData.add(fn);
    } else {
      onData.add(fn);
      gotData();
    }
  }

  gotData([force]) {
    if (force == null && _data != null) return;
    if (context['ctrl'] == null) {
      _data = null;
    } else {
      _data = context['ctrl'].data;
    }

    //if (_data == null) { return; }

    //hasData = true;
    onData.forEach((f) => f(_data));
    children.forEach((c) => c != null ? c.gotData(force) : false);
  }


  Watch watch(String expression, ReactionFn reactionFn, {context, formatters, bool canChangeModel, bool collection}) {
    if (expression == "1") {
      scheduleMicrotask(() => reactionFn(1, null));
      return new FakeWatch();
    }

    if (expression == "useDefault") {
      useDefaultRF.add(reactionFn);
      useDefault = _useDefault;
      return null;
    }

    throw "Watch not implemented: $expression";
  }

  Watch watchAST(AST ast, ReactionFn reactionFn, {bool canChangeModel}) {
    var name = (ast as FakeAST).name;
    if (name == "useDefault") {
      useDefaultRF.add(reactionFn);
      useDefault = _useDefault;
      return null;
    }

    if (name == "initData") {
      if (_initData == null) {
        rootScope.initDataRF.add(reactionFn);
      } else {
        reactionFn(_initData, null);
        rootScope.initDataRF.add(reactionFn);
      }
      //initData = _initData;
      return null;
    }

    if (name == "false") {
      scheduleMicrotask(() => reactionFn(false, null));
      return null;
    }
    if (name == "1") {
      scheduleMicrotask(() => reactionFn(1, null));
      return new FakeWatch();
    }

    if (name == '" "+(ctrl.data.value|stringify)') {
      dataFn((d) { reactionFn((d == null || d['value'] == null) ? '' : ' ${d['value']}', null);});
      return null;
    }

    if (name == 'ctrl.data.right != null') {
      dataFn((d) => reactionFn(d != null && d['right'] != null, null));
      return null;
    }
    if (name == 'ctrl.data.left != null') {
      dataFn((d) => reactionFn(d != null && d['left'] != null, null));
      return null;
    }
    if (name == 'ctrl.data.left') {
      dataFn((d) => reactionFn(d == null ? null : d['left'], null));
      return null;
    }
    if (name == 'ctrl.data.right') {
      dataFn((d) => reactionFn(d == null ? null : d['right'], null));
      return null;
    }

    throw "Watch AST not implemented: ${(ast as FakeAST).name}";
  }

  on(String name) {
    if (name != "ng-destroy") throw "bad on: $name";
    if (destoryStream == null) {
      destoryCompleter = new Completer();
      destoryStream = new StreamController.broadcast();
    }
    return destoryStream.stream;
  }

  Scope createChild(Object childContext) {

    var cPos = children.length;
    var c = new FakeScope._child(childContext, rootScope, _initData, () { children[cPos] = null; });
    children.add(c);
    c.gotData();
    return c;
  }

  void destroy() {
    isAttached = false;
    if (onDestory != null) { onDestory(); }
  }
}

class FakeWatch implements Watch {
  remove() {}
}
@Injectable()
class FakeRootScope implements RootScope {
  var initDataRF = [];


  var _domWriteFns = [];

  domWrite(fn) {
    _domWriteFns.add(fn);
  }

  List _runAsyncFns = [];

  void runAsync(fn()) {
    _runAsyncFns.add(fn);
  }

  dynamic apply([expression, Map locals]) {
    print("apply ${_domWriteFns.length}");
    while (_runAsyncFns.isNotEmpty) {
      var toRun = _runAsyncFns;
      _runAsyncFns = [];
      toRun.forEach((fn) => fn());
    }
    var toRun = _domWriteFns;
    _domWriteFns = [];
    toRun.forEach((fn) => fn());
    print("done apply");
  }
}

class FakeAST implements AST {
  String name;

  var parsedExp;

}
@Injectable()
class FakeASTParser implements ASTParser {
  Parser _parser;

  FakeASTParser(this._parser);

  AST call(String input, {formatters, bool collection}) {
    return new FakeAST()
      ..name = input
      ..parsedExp = _parser(input);
  }
}

// Main function runs the benchmark.
main() {
  var cleanup, createDom;

  var module = new Module()
      ..type(TreeComponent)
      ..type(TreeUrlComponent)
      ..type(NgFreeTree)
      ..type(NgFreeTreeScoped)
      ..type(NgFreeTreeClass)
      ..type(Scope, implementedBy: FakeScope)
      ..type(RootScope, implementedBy: FakeRootScope)
      ..type(ASTParser, implementedBy: FakeASTParser)
      ..factory(ScopeDigestTTL, (i) => new ScopeDigestTTL.value(15))
      ..bind(CompilerConfig, toValue: new CompilerConfig.withOptions(elementProbeEnabled: false));

  var injector = applicationFactory().addModule(module).run();
  assert(injector != null);

  // Set up ASTs
  var parser = injector.get(ASTParser);
  treeValueAST = parser('tree.value');
  treeRightNotNullAST = parser('tree.right != null');
  treeLeftNotNullAST = parser('tree.left != null');
  treeRightAST = parser('tree.right');
  treeLeftAST = parser('tree.left');
  treeAST = parser('tree');

  VmTurnZone zone = injector.get(VmTurnZone);
  Scope scope = injector.get(Scope);

  scope.context['initData'] = {
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
  cleanup = (_) => zone.run(() {
    scope.context['initData'] = {};
  });

  var count = 0;
  createDom = (_) => zone.run(() {
    var maxDepth = 9;
    var values = count++ % 2 == 0 ?
    ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '*'] :
    ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', '-'];
    scope.context['initData'] = buildTree(maxDepth, values, 0);
  });

  js.context['benchmarkSteps'].add(new js.JsObject.jsify({
      "name": "cleanup", "fn": new js.JsFunction.withThis(cleanup)
  }));
  js.context['benchmarkSteps'].add(new js.JsObject.jsify({
      "name": "createDom", "fn": new js.JsFunction.withThis(createDom)
  }));
}
