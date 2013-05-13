import "../_specs.dart";

main() {
  var specInjector = new SpecInjector();
  var inject = specInjector.inject;

  beforeEach(() {
    specInjector.reset();
  });

  describe('NgRepeat', () {
    it('should repeat over array', inject((Compiler compiler, BlockListFactory blf) {
      var element = $('<ul><li></li></ul>');
      Element liElt = element[0].query('li');
      //expect(liElt.outerHtml).toEqual('<li></li>');

      var ngRepeat = new NgRepeatDirective(blf, compiler, [liElt], new DirectiveValue.fromString("item in items"));

      var scope = new Scope();
      scope.items = ["misko", "shyam"];
      ngRepeat.attach(scope);
      scope.$digest();
      expect(element[0].outerHtml).toEqual('<ul><!-- ngRepeat --><li></li><li></li></ul>');

    }));
  });
}
