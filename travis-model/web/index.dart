import 'package:angular/angular.dart';
import 'package:angular/application_factory.dart';

class TravisBuild {
  String type;
  DateTime start;
  String id;
  TravisBuild(String this.type, Map obj) {
    try {
      start = DateTime.parse(obj['started_at']);
      id = "${obj['number']}";
    } catch (e) {
      throw "Could not parse date: ${obj['started_at']} in $obj";
    }
  }

  toString() => "$id $type $start";
}

@Injectable()
class Travis {
  Http _http;
  bool hasData = false;

  Map builds = {};

  var oldestBuild, newestBuild;

  DateTime get minTime => oldestBuild == null ? null : oldestBuild.start;
  DateTime get maxTime => newestBuild == null ? null : newestBuild.start;

  var gets = 0;

  getBuilds([afterId]) {
    gets++;
    if (gets > 4) return;
    var afterQ = afterId == null ? '' : '?after_number=$afterId';
    print("getting builds: $afterQ");
    _http.get('https://api.travis-ci.org/repositories/angular/angular.dart/builds.json$afterQ').then((HttpResponse obj) {
      obj.data.forEach((o) {
        var tb;

        try {
          tb = new TravisBuild('angular.dart', o);
        } catch (e) { return; }

        if (tb == null) return;
        builds[tb.id] = tb;
        if (oldestBuild == null || tb.start.isBefore(oldestBuild.start)) {
          oldestBuild = tb;
        }
        if (newestBuild == null || tb.start.isAfter(newestBuild.start)) {
          newestBuild = tb;
        }


      });
      print("obj: ${obj.data.length} ${builds.length}");
      print(builds);
      hasData = true;

      // fetch 50
      if (builds.length < 50) {
        getBuilds(oldestBuild.id);
      }

    });
  }

  Travis(this._http) {
    getBuilds();
  }
}

@Component(
  selector: 'travis-count',
  publishAs: 'ctrl',
  template: 'Got data: {{ctrl.travis.hasData}}'
)
class TravisCount {
  Travis travis;
  TravisCount(Travis this.travis);
}

class MinuteSlots {
  List minutes = [];
}

class MinuteSlot {
  DateTime time;
  int count = 0;
  MinuteSlot(this.time);

  get label => time.minute == 0 ? time.toString() : '';
}

main() {
  var app = applicationFactory()
      ..addModule(new Module()
        ..bind(MinuteSlots)
        ..bind(TravisCount)
        ..bind(Travis));

  var injector = app.run();

  if (injector == null) {
    print("null injector");
  }
  var scope = injector.get(Scope);
  var travis = injector.get(Travis);
  var ms = injector.get(MinuteSlots);
  updateMinutes(v, _) {
    if (travis.maxTime == null || travis.minTime == null) return;
    var minutes = ms.minutes = [];
    var t = travis.maxTime.add(new Duration(minutes: -1 * (travis.maxTime.minute % 5)));
    while (t.isAfter(travis.minTime)) {
      print(t);
      minutes.add(new MinuteSlot(t));
      t = t.add(new Duration(minutes: -5));
    }
    scope.context['minutes'] = minutes;
    print("minutes ${minutes.length}");
  }
  scope.context['travis'] = travis;
  scope.watch("travis.maxTime", updateMinutes);
  scope.watch("travis.minTime", updateMinutes);
}
