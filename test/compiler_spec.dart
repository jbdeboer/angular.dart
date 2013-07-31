import "_specs.dart";
import "_log.dart";
import "dart:mirrors";


@NgComponent(visibility: NgDirective.DIRECT_CHILDREN_VISIBILITY)
class TabComponent {
  int id = 0;
  Log log;
  LocalAttrDirective local;
  TabComponent(Log this.log, LocalAttrDirective this.local, Scope scope) {
    log('TabComponent-${id++}');
    local.ping();
  }
}

class PaneComponent {
  TabComponent tabComponent;
  LocalAttrDirective localDirective;
  Log log;
  PaneComponent(TabComponent this.tabComponent, LocalAttrDirective this.localDirective, Log this.log, Scope scope) {
    log('PaneComponent-${tabComponent.id++}');
    localDirective.ping();
  }
}

@NgDirective(visibility: NgDirective.LOCAL_VISIBILITY)
class LocalAttrDirective {
  int id = 0;
  Log log;
  LocalAttrDirective(Log this.log);
  ping() {
    log('LocalAttrDirective-${id++}');
  }
}

@NgDirective(visibility: NgDirective.CHILDREN_VISIBILITY, transclude: true)
class SimpleTranscludeInAttachAttrDirective {
  SimpleTranscludeInAttachAttrDirective(BlockHole blockHole, BoundBlockFactory boundBlockFactory, Log log, Scope scope) {
    scope.$evalAsync(() {
      var block = boundBlockFactory(scope);
      block.insertAfter(blockHole);
      log('SimpleTransclude');
    });
  }
}

class IncludeTranscludeAttrDirective {
  IncludeTranscludeAttrDirective(SimpleTranscludeInAttachAttrDirective simple, Log log) {
    log('IncludeTransclude');
  }
}

class PublishTypesDirectiveSuperType {
}

@NgDirective(publishTypes: const [PublishTypesDirectiveSuperType])
class PublishTypesAttrDirective implements PublishTypesDirectiveSuperType {
  static Injector _injector;
  PublishTypesAttrDirective(Injector injector) {
    _injector = injector;
  }
}

