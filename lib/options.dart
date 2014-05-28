library angular.options;

import 'package:angular/core/annotation.dart';

// Used in the element binder
var NO_WATCH = true;

@Component(
   selector: 'ng-internal-options',
   template:
      '<div>'
      '  Angular internal options'
      '  [<input type=checkbox ng-model="ctrl.noWatch"> Handrolled watchers]'
      '</div>',
   publishAs: 'ctrl'
)
class NgInternalOptions {
  get noWatch => NO_WATCH;
  set noWatch(v) { NO_WATCH = v; }
}
