import "package:unittest/unittest.dart" as unittest;
import "package:js/js.dart" as js;

import "test/_http.dart" as test_0;
import "test/_http_spec.dart" as test_1;
import "test/_log.dart" as test_2;
import "test/_specs.dart" as test_3;
import "test/_specs_spec.dart" as test_4;
import "test/_test_bed.dart" as test_5;
import "test/angular_spec.dart" as test_6;
import "test/block_spec.dart" as test_7;
import "test/cache_spec.dart" as test_8;
import "test/compiler_spec.dart" as test_9;
import "test/controller_spec.dart" as test_10;
import "test/directive_spec.dart" as test_11;
import "test/http_spec.dart" as test_12;
import "test/interface_typing_spec.dart" as test_13;
import "test/interpolate_spec.dart" as test_14;
import "test/jasmine_syntax.dart" as test_15;
import "test/mirrors_spec.dart" as test_16;
import "test/node_cursor_spec.dart" as test_17;
import "test/scope_spec.dart" as test_18;
import "test/selector_spec.dart" as test_19;
import "test/shadow_root_options_spec.dart" as test_20;
import "test/string_utilities_spec.dart" as test_21;
import "test/templateurl_spec.dart" as test_22;
import "test/zone_spec.dart" as test_23;
import "test/directives/ng_bind_spec.dart" as test_24;
import "test/directives/ng_class_spec.dart" as test_25;
import "test/directives/ng_click_spec.dart" as test_26;
import "test/directives/ng_cloak_spec.dart" as test_27;
import "test/directives/ng_controller_spec.dart" as test_28;
import "test/directives/ng_disabled_spec.dart" as test_29;
import "test/directives/ng_hide_spec.dart" as test_30;
import "test/directives/ng_if_spec.dart" as test_31;
import "test/directives/ng_include_spec.dart" as test_32;
import "test/directives/ng_model_spec.dart" as test_33;
import "test/directives/ng_mustache_spec.dart" as test_34;
import "test/directives/ng_repeat_spec.dart" as test_35;
import "test/directives/ng_show_spec.dart" as test_36;
import "test/tools/html_extractor_spec.dart" as test_37;
import "test/tools/selector_spec.dart" as test_38;
import "test/tools/source_metadata_extractor_spec.dart" as test_39;
import "test/parser/generated_parser_spec.dart" as test_40;
import "test/parser/lexer_spec.dart" as test_41;
import "test/parser/parser_spec.dart" as test_42;
import "test/parser/static_parser_spec.dart" as test_43;

class AdapterConfiguration extends unittest.SimpleConfiguration {
  bool get autoStart => false;

  void onDone(success) {
    try {
      super.onDone(success);
    } catch(e) {};
    js.scoped(() {
      js.context.__karma__.complete();
    });
  }

  void onTestStart(unittest.TestCase testCase) {
    super.onTestStart(testCase);
  }

  void onTestResult(unittest.TestCase testCase) {
    var suites = testCase.description.split(unittest.groupSep);
    var description = suites.removeLast();

    js.scoped(() {
      var logData = [];
      if (testCase.result != unittest.PASS) {
        logData.add(testCase.message);
        logData.add(testCase.stackTrace.toString());
      }
      js.context.__karma__.result(
        js.map({
          'id': testCase.id,
          'description': description,
          'success': testCase.result == unittest.PASS,
          'suite': suites,
          'skipped': !testCase.enabled,
          'log': js.array(logData),
          'time': testCase.runningTime.inMilliseconds
        })
      );
    });
  }

  void onLogMessage(unittest.TestCase testCase, String message) {
    js.scoped(() {
      js.context.__karma__.info(js.map({
        'dump': message
      }));
    });
  }

  void onSummary(int passed, int failed, int errors,
      List<unittest.TestCase> results, String uncaughtError) {
    if (uncaughtError != null) {
      js.scoped(() {
        js.context.__karma__.error(uncaughtError);
      });
    }
    // it's OK to print the default summary into the console
    super.onSummary(passed, failed, errors, results, uncaughtError);
  }
}

main() {
  // Change the groupSeparator, as the default " " is commonly used in spec
  // descriptions, which screws it up when we try to parse the original suites.
  unittest.groupSep = '#';
  unittest.unittestConfiguration = new AdapterConfiguration();

  test_0.main();
  test_1.main();
  test_2.main();
  test_3.main();
  test_4.main();
  test_5.main();
  test_6.main();
  test_7.main();
  test_8.main();
  test_9.main();
  test_10.main();
  test_11.main();
  test_12.main();
  test_13.main();
  test_14.main();
  test_15.main();
  test_16.main();
  test_17.main();
  test_18.main();
  test_19.main();
  test_20.main();
  test_21.main();
  test_22.main();
  test_23.main();
  test_24.main();
  test_25.main();
  test_26.main();
  test_27.main();
  test_28.main();
  test_29.main();
  test_30.main();
  test_31.main();
  test_32.main();
  test_33.main();
  test_34.main();
  test_35.main();
  test_36.main();
  test_37.main();
  test_38.main();
  test_39.main();
  test_40.main();
  test_41.main();
  test_42.main();
  test_43.main();

  js.scoped(() {
    js.context.__karma__.start = new js.Callback.once(() {});
    js.context.__karma__.info(js.map({'total': unittest.testCases.length}));
  });
  unittest.runTests();
}

