library angular.directive.ng_style;

import "dart:html" as dom;
import "../dom/directive.dart";
import "../utils.dart";

/**
  * The `ngStyle` directive allows you to set CSS style on an HTML element conditionally.
  *
  * @example
        <span ng-style="{color:'red'}">Sample Text</span>
  */
@NgDirective(
    selector: '[ng-style]',
    map: const { 'ng-style': '=.style'})
class NgStyleAttrDirective {
  dom.Element _element;
  NgStyleAttrDirective(dom.Element this._element) { print('ng-style created'); }

  var lastStyles;

/**
  * ng-style attribute takes an expression hich evals to an
  *      object whose keys are CSS style names and values are corresponding values for those CSS
  *      keys.
*/
  set style(Map newStyles) {
    print('style called');
    dom.CssStyleDeclaration css = _element.style;
    if (lastStyles != null) {
      lastStyles.forEach((val, style) { css.setProperty(val, ''); });
    }
    lastStyles = newStyles;
    newStyles.forEach((val, style) { print('val $val style $style'); css.setProperty(val, style); });
  }
}

