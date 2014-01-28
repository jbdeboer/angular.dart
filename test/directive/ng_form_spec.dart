library form_spec;

import '../_specs.dart';

main() =>
describe('form', () {
  TestBed _;

  beforeEach(inject((TestBed tb) => _ = tb));

  it('should set the name of the form and attach it to the scope', inject((Scope scope) {
    var element = $('<form name="myForm"></form>');

    expect(scope['myForm']).toBeNull();

    _.compile(element);
    scope.$apply();

    expect(scope['myForm']).toBeDefined();

    var form = scope['myForm'];
    expect(form.name).toEqual('myForm');
  }));

  describe('pristine / dirty', () {
    it('should be set to pristine by default', inject((Scope scope) {
      var element = $('<form name="myForm"></form>');

      _.compile(element);
      scope.$apply();

      var form = scope['myForm'];
      expect(form.pristine).toEqual(true);
      expect(form.dirty).toEqual(false);
    }));

    it('should add and remove the correct CSS classes when set to dirty and to pristine', inject((Scope scope) {
      var element = $('<form name="myForm"></form>');

      _.compile(element);
      scope.$apply();

      var form = scope['myForm'];

      form.dirty = true;
      expect(form.pristine).toEqual(false);
      expect(form.dirty).toEqual(true);
      expect(element.hasClass('ng-pristine')).toBe(false);
      expect(element.hasClass('ng-dirty')).toBe(true);

      form.pristine = true;
      expect(form.pristine).toEqual(true);
      expect(form.dirty).toEqual(false);
      expect(element.hasClass('ng-pristine')).toBe(true);
      expect(element.hasClass('ng-dirty')).toBe(false);
    }));
  });

  describe('valid / invalid', () {
    it('should add and remove the correct flags when set to valid and to invalid', inject((Scope scope) {
      var element = $('<form name="myForm"></form>');

      _.compile(element);
      scope.$apply();

      var form = scope['myForm'];

      form.invalid = true;
      expect(form.valid).toEqual(false);
      expect(form.invalid).toEqual(true);
      expect(element.hasClass('ng-valid')).toBe(false);
      expect(element.hasClass('ng-invalid')).toBe(true);

      form.valid = true;
      expect(form.valid).toEqual(true);
      expect(form.invalid).toEqual(false);
      expect(element.hasClass('ng-invalid')).toBe(false);
      expect(element.hasClass('ng-valid')).toBe(true);
    }));
  });

  describe('controls', () {
    it('should add each contained ng-model as a control upon compile', inject((Scope scope) {
      var element = $('<form name="myForm">' + 
                      '  <input type="text" ng-model="mega_model" name="mega_name" />' +
                      '  <select ng-model="fire_model" name="fire_name">' +
                      '    <option>value</option>' + 
                      '  </select>' +
                      '</form>');

      _.compile(element);

      scope.mega_model = 'mega';
      scope.fire_model = 'fire';
      scope.$apply();

      var form = scope['myForm'];
      expect(form['mega_name'].modelValue).toBe('mega');
      expect(form['fire_name'].modelValue).toBe('fire');
    }));

    it('should properly remove controls directly from the ngForm instance', inject((Scope scope) {
      var element = $('<form name="myForm">' + 
                      '  <input type="text" ng-model="mega_model" name="mega_control" />' +
                      '</form>');

      _.compile(element);
      scope.$apply();

      var form = scope['myForm'];
      var control = form['mega_control'];
      form.removeControl(control);
      expect(form['mega_control']).toBeNull();
    }));

    it('should remove all controls when the scope is destroyed', inject((Scope scope) {
      var element = $('<form name="myForm">' + 
                      '  <input type="text" ng-model="one" name="one" />' +
                      '  <input type="text" ng-model="two" name="two" />' +
                      '  <input type="text" ng-model="three" name="three" />' +
                      '</form>');

      _.compile(element);
      scope.$apply();

      var form = scope['myForm'];
      expect(form['one']).toBeDefined();
      expect(form['two']).toBeDefined();
      expect(form['three']).toBeDefined();

      scope.$broadcast(r'$destroy');

      expect(form['one']).toBeNull();
      expect(form['two']).toBeNull();
      expect(form['three']).toBeNull();
    }));
  });

  describe('onSubmit', () {
    it('should suppress the submission event if no action is provided within the form', inject((Scope scope) {
      var element = $('<form name="myForm"></form>');

      _.compile(element);
      scope.$apply();

      Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

      expect(submissionEvent.defaultPrevented).toBe(false);
      element[0].dispatchEvent(submissionEvent);
      expect(submissionEvent.defaultPrevented).toBe(true);

      Event fakeEvent = new Event.eventType('CustomEvent', 'running');

      expect(fakeEvent.defaultPrevented).toBe(false);
      element[0].dispatchEvent(submissionEvent);
      expect(fakeEvent.defaultPrevented).toBe(false);
    }));

    it('should not prevent the submission event if an action is defined', inject((Scope scope) {
      var element = $('<form name="myForm" action="..."></form>');

      _.compile(element);
      scope.$apply();

      Event submissionEvent = new Event.eventType('CustomEvent', 'submit');

      expect(submissionEvent.defaultPrevented).toBe(false);
      element[0].dispatchEvent(submissionEvent);
      expect(submissionEvent.defaultPrevented).toBe(false);
    }));

    it('should execute the ng-submit expression if provided upon form submission', inject((Scope scope) {
      var element = $('<form name="myForm" ng-submit="submitted = true"></form>');

      _.compile(element);
      scope.$apply();

      _.rootScope.submitted = false;

      Event submissionEvent = new Event.eventType('CustomEvent', 'submit');
      element[0].dispatchEvent(submissionEvent);

      expect(_.rootScope.submitted).toBe(true);
    }));
  });
});
