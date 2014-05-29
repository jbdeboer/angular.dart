library angular.options;

import 'package:angular/core/annotation.dart';

// Used in the element binder
var NO_WATCH = true;
var CUSTOM_INJECTOR = false;

@Component(
   selector: 'ng-internal-options',
   template:
      '<div>'
      '  Angular internal options'
      '  [<input type=checkbox ng-model="ctrl.noWatch"> Handrolled watchers]'
      '  [<input type=checkbox ng-model="ctrl.customInjector"> Custom injector]'
      '</div>',
   publishAs: 'ctrl'
)
class NgInternalOptions {
  get noWatch => NO_WATCH;
  set noWatch(v) { NO_WATCH = v; }

  get customInjector => CUSTOM_INJECTOR;
  set customInjector(v) { CUSTOM_INJECTOR = v;}
}
