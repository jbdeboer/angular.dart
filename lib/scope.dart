part of angular;

var _ttl = 10;
var initWatchVal = new Object();

class Watch {
  Function fn;
  dynamic last;
  Function get;
  String exp;

  Watch(this.fn, this.last, this.get, this.exp);
}

class Event {
  String name;
  Scope targetScope;
  Scope currentScope;
  bool propagationStopped = false;
  bool defaultPrevented = false;
  
  Event(this.name, this.targetScope);

  stopPropagation () => propagationStopped = true;
  preventDefault() => defaultPrevented = true;
}

class ScopeDigestTTL {
  num ttl;
  ScopeDigestTTL(num this.ttl);
}

class Scope {
  String $id;
  Scope $parent;

  ExceptionHandler _exceptionHandler;
  Parser _parser;
  num _ttl;
  String _phase;
  Map<String, Object> _properties = {};
  List<Function> _asyncQueue = [];
  List<Watch> _watchers = [];
  Map<String, Function> _listeners = {};
  Scope _nextSibling, _prevSibling, _childHead, _childTail;
  bool _isolate = false;


  Scope(ExceptionHandler this._exceptionHandler, Parser this._parser, ScopeDigestTTL ttl) {
    _properties[r'this']= this;
    _ttl = ttl.ttl;
    $root = this;
    $id = nextUid();
  }

  Scope._child(Scope this.$parent, bool this._isolate) {
    _exceptionHandler = $parent._exceptionHandler;
    _parser = $parent._parser;
    _ttl = $parent._ttl;
    _properties[r'this'] = this;
    $id = nextUid();
    if (_isolate) {
      $root = $parent.$root;
    }

    _prevSibling = $parent._childTail;
    if ($parent._childHead != null) {
      $parent._childTail._nextSibling = this;
      $parent._childTail = this;
    } else {
      $parent._childHead = $parent._childTail = this;
    }
  }

  operator []=(String name, value) => _properties[name] = value;
  operator [](String name) {
    if (_properties.containsKey(name)) {
      return _properties[name];
    } else if (!_isolate) {
      var $parent = _properties[r'$parent'];
      var $root = _properties[r'$root'];
      if ($parent != null && $parent != $root) {
        return $parent[name];
      }
    }
    return null;
  }

  noSuchMethod(Invocation invocation) {
    var name = MirrorSystem.getName(invocation.memberName);
    if (invocation.isGetter) {
      return this[name];
    } else if (invocation.isSetter) {
      var value = invocation.positionalArguments[0];
      name = name.substring(0, name.length - 1);
      this[name] = value;
      return value;
    } else {
      throw "Only getters/setters supported got '${name}(...). Check argument length?'.";
    }
  }



  $new([bool isolate = false]) {
    return new Scope._child(this, isolate);
  }


  $watch(watchExp, [Function listener]) {
    var scope = this;
    var get = _compileToFn(watchExp);
    var watcher = new Watch(listener, initWatchVal, get, watchExp.toString());

    // in the case user pass string, we need to compile it, do we really need this ?
    if (!(listener is Function)) {
      var listenFn = _compileToFn(listener);
      watcher.fn = (newVal, oldVal, scope) {listenFn(scope);};
    }

    // we use unshift since we use a while loop in $digest for speed.
    // the while loop reads in reverse order.
    _watchers.insert(0, watcher);

    return () {
      _watchers.remove(watcher);
    };
  }


  $digest() {
    var value, last,
        asyncQueue = _asyncQueue,
        length,
        dirty, _ttlLeft = _ttl,
        logIdx, logMsg;
    List<List<String>> watchLog = [];
    List<Watch> watchers;
    Watch watch;
    Scope next, current, target = this;

    _beginPhase('\$digest');

    do { // "while dirty" loop
      dirty = false;
      current = target;

      while(asyncQueue.length > 0) {
        try {
          current.$eval(asyncQueue.shift());
        } catch (e, s) {
          _exceptionHandler(e, s);
        }
      }

      do { // "traverse the scopes" loop
        if ((watchers = current._watchers) != null) {
          // process our watches
          length = watchers.length;
          while (length-- > 0) {
            try {
              watch = watchers[length];
              if ((value = watch.get(current)) != (last = watch.last) &&
                  !(value is num && last is num && value.isNaN && last.isNaN)) {
                dirty = true;
                watch.last = value;
                watch.fn(value, ((last == initWatchVal) ? value : last), current);
                if (_ttlLeft < 5) {
                  logIdx = 4 - _ttlLeft;
                  if (watchLog.length <= logIdx) {
                    watchLog.add([]);
                  }
                  logMsg = (watch.exp is Function)
                      ? 'fn: ' + (watch.exp.name || watch.exp.toString())
                      : watch.exp;
                  logMsg += '; newVal: ' + toJson(value) + '; oldVal: ' + toJson(last);
                  watchLog[logIdx].add(logMsg);
                }
              }
            } catch (e, s) {
              _exceptionHandler(e, s);
            }
          }
        }

        // Insanity Warning: scope depth-first traversal
        // yes, this code is a bit crazy, but it works and we have tests to prove it!
        // this piece should be kept in sync with the traversal in $broadcast
        if (current._childHead == null) {
          if (current == target) {
            next = null;
          } else {
            next = current._nextSibling;
            if (next == null) {
              while(current !== target && (next = current._nextSibling) == null) {
                current = current.$parent;
              }
            }
          }
        } else {
          next = current._childHead;
        }
      } while ((current = next) != null);

      if(dirty && (_ttlLeft--) == 0) {
        _clearPhase();
        throw '$_ttl \$digest() iterations reached. Aborting!\n' +
            'Watchers fired in the last 5 iterations: ${toJson(watchLog)}';
      }
    } while (dirty || asyncQueue.length > 0);

    _clearPhase();
  }


