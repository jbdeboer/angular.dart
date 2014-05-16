library angular.dom.platform_spec;

import '../_specs.dart';

main() {
  describe('Platform', () {

    beforeEachModule((Module module) {
      module
        ..bind(SimpleComponent);
    });

    it('Should apply background color across browsers.',
      async((TestBed _, MockHttpBackend backend) {

      backend
        ..expectGET('style.css').respond(200, 'span{ background-color: red; }');

      var element = e('<span><simple-component '
          'color="red">ignore</simple-component></span>');

      _.compile(element);

      microLeap();
      backend.flush();
      microLeap();

      expect(element.getComputedStyle().backgroundColor()).toBe("red");

      expect(element.children[0].shadowRoot.querySelector("span")
      .getComputedStyle().backgroundColor()).toBe("red");
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
