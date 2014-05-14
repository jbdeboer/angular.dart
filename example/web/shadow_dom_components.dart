import 'dart:html';

import 'package:angular/angular.dart';
import 'package:angular/animate/module.dart';
import 'package:angular/application_factory.dart';
import 'package:di/di.dart';

main() {

  print("hello world");

  var app = applicationFactory();
  app.modules.add(new Module()
    ..bind(MyComponent));
  app.selector("body");
  app.run();
}

@Component(
    selector: "my-component",
    publishAs: "ctrl",
    template: """
      <div class="custom-component" ng-class="ctrl.color">
        <span>Shadow [</span>
        <content></content>
        <span>]</span>
        <a href="#" ng-click="ctrl.on=!ctrl.on">[Toggle]</a>
        <span ng-if="ctrl.on">off</span>
        <span ng-if="!ctrl.on">on</span>
      </div>
    """,
    cssUrl: "/css/shadow_dom_components.css")
class MyComponent {
  @NgAttr('color')
  String color;

  bool on = false;
}