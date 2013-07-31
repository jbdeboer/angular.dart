import '_specs.dart';

// Used to test getter / setter logic.
class TestData {
  String _str = "testString";
  get str => _str;
  set str(x) => _str = x;

  method() => "testMethod";
}

class Ident {
  id(x) => x;
  doubleId(x,y) => [x,y];
}

class Mixin {}
class MixedTestData extends TestData with Mixin {
}

class MapData {
  operator[](x) => "mapped-$x";
  containsKey(x) => true;
}
class MixedMapData extends MapData with Mixin { }
class InheritedMapData extends MapData { }

class BadContainsKeys {
  containsKey(x) => null;
  String str = "member";
}

class LexerExpect extends Expect {
  LexerExpect(actual) : super(actual);
  toBeToken(int index, String text) {
    expect(actual is Token).toEqual(true);
    expect(actual.index).toEqual(index);
    expect(actual.text).toEqual(text);
  }
}
expect(actual) => new LexerExpect(actual);

main() {
  var lex = Parser.lex;
  describe('lexer', () {
    // New test case
    it('should tokenize a simple identifier', () {
      var tokens = Parser.lex("j");
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeToken(0, 'j');
    });

    // New test case
    it('should tokenize a dotted identifier', () {
      var tokens = Parser.lex("j.k");
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeToken(0, 'j.k');
    });

    it('should tokenize an operator', () {
      var tokens = Parser.lex('j-k');
      expect(tokens.length).toEqual(3);
      expect(tokens[1]).toBeToken(1, '-');
    });

    it('should tokenize an indexed operator', () {
      var tokens = Parser.lex('j[k]');
      expect(tokens.length).toEqual(4);
      expect(tokens[1]).toBeToken(1, '[');
    });

    it('should tokenize numbers', () {
      var tokens = Parser.lex('88');
      expect(tokens.length).toEqual(1);
      expect(tokens[0]).toBeToken(0, '88');
    });

    it('should tokenize numbers within index ops', () {
      expect(Parser.lex('a[22]')[2]).toBeToken(2, '22');
    });

    it('should tokenize simple quoted strings', () {
      expect(Parser.lex('"a"')[0]).toBeToken(0, '"a"');
    });

    it('should tokenize quoted strings with escaped quotes', () {
      expect(Parser.lex('"a\\""')[0]).toBeToken(0, '"a\\""');
    });

    it('should tokenize a string', () {
      var tokens = Parser.lex("j-a.bc[22]+1.3|f:'a\\\'c':\"d\\\"e\"");
      var i = 0;
      expect(tokens[i]).toBeToken(0, 'j');

      i++;
      expect(tokens[i]).toBeToken(1, '-');

      i++;
      expect(tokens[i]).toBeToken(2, 'a.bc');

      i++;
      expect(tokens[i]).toBeToken(6, '[');

      i++;
      expect(tokens[i]).toBeToken(7, '22');

      i++;
      expect(tokens[i]).toBeToken(9, ']');

      i++;
      expect(tokens[i]).toBeToken(10, '+');

      i++;
      expect(tokens[i]).toBeToken(11, '1.3');

      i++;
      expect(tokens[i]).toBeToken(14, '|');

      i++;
      expect(tokens[i]).toBeToken(15, 'f');

      i++;
      expect(tokens[i]).toBeToken(16, ':');

      i++;
      expect(tokens[i]).toBeToken(17, '\'a\\\'c\'');

      i++;
      expect(tokens[i]).toBeToken(23, ':');

      i++;
      expect(tokens[i]).toBeToken(24, '"d\\"e"');
    });

    it('should tokenize undefined', () {
      var tokens = Parser.lex("undefined");
      var i = 0;
      expect(tokens[i]).toBeToken(0, 'undefined');
      expect(tokens[i].fn(null, null, null, null)).toEqual(null);
    });

    it('should ignore whitespace', () {
      var tokens = lex("a \t \n \r b");
      expect(tokens[0].text).toEqual('a');
      expect(tokens[1].text).toEqual('b');
    });

    it('should tokenize quoted string', () {
      var str = "['\\'', \"\\\"\"]";
      var tokens = lex(str);

      expect(tokens[1].index).toEqual(1);
      expect(tokens[1].string).toEqual("'");

      expect(tokens[3].index).toEqual(7);
      expect(tokens[3].string).toEqual('"');
    });

    it('should tokenize escaped quoted string', () {
      var str = '"\\"\\n\\f\\r\\t\\v\\u00A0"';
      var tokens = lex(str);

      expect(tokens[0].fn0()).toEqual('"\n\f\r\t\v\u00A0');
    });

    it('should tokenize unicode', () {
      var tokens = lex('"\\u00A0"');
      expect(tokens.length).toEqual(1);
      expect(tokens[0].fn0()).toEqual('\u00a0');
    });

    it('should tokenize relation', () {
      var tokens = lex("! == != < > <= >=");
      expect(tokens[0].text).toEqual('!');
      expect(tokens[1].text).toEqual('==');
      expect(tokens[2].text).toEqual('!=');
      expect(tokens[3].text).toEqual('<');
      expect(tokens[4].text).toEqual('>');
      expect(tokens[5].text).toEqual('<=');
      expect(tokens[6].text).toEqual('>=');
    });

    it('should tokenize statements', () {
      var tokens = lex("a;b;");
      expect(tokens[0].text).toEqual('a');
      expect(tokens[1].text).toEqual(';');
      expect(tokens[2].text).toEqual('b');
      expect(tokens[3].text).toEqual(';');
    });

    it('should tokenize function invocation', () {
      var tokens = lex("a()");
      expect(tokens[0]).toBeToken(0, 'a');
      expect(tokens[1]).toBeToken(1, '(');
      expect(tokens[2]).toBeToken(2, ')');
    });

    it('should tokenize simple method invocations', () {
      var tokens = lex("a.method()");
      expect(tokens[2]).toBeToken(2, 'method');
    });

    it('should tokenize method invocation', () {
      var tokens = lex("a.b.c (d) - e.f()");
      expect(tokens[0]).toBeToken(0, 'a.b');
      expect(tokens[1]).toBeToken(3, '.');
      expect(tokens[2]).toBeToken(4, 'c');
      expect(tokens[3]).toBeToken(6, '(');
      expect(tokens[4]).toBeToken(7, 'd');
      expect(tokens[5]).toBeToken(8, ')');
      expect(tokens[6]).toBeToken(10, '-');
      expect(tokens[7]).toBeToken(12, 'e');
      expect(tokens[8]).toBeToken(13, '.');
      expect(tokens[9]).toBeToken(14, 'f');
      expect(tokens[10]).toBeToken(15, '(');
      expect(tokens[11]).toBeToken(16, ')');
    });

    it('should tokenize number', () {
      var tokens = lex("0.5");
      expect(tokens[0].fn0()).toEqual(0.5);
    });

    // NOTE(deboer): NOT A LEXER TEST
//    it('should tokenize negative number', () {
//      var tokens = lex("-0.5");
//      expect(tokens[0].fn0()).toEqual(-0.5);
//    });

    it('should tokenize number with exponent', () {
      var tokens = lex("0.5E-10");
      expect(tokens.length).toEqual(1);
      expect(tokens[0].fn0()).toEqual(0.5E-10);
      tokens = lex("0.5E+10");
      expect(tokens[0].fn0()).toEqual(0.5E+10);
    });

    it('should throws exception for invalid exponent', () {
      expect(() {
        lex("0.5E-");
      }).toThrow('Lexer Error: Invalid exponent at column 4 in expression [0.5E-].');

      expect(() {
        lex("0.5E-A");
      }).toThrow('Lexer Error: Invalid exponent at column 4 in expression [0.5E-A].');
    });

    it('should tokenize number starting with a dot', () {
      var tokens = lex(".5");
      expect(tokens[0].fn0()).toEqual(0.5);
    });

    it('should throw error on invalid unicode', () {
      expect(() {
        lex("'\\u1''bla'");
      }).toThrow("Lexer Error: Invalid unicode escape [\\u1''b] at column 2 in expression ['\\u1''bla'].");
    });
  });

  describe('parse', () {
    var scope;
    eval(String text) => Parser.parse(text)(scope, null);

    beforeEach(() { scope = {}; });

    it('should parse numerical expressions', () {
      expect(eval("1")).toEqual(1);
    });

    it('should parse unary - expressions', () {
      expect(eval("-1")).toEqual(-1);
      expect(eval("+1")).toEqual(1);
    });

    it('should parse unary ! expressions', () {
      expect(eval("!true")).toEqual(!true);
    });

    it('should parse multiplicative expressions', () {
      expect(eval("3*4/2%5")).toEqual(3*4/2%5);
    });

    it('should parse additive expressions', () {
      expect(eval("3+6-2")).toEqual(3+6-2);
    });

    it('should parse relational expressions', () {
      expect(eval("2<3")).toEqual(2<3);
      expect(eval("2>3")).toEqual(2>3);
      expect(eval("2<=2")).toEqual(2<=2);
      expect(eval("2>=2")).toEqual(2>=2);
    });

    it('should parse equality expressions', () {
      expect(eval("2==3")).toEqual(2==3);
      expect(eval("2!=3")).toEqual(2!=3);
    });

    it('should parse logicalAND expressions', () {
      expect(eval("true&&true")).toEqual(true&&true);
      expect(eval("true&&false")).toEqual(true&&false);
    });

    it('should parse logicalOR expressions', () {
      expect(eval("true||true")).toEqual(true||true);
      expect(eval("true||false")).toEqual(true||false);
      expect(eval("false||false")).toEqual(false||false);
    });

    it('should auto convert ints to strings', () {
      expect(eval("'str ' + 4")).toEqual("str 4");
      expect(eval("4 + ' str'")).toEqual("4 str");
      expect(eval("4 + 4")).toEqual(8);
      expect(eval("4 + 4 + ' str'")).toEqual("8 str");
      expect(eval("'str ' + 4 + 4")).toEqual("str 44");
    });

    expectEval(String expr) => expect(() => eval(expr));

    // PARSER ERRORS

    it('should throw a reasonable error for unconsumed tokens', () {
      expectEval(")").toThrow('Parser Error: Unconsumed token ) at column 1 in [)]');
    });

    it('should throw a "not implemented" error for filters', () {
      expectEval("4|a").toThrow(
          'Parser Error: Filters are not implemented at column 2 in [4|a]');
    });

    it('should throw on missing expected token', () {
      expectEval("a(b").toThrow('Parser Error: Missing expected ) the end of the expression [a(b]');
    });

    it('should throw on bad assignment', () {
      expectEval("5=4").toThrow('Parser Error: Expression 5 is not assignable at column 2 in [5=4]');
      expectEval("array[5=4]").toThrow('Parser Error: Expression 5 is not assignable at column 8 in [array[5=4]]');
    });

    // EVAL ERRORS

    it('should throw on null object field access', () {
      expectEval("null[3]").toThrow(
          "Eval Error: Accessing null object while evaling [null[3]]");
    });

    it('should throw on non-list, non-map field access', () {
      expectEval("6[3]").toThrow('Eval Error: Attempted field access on a non-list, non-map while evaling [6[3]]');
      expectEval("6[3]=2").toThrow('Eval Error: Attempting to set a field on a non-list, non-map while evaling [6[3]=2');
    });



    it('should throw on undefined functions', () {
      expectEval("notAFn()").toThrow('Eval Error: Undefined function notAFn while evaling [notAFn()]');
    });

    it('should throw on not-function function calls', () {
      expectEval("4()").toThrow('Eval Error: 4 is not a function while evaling [4()]');
    });



    //// ==== IMPORTED ITs

    it('should parse expressions', () {
      expect(eval("-1")).toEqual(-1);
      expect(eval("1 + 2.5")).toEqual(3.5);
      expect(eval("1 + -2.5")).toEqual(-1.5);
      expect(eval("1+2*3/4")).toEqual(1+2*3/4);
      expect(eval("0--1+1.5")).toEqual(0- -1 + 1.5);
      expect(eval("-0--1++2*-3/-4")).toEqual(-0- -1+ 2*-3/-4);
      expect(eval("1/2*3")).toEqual(1/2*3);
    });

    it('should parse comparison', () {
      expect(eval("false")).toBeFalsy();
      expect(eval("!true")).toBeFalsy();
      expect(eval("1==1")).toBeTruthy();
      expect(eval("1!=2")).toBeTruthy();
      expect(eval("1<2")).toBeTruthy();
      expect(eval("1<=1")).toBeTruthy();
      expect(eval("1>2")).toEqual(1>2);
      expect(eval("2>=1")).toEqual(2>=1);
      expect(eval("true==2<3")).toEqual(true == 2<3);
    });

    it('should parse logical', () {
      expect(eval("0&&2")).toEqual((0!=0)&&(2!=0));
      expect(eval("0||2")).toEqual(0!=0||2!=0);
      expect(eval("0||1&&2")).toEqual(0!=0||1!=0&&2!=0);
    });

    it('should parse string', () {
      expect(eval("'a' + 'b c'")).toEqual("ab c");
    });

    // TODO filters

    it('should access scope', () {
      scope['a'] =  123;
      scope['b'] = {'c': 456};
      expect(eval("a")).toEqual(123);
      expect(eval("b.c")).toEqual(456);
      expect(eval("x.y.z")).toEqual(null);
    });

    it('should access classes on scope', () {
      scope['ident'] = new Ident();
      expect(eval('ident.id(6)')).toEqual(6);
      expect(eval('ident.doubleId(4,5)')).toEqual([4, 5]);
    });

    it('should resolve deeply nested paths (important for CSP mode)', () {
      scope['a'] = {'b': {'c': {'d': {'e': {'f': {'g': {'h': {'i': {'j': {'k': {'l': {'m': {'n': 'nooo!'}}}}}}}}}}}}};
      expect(eval("a.b.c.d.e.f.g.h.i.j.k.l.m.n")).toBe('nooo!');
    });

    it('should be forgiving', () {
      scope = {'a': {'b': 23}};
      expect(eval('b')).toBeNull();
      expect(eval('a.x')).toBeNull();
      expect(eval('a.b.c.d')).toBeNull();
    });

    it('should evaluate grouped expressions', () {
      expect(eval("(1+2)*3")).toEqual((1+2)*3);
    });

    it('should evaluate assignments', () {
      scope = {'g': 4, 'arr': [3,4]};

      expect(eval("a=12")).toEqual(12);
      expect(scope["a"]).toEqual(12);

      expect(eval("arr[c=1]")).toEqual(4);
      expect(scope["c"]).toEqual(1);

      expect(eval("x.y.z=123;")).toEqual(123);
      expect(scope["x"]["y"]["z"]).toEqual(123);

      expect(eval("a=123; b=234")).toEqual(234);
      expect(scope["a"]).toEqual(123);
      expect(scope["b"]).toEqual(234);
    });

    it('should evaluate function call without arguments', () {
      scope['const'] = () => 123;
      expect(eval("const()")).toEqual(123);
    });

    it('should evaluate function call with arguments', () {
      scope["add"] =  (a,b) {
        return a+b;
      };
      expect(eval("add(1,2)")).toEqual(3);
    });

    it('should evaluate function call from a return value', () {
      scope["val"] = 33;
      scope["getter"] = () { return () { return scope["val"]; };};
      expect(eval("getter()()")).toBe(33);
    });

    it('should evaluate multiplication and division', () {
      scope["taxRate"] =  8;
      scope["subTotal"] =  100;
      expect(eval("taxRate / 100 * subTotal")).toEqual(8);
      expect(eval("subTotal * taxRate / 100")).toEqual(8);
    });

    it('should evaluate array', () {
      expect(eval("[]").length).toEqual(0);
      expect(eval("[1, 2]").length).toEqual(2);
      expect(eval("[1, 2]")[0]).toEqual(1);
      expect(eval("[1, 2]")[1]).toEqual(2);
    });

    it('should evaluate array access', () {
      expect(eval("[1][0]")).toEqual(1);
      expect(eval("[[1]][0][0]")).toEqual(1);
      expect(eval("[].length")).toEqual(0);
      expect(eval("[1, 2].length")).toEqual(2);
    });

    it('should evaluate object', () {
      expect(eval("{}")).toEqual({});
      expect(eval("{a:'b'}")).toEqual({"a":"b"});
      expect(eval("{'a':'b'}")).toEqual({"a":"b"});
      expect(eval("{\"a\":'b'}")).toEqual({"a":"b"});
    });

    it('should evaluate object access', () {
      expect(eval("{false:'WC', true:'CC'}[false]")).toEqual("WC");
    });

    it('should evaluate JSON', () {
      expect(eval("[{}]")).toEqual([{}]);
      expect(eval("[{a:[]}, {b:1}]")).toEqual([{"a":[]},{"b":1}]);
    });

    it('should evaluate multiple statements', () {
      expect(eval("a=1;b=3;a+b")).toEqual(4);
      expect(eval(";;1;;")).toEqual(1);
    });

    // skipping should evaluate object methods in correct context (this)
    // skipping should evaluate methods in correct context (this) in argument

    it('should evaluate objects on scope context', () {
      scope["a"] =  "abc";
      expect(eval("{a:a}")["a"]).toEqual("abc");
    });

    it('should evalulate objects on Scope', inject((Scope scope) {
      scope.a = "abc";
      var result = Parser.parse("a")(scope, null);
      expect(result).toEqual("abc");
    }));

    it('should evaluate field access on function call result', () {
      scope["a"] =  () {
        return {'name':'misko'};
      };
      expect(eval("a().name")).toEqual("misko");
    });

    it('should evaluate field access after array access', () {
      scope["items"] =  [{}, {'name':'misko'}];
      expect(eval('items[1].name')).toEqual("misko");
    });

    it('should evaluate array assignment', () {
      scope["items"] =  [];

      expect(eval('items[1] = "abc"')).toEqual("abc");
      expect(eval('items[1]')).toEqual("abc");
      //    Dont know how to make this work....
      //    expect(eval('books[1] = "moby"')).toEqual("moby");
      //    expect(eval('books[1]')).toEqual("moby");
    });

    it('should evaluate remainder', () {
      expect(eval('1%2')).toEqual(1);
    });

    it('should evaluate sum with undefined', () {
      expect(eval('1+undefined')).toEqual(1);
      expect(eval('undefined+1')).toEqual(1);
    });
    it('should throw exception on non-closed bracket', () {
      expect(() {
        eval('[].count(');
      }).toThrow('Unexpected end of expression: [].count(');
    });

    it('should evaluate double negation', () {
      expect(eval('true')).toBeTruthy();
      expect(eval('!true')).toBeFalsy();
      expect(eval('!!true')).toBeTruthy();
      expect(eval('{true:"a", false:"b"}[!!true]')).toEqual('a');
    });

    it('should evaluate negation', () {
      expect(eval("!false || true")).toEqual(!false || true);
      expect(eval("!(11 == 10)")).toEqual(!(11 == 10));
      expect(eval("12/6/2")).toEqual(12/6/2);
    });

    it('should evaluate exclamation mark', () {
      expect(eval('suffix = "!"')).toEqual('!');
    });

    it('should evaluate minus', () {
      expect(eval("{a:'-'}")).toEqual({'a': "-"});
    });

    it('should evaluate undefined', () {
      expect(eval("undefined")).toBeNull();
      expect(eval("a=undefined")).toBeNull();
      expect(scope["a"]).toBeNull();
    });

    it('should allow assignment after array dereference', () {
      scope["obj"] = [{}];
      eval('obj[0].name=1');
      // can not be expressed in Dart expect(scope["obj"]["name"]).toBeNull();
      expect(scope["obj"][0]["name"]).toEqual(1);
    });

    it('should short-circuit AND operator', () {
      scope["run"] = () {
        throw "IT SHOULD NOT HAVE RUN";
      };
      expect(eval('false && run()')).toBe(false);
    });

    it('should short-circuit OR operator', () {
      scope["run"] = () {
        throw "IT SHOULD NOT HAVE RUN";
      };
      expect(eval('true || run()')).toBe(true);
    });

    it('should support method calls on primitive types', () {
      scope["empty"] = '';
      scope["zero"] = 0;
      scope["bool"] = false;

      expect(eval('empty.substring(0)')).toEqual('');
      expect(eval('zero.toString()')).toEqual('0');
      // DOES NOT WORK.  bool.toString is not reflected
      // expect(eval('bool.toString()')).toEqual('false');
    });

    it('should support map getters', () {
      expect(Parser.parse('a')({'a': 4})).toEqual(4);
    });

    it('should support member getters', () {
      expect(Parser.parse('str')(new TestData())).toEqual('testString');
    });

    it('should support returning member functions', () {
      expect(Parser.parse('method')(new TestData())()).toEqual('testMethod');
    });

    it('should support calling member functions', () {
      expect(Parser.parse('method()')(new TestData())).toEqual('testMethod');
    });

    it('should support array setters', () {
      var data = {'a': [1,3]};
      expect(Parser.parse('a[1]=2')(data)).toEqual(2);
      expect(data['a'][1]).toEqual(2);
    });

    it('should support member field setters', () {
      TestData data = new TestData();
      expect(Parser.parse('str="bob"')(data)).toEqual('bob');
      expect(data.str).toEqual("bob");
    });

    it('should support member field getters from mixins', () {
      MixedTestData data = new MixedTestData();
      data.str = 'dole';
      expect(Parser.parse('str')(data)).toEqual('dole');
    });

    it('should support map getters from superclass', () {
     InheritedMapData mapData = new InheritedMapData();
     expect(Parser.parse('notmixed')(mapData)).toEqual('mapped-notmixed');
    });

    it('should support map getters from mixins', () {
    MixedMapData data = new MixedMapData();
    expect(Parser.parse('str')(data)).toEqual('mapped-str');
    });

    it('should gracefully handle bad containsKey', () {
     expect(Parser.parse('str')(new BadContainsKeys())).toEqual('member');
    });

    it('should parse functions for object indices', () {
      expect(Parser.parse('a[x()]()')({'a': [()=>6], 'x': () => 0})).toEqual(6);
    });

    it('should fail gracefully when missing a function', () {
      expect(() {
        Parser.parse('doesNotExist()')({});
      }).toThrow('Undefined function doesNotExist');

      expect(() {
        Parser.parse('exists(doesNotExist())')({'exists': () => true});
      }).toThrow('Undefined function doesNotExist');

      expect(() {
        Parser.parse('doesNotExists(exists())')({'exists': () => true});
      }).toThrow('Undefined function doesNotExist');

      expect(() {
        Parser.parse('a[0]()')({'a': [4]});
      }).toThrow('a[0] is not a function');

      expect(() {
        Parser.parse('a[x()]()')({'a': [4], 'x': () => 0});
      }).toThrow('a[x()] is not a function');

      expect(() {
        Parser.parse('{}()')({});
      }).toThrow('{} is not a function');
    });

    it('should let null be null', () {
      scope['map'] = {};

      expect(eval('null')).toBe(null);
      expect(eval('map.null')).toBe(null);
    });


    it('should behave gracefully with a null scope', () {
      expect(Parser.parse('null')(null)).toBe(null);
    });


    it('should pass exceptions through getters', () {
      expect(() {
        Parser.parse('boo')(new ScopeWithErrors());
      }).toThrow('boo to you');
    });


    it('should pass exceptions through methods', () {
      expect(() {
        Parser.parse('foo()')(new ScopeWithErrors());
      }).toThrow('foo to you');
    });
  });

  describe('assignable', () {
    it('should expose assignment function', () {
      var fn = Parser.parse('a');
      expect(fn.assign).toBeNotNull();
      var scope = {};
      fn.assign(scope, 123, null);
      expect(scope).toEqual({'a':123});
    });
  });

  describe('locals', () {
    it('should expose local variables', () {
      expect(Parser.parse('a')({'a': 6}, {'a': 1})).toEqual(1);
      expect(Parser.parse('add(a,b)')({'b': 1, 'add': (a, b) { return a + b; }}, {'a': 2})).toEqual(3);
    });

    it('should expose traverse locals', () {
      expect(Parser.parse('a.b')({'a': {'b': 6}}, {'a': {'b':1}})).toEqual(1);
      expect(Parser.parse('a.b')({'a': null}, {'a': {'b':1}})).toEqual(1);
      expect(Parser.parse('a.b')({'a': {'b': 5}}, {'a': null})).toEqual(null);
    });
  });
}

class ScopeWithErrors {
  String get boo { dump("got a boo"); throw "boo to you"; }
  String foo() { dump("got a foo"); throw "foo to you"; }
}
