library angular.dom.platform_spec;

import '../_specs.dart';

import 'dart:js' as js;

main() {
  describe('Platform', () {

    beforeEachModule((Module module) {
      module
        ..bind(WebPlatformTestComponent)
        ..bind(WebPlatform, toValue: new WebPlatform());
    });

    it('Should be able to find "Platform" on the current test page', () {
      expect(js.context['Platform']).toBeNotNull();
    });

    it('Should not be able to find "ShadowCss" on the current test page', () {
      expect(js.context['Platform']['ShadowCSS']).toBeNull();
    });

    it('should get the real platform through the injector for platform tests.',
      inject((WebPlatform platform) {

        expect(platform != null);
        print(platform);
        expect(platform.shadowDomShimRequired).toBeFalsy();
        expect(platform.cssShimRequired).toBeFalsy();
    }));

    iit('Should apply background color across browsers.',
      async((TestBed _, MockHttpBackend backend, WebPlatform platform) {

      backend
        ..expectGET('style.css').respond(200, 'span{ background-color: red; }');

      Element element = e('<span><test-wptc '
          'color="red">ignore</test-wptc></span>');

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


        //throw element.children[0].shadowRoot.nodes;

        expect(element.children[0].shadowRoot.querySelector("span")
        .getComputedStyle().backgroundColor).toEqual("rgb(255, 0, 0)");

      } finally {
        element.remove();
      }
    }));
  });
}

@Component(
    selector: "test-wptc",
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
class WebPlatformTestComponent {
  @NgAttr('color')
  String color;

  bool on = false;
}
