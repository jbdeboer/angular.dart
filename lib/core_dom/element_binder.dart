part of angular.core.dom;

/**
 * ElementBinder is created by the Selector and is responsible for instantiating individual directives
 * and binding element properties.
 */

class ElementBinder {
  List<DirectiveRef> directives = [];

  /**
   * As we are iterating through the directives, we may record the position.
   * TODO: Make this member private.
   */
  bool skipTemplate = false;

  DirectiveRef templateDirective;

//  ElementBinder() {
//  };
}
