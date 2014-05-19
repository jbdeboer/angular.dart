library angular.dom.platform_spec;

import '../_specs.dart';

import 'dart:js' as js;

main() {
  ddescribe('Platform', () {

    beforeEachModule((Module module) {
      module
        ..bind(SimpleComponent)
        ..bind(WebPlatform, toValue: new WebPlatform());
    });

    it('Should be able to find "Platform" on the current test page', () {
      expect(js.context['Platform']).toBeNotNull();
    });

    it('Should not be able to find "ShadowCss" on the current test page', () {
      expect(js.context['Platform']['shadowCss']).toBeNull();
    });

    it('should get the real platform through the injector for platform tests.',
      inject((WebPlatform platform) {
        expect(platform != null);
        expect(platform.shadowDomShimRequired).toBeFalsy();
        expect(platform.cssShimRequired).toBeFalsy();
    }));

    it('Should apply background color across browsers.',
      async((TestBed _, MockHttpBackend backend, WebPlatform platform) {

//      backend
//        ..expectGET('style.css').respond(200, 'span{ background-color: red; }');

      Element element = e('<span><simple-component '
          'color="red">ignore</simple-component></span>');

      _.compile(element);

      microLeap();
      backend.flush();
      microLeap();

      try {
        document.body.append(element);
        microLeap();
  //
  //      CssStyleDeclaration css = element.getComputedStyle();
  //      throw css.backgroundColor
  //      print(element.getComputedStyle().backgroundColor);

        expect(element.getComputedStyle().backgroundColor).not.toBe("red");


        throw element.children[0].shadowRoot.nodes;

        expect(element.children[0].shadowRoot.querySelector("span")
        .getComputedStyle().backgroundColor).toBe("red");

      } finally {
        element.remove();
      }
    }));
  });
}

@Component(
    selector: "simple-component",
    publishAs: "ctrl",
    template: """
      <div class="custom-component" ng-class="ctrl.color">
        <span>Shadow [</span>
        <content></content>
        <span>]</span>
        <a href="#" ng-click="ctrl.on=!ctrl.on">[Toggle]</a>
        <span ng-if="ctrl.on">off</span>
        <span ng-if="!ctrl.on">on</span>
      </div>
    """,
    cssUrl: "style.css")
class SimpleComponent {
  @NgAttr('color')
  String color;

  bool on = false;
}
