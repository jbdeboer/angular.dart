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

  //var oldestBuild, newestBuild;

  //DateTime get minTime => oldestBuild == null ? null : oldestBuild.start;
  //DateTime get maxTime => newestBuild == null ? null : newestBuild.start;

  var gets = 0;

  getBuilds(repo, oldestBuild, [afterId]) {
    gets++;
    if (gets > 40) return;
    var afterQ = afterId == null ? '' : '?after_number=$afterId';
    print("getting builds: $afterQ");
    _http.get('https://api.travis-ci.org/repositories/angular/$repo/builds.json$afterQ').then((HttpResponse obj) {
      obj.data.forEach((o) {
        var tb;

        try {
          tb = new TravisBuild(repo, o);
        } catch (e) { return; }

        if (tb == null) return;

        minutes.add(tb.start, repo);

        builds[tb.id] = tb;
        if (oldestBuild == null || tb.start.isBefore(oldestBuild.start)) {
          oldestBuild = tb;
        }
     //   if (newestBuild == null || tb.start.isAfter(newestBuild.start)) {
     //     newestBuild = tb;
     //   }


      });
      print("obj: ${obj.data.length} ${builds.length}");
      print(builds);
      hasData = true;

      // fetch 3 days
      var lastWeek = new DateTime.now().add(new Duration(days: -7));
      print("oldest: ${oldestBuild.start} ${oldestBuild.start.isAfter(lastWeek)}");
      if (oldestBuild.start.isAfter(lastWeek)) {
        getBuilds(repo, oldestBuild, oldestBuild.id);
      }

    
    });
  }

  MinuteSlots minutes;
  Travis(this._http, this.minutes) {
    getBuilds('angular.dart', null);
    getBuilds('angular.js', null);


    //minutes.add(new DateTime.now(), "ad");
    //minutes.add(new DateTime.now().add(new Duration(hours: -4)), "ad");
  }

  var _onC;
  onChange(fn) {
    _onC = fn;
  }
}

@Component(
  selector: 'travis-count',
  publishAs: 'ctrl',
  template: '''<style>.totalminutes { padding-left: 0.5em; float: left; } .minute { height: 1.2em } .reset { clear: both}  .label { padding-right: 0.5em; float: left; } .count { float: left; background: lightblue } .ajscount { float: left; background: lightgreen }</style>
   <span style="background: lightblue">Blue is AngularDart</span>, <span style="background: lightgreen">Green is AngularJS.</span>  Below is the number of Travis jobs started every hour for the last week.  The bars are scaled by runtime (115 minutes for AngularDart, 39 minutes for AngularJS)

   <ul>
  <li>Total Dart jobs: {{ctrl.ms.totalDart}}</li>
  <li>Total JS jobs: {{ctrl.ms.totalJs}}</li>
  <li>Workday (9-5 PST) Dart: {{ctrl.ms.wdDart}}</li>
  <li>Workday JS: {{ctrl.ms.wdJs}}</li>
</ul>


    <div class="minute" ng-repeat="m in ctrl.ms.minutes">
      <span class="label">{{m.label}}</span>
      <span class="count" ng-style="{width: (3.45 * m.count) + 'em'}">{{m.countS}}</span>
      <span class="ajscount" ng-style="{width: (1.17 * m.ajscount) + 'em'}">{{m.ajscountS}}</span>
      <span class="totalminutes">{{m.totalMinutes}}</span>
      
      <span class="reset"></span>
      
    </div>'''
)
class TravisCount {
  Travis travis;
  MinuteSlots ms;
  TravisCount(Travis this.travis, this.ms);
}

@Injectable()
class MinuteSlots {
  Travis travis;
  var travisDirty = true;

  int totalDart = 0, totalJs = 0, wdDart = 0, wdJs = 0;

  MinuteSlots() {
    //travis.onChange(() => travisDirty = true);
  }

  Map minMap = {};
  List _minutes = [];
  get minutes {
    //if (travisDirty) update();
    //print("minutes from ms ${_minutes.length}");
    return _minutes;
  }

  update() {

  }

  DateTime minTime, maxTime;

  slotId(time) => time.add(new Duration(minutes: -1 * (time.minute),
                                   seconds: -1 * (time.second),
                                   milliseconds: -1 * (time.millisecond)
                                   ));
  getSlot(time) => minMap[slotId(time).millisecondsSinceEpoch];

  addSlot(start, end) {
    if (start.isAfter(end)) throw "Bad addSlot $start < $end";
    var t = slotId(start);
    do {
      minMap.putIfAbsent(t.millisecondsSinceEpoch, () => new MinuteSlot(t));
      t = t.add(new Duration(minutes: 60));
    } while (t.isBefore(end));

    // Update the list.
    var minKeys = minMap.keys.toList();
    minKeys.sort();
    _minutes.clear();
    minKeys.reversed.forEach((x) => _minutes.add(minMap[x]));
    print("$_minutes");

  }
  add(DateTime time, String type) {
    if (minTime == null) { 
      minTime = time;
      addSlot(time, time);
    }
    if (maxTime == null) {
      maxTime = time;
      addSlot(time, time);
    }

    if (time.isBefore(minTime)) {
      addSlot(time, minTime);
      minTime = time;
    }

    if (time.isAfter(maxTime)) {
      addSlot(maxTime, time);
      maxTime = time;
    }

    var slot = getSlot(time);
    bool isWorkday = false;
    if (time.weekday != DateTime.SUNDAY && time.weekday != DateTime.SATURDAY && (time.hour >= 17 || time.hour <= 1)) isWorkday = true;
    if (type == 'angular.js') {
      slot.ajscount++;
      totalJs++;
      if (isWorkday) wdJs++;
    } else {
      slot.count++;
      totalDart++;
      if (isWorkday) wdDart++;
    }
    //getSlot(time).count++;
  }
}

class MinuteSlot {
  DateTime time;
  int count = 0;
  int ajscount = 0;
  MinuteSlot(this.time);

  get label => time.minute == 0 ? time.toString() : '';
  get countS => count == 0 ? '' : "$count";
  get ajscountS => ajscount == 0 ? '' : "$ajscount";
  get totalMinutesInt => count * 115 + ajscount * 39;
  get totalMinutes => totalMinutesInt == 0 ? '' : "$totalMinutesInt mins"; 

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
  //scope.watch('1', () => scope.context['ms'] = ms);
  print("Setting ms: $ms");
  // updateMinutes(v, _) {
  //   if (travis.maxTime == null || travis.minTime == null) return;
  //   var minutes = ms.minutes = [];
  //   var t = travis.maxTime.add(new Duration(minutes: -1 * (travis.maxTime.minute % 5)));
  //   while (t.isAfter(travis.minTime)) {
  //     print(t);
  //     minutes.add(new MinuteSlot(t));
  //     t = t.add(new Duration(minutes: -5));
  //   }
  //   scope.context['minutes'] = minutes;
  //   print("minutes ${minutes.length}");
  // }
  //scope.context['travis'] = travis;
  //scope.watch("travis.maxTime", updateMinutes);
  //scope.watch("travis.minTime", updateMinutes);
}