main() {

  describe('dte.compiler', () {
    Compiler $compile;
    Injector injector;
    Scope $rootScope;
    DirectiveRegistry directives;

    beforeEach(module((AngularModule module) {
      module
        ..directive(TabComponent)
        ..directive(PublishTypesAttrDirective)
        ..directive(PaneComponent)
        ..directive(SimpleTranscludeInAttachAttrDirective)
        ..directive(IncludeTranscludeAttrDirective)
        ..directive(LocalAttrDirective);
      return (Injector _injector) {
        injector = _injector;
        $compile = injector.get(Compiler);
        $rootScope = injector.get(Scope);
      };
    }));

    it('should compile basic hello world', inject(() {
      var element = $('<div ng-bind="name"></div>');
      var template = $compile(element);

      $rootScope['name'] = 'angular';
      template(injector, element);

      expect(element.text()).toEqual('');
      $rootScope.$digest();
      expect(element.text()).toEqual('angular');
    }));

    it('should not throw on an empty list', inject(() {
      $compile([]);
    }));

    it('should compile a directive in a child', inject(() {
      var element = $('<div><div ng-bind="name"></div></div>');
      var template = $compile(element);

      $rootScope['name'] = 'angular';


      template(injector, element);

      expect(element.text()).toEqual('');
      $rootScope.$digest();
      expect(element.text()).toEqual('angular');
    }));


    it('should compile repeater', inject(() {
      var element = $('<div><div ng-repeat="item in items" ng-bind="item"></div></div>');
      var template = $compile(element);

      $rootScope.items = ['A', 'b'];
      template(injector, element);

      expect(element.text()).toEqual('');
      // TODO(deboer): Digest twice until we have dirty checking in the scope.
      $rootScope.$digest();
      $rootScope.$digest();
      expect(element.text()).toEqual('Ab');

      $rootScope.items = [];
      $rootScope.$digest();
      expect(element.html()).toEqual('<!--ANCHOR: [ng-repeat]=item in items-->');
    }));

    it('should compile repeater with children', inject((Compiler $compile) {
      var element = $('<div><div ng-repeat="item in items"><div ng-bind="item"></div></div></div>');
      var template = $compile(element);

      $rootScope.items = ['A', 'b'];
      template(injector, element);

      expect(element.text()).toEqual('');
      // TODO(deboer): Digest twice until we have dirty checking in the scope.
      $rootScope.$digest();
      $rootScope.$digest();
      expect(element.text()).toEqual('Ab');

      $rootScope.items = [];
      $rootScope.$digest();
      expect(element.html()).toEqual('<!--ANCHOR: [ng-repeat]=item in items-->');
    }));


    it('should compile text', inject((Compiler $compile) {
      var element = $('<div>{{name}}<span>!</span></div>').contents();
      element.remove();

      var template = $compile(element);

      $rootScope.name = 'OK';
      var block = template(injector);

      element = $(block.elements);

      block;

      expect(element.text()).toEqual('!');
      $rootScope.$digest();
      expect(element.text()).toEqual('OK!');
    }));


    it('should compile nested repeater', inject((Compiler $compile) {
      var element = $(
          '<div>' +
            '<ul ng-repeat="lis in uls">' +
               '<li ng-repeat="li in lis">{{li}}</li>' +
            '</ul>' +
          '</div>');
      var template = $compile(element);

      $rootScope.uls = [['A'], ['b']];
      template(injector, element);

      expect(element.text()).toEqual('');
      $rootScope.$digest();
      expect(element.text()).toEqual('Ab');
    }));


    describe("interpolation", () {
      it('should interpolate attribute nodes', inject(() {
        var element = $('<div test="{{name}}"></div>');
        var template = $compile(element);

        $rootScope.name = 'angular';
        template(injector, element);

        $rootScope.$digest();
        expect(element.attr('test')).toEqual('angular');
      }));


      it('should interpolate text nodes', inject(() {
        var element = $('<div>{{name}}</div>');
        var template = $compile(element);

        $rootScope.name = 'angular';
        template(injector, element);

        expect(element.text()).toEqual('');
        $rootScope.$digest();
        expect(element.text()).toEqual('angular');
      }));
    });


    describe('components', () {
      beforeEach(module((AngularModule module) {
        module.directive(SimpleComponent);
        module.directive(CamelCaseMapComponent);
        module.directive(IoComponent);
        module.directive(ParentExpressionComponent);
        module.directive(PublishMeComponent);
        module.directive(LogComponent);
        module.directive(FunctionRunnerComponent);
      }));

      it('should create a simple component', async(inject(() {
        $rootScope.name = 'OUTTER';
        $rootScope.sep = '-';
        var element = $(r'<div>{{name}}{{sep}}{{$id}}:<simple>{{name}}{{sep}}{{$id}}</simple></div>');
        BlockFactory blockFactory = $compile(element);
        $rootScope.$apply(() {
          Block block = blockFactory(injector, element);
        });

        nextTurn();
        expect(element.textWithShadow()).toEqual('OUTTER-_1:INNER_2(OUTTER-_1)');
      })));

      it('should create a component that can access parent scope', async(inject(() {
        $rootScope.fromParent = "should not be used";
        $rootScope.val = "poof";
        var element = $('<parent-expression from-parent=val></parent-expression>');

        $rootScope.$apply(() {
          $compile(element)(injector, element);
        });

        nextTurn();
        expect(renderedText(element)).toEqual('inside poof');
      })));

      it('should behave nicely if a mapped attribute is missing', async(inject(() {
        var element = $('<parent-expression></parent-expression>');
        $rootScope.$apply(() {
          $compile(element)(injector, element);
        });

        nextTurn();
        expect(renderedText(element)).toEqual('inside ');
      })));

      it('should behave nicely if a mapped attribute evals to null', async(inject(() {
        $rootScope.val = null;
        var element = $('<parent-expression fromParent=val></parent-expression>');
        $rootScope.$apply(() {
          $compile(element)(injector, element);
        });

        nextTurn();
        expect(renderedText(element)).toEqual('inside ');
      })));

      it('should create a component with IO', inject(() {
        var element = $(r'<div><io attr="A" expr="name" ondone="done=true"></io></div>');
        $compile(element)(injector, element);
        $rootScope.name = 'misko';
        $rootScope.$apply();
        var component = $rootScope.ioComponent;
        expect(component.scope.name).toEqual(null);
        expect(component.scope.attr).toEqual('A');
        expect(component.scope.expr).toEqual('misko');
        component.scope.expr = 'angular';
        $rootScope.$apply();
        expect($rootScope.name).toEqual('angular');
        expect($rootScope.done).toEqual(null);
        component.scope.ondone();
        expect($rootScope.done).toEqual(true);
      }));

      it('should create a component with IO and "=" binding value should be available', inject(() {
        $rootScope.name = 'misko';
        var element = $(r'<div><io attr="A" expr="name" ondone="done=true"></io></div>');
        $compile(element)(injector, element);
        var component = $rootScope.ioComponent;
        expect(component.scope.expr).toEqual('misko');
        $rootScope.$apply();
        component.scope.expr = 'angular';
        $rootScope.$apply();
        expect($rootScope.name).toEqual('angular');
      }));

      it('should expose mapped attributes as camel case', inject(() {
        var element = $('<camel-case-map camel-case=6></camel-case-map>');
        $compile(element)(injector, element);
        $rootScope.$apply();
        var componentScope = $rootScope.camelCase;
        expect(componentScope.camelCase).toEqual('6');
      }));

      it('should throw an exception if required directive is missing', inject((Compiler $compile, Scope $rootScope, Injector injector) {
        expect(() {
          var element = $('<tab local><pane></pane><pane local></pane></tab>');
          $compile(element)(injector, element);
        }, throwsA(contains('No provider found for LocalAttrDirective! (resolving LocalAttrDirective)')));
      }));

      it('should publish component controller into the scope', async(inject((Scope $rootScope) {
        var element = $(r'<div><publish-me></publish-me></div>');
        $rootScope.$apply(() {
          $compile(element)(injector, element);
        });

        nextTurn();
        expect(element.textWithShadow()).toEqual('WORKED');
      })));

      it('should "publish" controller to injector under provided publishTypes', inject(() {
        var element = $(r'<div publish-types></div>');
        $compile(element)(injector, element);
        expect(PublishTypesAttrDirective._injector.get(PublishTypesAttrDirective)).
            toBe(PublishTypesAttrDirective._injector.get(PublishTypesDirectiveSuperType));
      }));

      it('should allow repeaters over controllers', inject((Logger logger) {
        var element = $(r'<log ng-repeat="i in [1, 2]"></log>');
        $compile(element)(injector, element);
        $rootScope.$apply();
        expect(logger.length).toEqual(2);
      }));

      iit('should pass functions through attributes', inject((Scope scope) {
        var count = 0;
        scope['inc'] = () { count++; return "boo"; };
        var element = $('<function-runner func=inc></function-runner>');

        expect(count).toEqual(0);
        $compile(element)(injector, element);
        $rootScope.$apply();
        expect(count).toEqual(1);
      }));
    });

    describe('controller scoping', () {

      it('shoud make controllers available to sibling and child controllers', inject((Compiler $compile, Scope $rootScope, Log log, Injector injector) {
        var element = $('<tab local><pane local></pane><pane local></pane></tab>');
        $compile(element)(injector, element);
        expect(log.result()).toEqual('TabComponent-0; LocalAttrDirective-0; PaneComponent-1; LocalAttrDirective-0; PaneComponent-2; LocalAttrDirective-0');
      }));

      it('should reuse controllers for transclusions', inject((Compiler $compile, Scope $rootScope, Log log, Injector injector) {
        var element = $('<div simple-transclude-in-attach include-transclude>block</div>');
        $compile(element)(injector, element);
        $rootScope.$apply();
        expect(log.result()).toEqual('IncludeTransclude; SimpleTransclude');
      }));

    });
  });
}