  $destroy() {
    if ($root == this) return; // we can't remove the root node;

    $broadcast(r'$destroy');

    if ($parent._childHead == this) $parent._childHead = _nextSibling;
    if ($parent._childTail == this) $parent._childTail = _prevSibling;
    if (_prevSibling != null) _prevSibling._nextSibling = _nextSibling;
    if (_nextSibling != null) _nextSibling._prevSibling = _prevSibling;
  }


  $eval(expr, [locals]) {
    return _compileToFn(expr)(this, locals);
  }


  $evalAsync(expr) {
    _asyncQueue.push(expr);
  }


  $apply(expr) {
    try {
      beginPhase('$apply');
      return $eval(expr);
    } catch (e) {
      _exceptionHandler(e);
    } finally {
      clearPhase();
      try {
        $rootScope.$digest();
      } catch (e) {
        _exceptionHandler(e);
        throw e;
      }
    }
  }


  $on(name, listener) {
    if (!_listeners.containsKey(name)) {
      _listeners[name] = namedListeners = [];
    }
    var namedListeners = _listeners[name];
    namedListeners.add(listener);

    return () {
      namedListeners.remove(listener);
    };
  }


  $emit(name, args) {
    var empty = [],
        namedListeners,
        scope = this,
        stopPropagation = false,
        event = new Event(name, this),
        listenerArgs = concat([event], arguments, 1),
        i, length;

    do {
      namedListeners = scope._listeners[name] || empty;
      event.currentScope = scope;
      i = 0;
      for (length = namedListeners.length; i<length; i++) {
        try {
          namedListeners[i].apply(null, listenerArgs);
          if (stopPropagation) return event;
        } catch (e) {
          _exceptionHandler(e);
        }
      }
      //traverse upwards
      scope = scope.$parent;
    } while (scope);

    return event;
  }


  $broadcast(String name, [List listenerArgs]) {
    var target = this,
        current = target,
        next = target,
        event = new Event(name, this);

    //down while you can, then up and next sibling or up and next sibling until back at root
    if (!?listenerArgs) {
      listenerArgs = [];
    }
    listenerArgs.insert(0, name);
    do {
      current = next;
      event.currentScope = current;
      if (current._listeners.containsKey(name)) {
        current._listeners[name].forEach((listener) {
          try {
            Function.apply(listener, listenerArgs);
          } catch(e, s) {
            _exceptionHandler(e, s);
          }
        });
      }

      // Insanity Warning: scope depth-first traversal
      // yes, this code is a bit crazy, but it works and we have tests to prove it!
      // this piece should be kept in sync with the traversal in $broadcast
      if (current._childHead == null) {
        if (current == target) {
          next = null;
        } else {
          next = current._nextSibling;
          if (next == null) {
            while(current !== target && (next = current._nextSibling) == null) {
              current = current.$parent;
            }
          }
        }
      } else {
        next = current._childHead;
      }
    } while ((current = next) != null);

    return event;
  }

  
  _beginPhase(phase) {
    if ($root._phase != null) {
      throw '${$root._phase} already in progress';
    }

    $root._phase = phase;
  }

  _clearPhase() {
    $root._phase = null;
  }

  Function _compileToFn(exp) {
    if (exp == null) {
      return (a) => null;
    } else if (exp is String) {
      return _parser(exp);
    } else if (exp is Function) {
      return exp;
    } else {
      throw 'Expecting String or Function';
    }
  }

}
