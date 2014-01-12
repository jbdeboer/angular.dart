library todo;

import 'package:angular/angular.dart';

class Item {
  String text;
  bool done;

  Item([String this.text = '', bool this.done = false]);

  bool get isEmpty => text.isEmpty;
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

  TodoController(ServerController serverController) {
    newItem = new Item();
    items = [
      new Item('Write Angular in Dart', true),
      new Item('Build powerful web apps'),
      new Item('Push the web forward')
    ];

    serverController.init(this);
  }

  add() {
    if (newItem.isEmpty) return;

    items.add(newItem);
    newItem = new Item();
  }

  markAllDone() {
    items.forEach((item) => item.done = true);
  }

  archiveDone() {
    items.removeWhere((item) => item.done);
  }

  String classFor(Item item) {
    return item.done ? 'done' : '';
  }

  int remaining() {
    return items.where((item) => !item.done).length;
  }
}
