library todo;

import 'package:angular/angular.dart';
import 'package:js/js.dart' as js;

class Item {
  String text;
  bool done;

  Item([String this.text = '', bool this.done = false]);

  bool get isEmpty => text.isEmpty;

  clone() => new Item(text, done);

  clear() {
    text = '';
    done = false;
  }
}

// In 'server mode', this class fetches items from the server.
class ServerController {
  Http _http;

  ServerController(Http this._http);

  init(TodoController todo) {
    _http(method: 'GET', url: '/todos').then((HttpResponse data) {
      data.data.forEach((d) {
        todo.items.add(new Item(d["text"], d["done"]));
      });
    });
  }
}

// An implementation of ServerController that does nothing.
// Logic in main.dart determines which implementation we should
// use.
class NoServerController implements ServerController {
  init(TodoController todo) { }
}


@NgDirective(
  selector: '[todo-controller]',
  publishAs: 'todo'
)
class TodoController {
  List<Item> items;
  Item newItem;

  TodoController(ServerController serverController, NgZone zone, Scope scope) {
    newItem = new Item();
    items = [
      new Item('Write Angular in Dart', true),
      new Item('Write Dart in Angular'),
      new Item('Do something useful')
    ];

    serverController.init(this);

    var oldOnTurnDone = zone.onTurnDone;
    var run = 0;
    zone.onTurnDone = () {
      oldOnTurnDone();
      print("running scope again");
      js.context.console.log("a"); //__resetTrace(); //wtf.trace.reset();
      scope.$digest();
      js.context.console.log("b"); //__showTrace(); //wtf.trace.stop();
      //js.context.wtf.trace.snapshot('file://tmp/todo-$run');
      print("done running scope again");
    };


  }

  // workaround for https://github.com/angular/angular.dart/issues/37
  dynamic operator [](String key) {
    if (key == 'newItem') {
      return newItem;
    }
  }

  add() {
    if (newItem.isEmpty) return;

    items.add(newItem.clone());
    newItem.clear();
  }

  markAllDone() {
    items.forEach((item) => item.done = true);
  }

  archiveDone() {
    items.removeWhere((item) => item.done);
  }

  String classFor(Item item) {
    item.done ? 'done' : '';
  }

  int remaining() {
    return items.where((item) => !item.done).length;
  }
}