@NgComponent(
    template: r'{{name}}{{sep}}{{$id}}(<content>SHADOW-CONTENT</content>)'
)
class SimpleComponent {
  SimpleComponent(Scope scope) {
    scope.name = 'INNER';
  }
}

@NgComponent(
    template: r'<content></content>',
    map: const {
      'attr': '@',
      'expr': '=',
      'ondone': '&',
    }
)
class IoComponent {
  Scope scope;
  IoComponent(Scope scope) {
    this.scope = scope;
    scope.$root.ioComponent = this;
  }
}

@NgComponent(
    map: const {
      'camelCase': '@',
    }
)
class CamelCaseMapComponent {
  CamelCaseMapComponent(Scope scope) {
    scope.$root.camelCase = scope;
  }
}

@NgComponent(
    template: '<div>inside {{fromParent()}}</div>',
    map: const {
      'fromParent': '&',
    }
)
class ParentExpressionComponent {
}

@NgComponent(
    template: r'<content>{{ctrlName.value}}</content>',
    publishAs: 'ctrlName'
)
class PublishMeComponent {
  String value = 'WORKED';
}


@NgComponent(
    template: r'<content></content>',
    publishAs: 'ctrlName'
)
class LogComponent {
  LogComponent(Scope scope, Logger logger) {
    logger.add(scope);
  }
}

@NgComponent(
    map: const {
      'func': '&'
    }
)
class FunctionRunnerComponent {
  FunctionRunnerComponent(Scope scope) {
    scope['func']()();
  }
}
