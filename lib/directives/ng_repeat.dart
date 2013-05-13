part of angular;

class NgRepeatDirective  {
  List<dom.Node> nodeList;
  String itemExpr, listExpr;
  BlockList cursor;
  Compiler compile;
  Function linker;
  BlockListFactory blf;

  NgRepeatDirective(BlockListFactory this.blf, Compiler this.compile, List<dom.Node> this.nodeList, DirectiveValue value) {
    var splits = value.value.split('in');
    assert(splits.length == 2); // or not?
    itemExpr = splits[0];
    listExpr = splits[1];

    // should be in the compiler's transclude functions.
    es(String html) {
      var div = new dom.DivElement();
      div.innerHtml = html;
      return div.nodes;
    }

    var cursorElt = es('<!-- ngRepeat -->');
    cursor = blf([cursorElt[0]], {});

    var clone = this.nodeList[0].clone(true);
    linker = (scope, cloneFn) {
      var oneClone = clone.clone(true);
      cloneFn(compile([oneClone])([oneClone])..attach(scope));
    };

    this.nodeList[0].replaceWith(cursor.elements[0]);
  }

  attach(Scope scope) {
    // should be watchprops
    scope.$watch(listExpr, (List value) {
      // for each value, create a child scope and call the compiler's linker
      // function.
      value.forEach((oneValue) {

        scope[itemExpr] = oneValue;
        linker(scope, (clone) {
          clone.insertAfter(cursor);
        });
      });

    });
  }
}
