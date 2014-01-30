import 'package:angular/angular.dart';

@NgController(
  selector: '[contrib]',
  publishAs: 'ctrl'
)
class Contrib {
  var imgs = [
    'avatars/1-deboer.jpeg',
    'avatars/2-mhevery.jpeg',
    'avatars/3-pavelj.jpeg',
    'avatars/4-chirayu.jpeg',
    'avatars/5-vojta.png',
    'avatars/6-vicb.jpeg',
    'avatars/7-cbracken.png',
    'avatars/8-akiellor.png',
    'avatars/9-matsko.jpeg',
    'avatars/10-justin.jpeg',
    'avatars/11-blois.png',
    'avatars/12-sethladd.jpeg',
    'avatars/13-demike.png',
    'avatars/14-codelogic.jpeg',
    'avatars/15-dirlantis.jpeg',
    'avatars/16-d2m.jpeg',
    'avatars/17a-andersforsell.jpeg',
    'avatars/17-bgourlie.jpeg',
    'avatars/17-yjbanov.png',
    'avatars/18-gmacd.jpeg',
    'avatars/19-kemalle.jpeg',
    'avatars/20-nerdrew.jpeg',
    'avatars/21-zoechi.png',
    'avatars/22-kurman.png',
    'avatars/23-jwren.jpeg',
    'avatars/24-marko.jpeg',
    'avatars/25-marcf.png'

  ];

  List rows = [];
  Contrib() {
    List curRow = [];
    imgs.forEach((i) {
      curRow.add(i);
      if (curRow.length == 3) {
        rows.add(curRow);
        curRow = [];
      }
    });
  }
}

main() {
  ngBootstrap(module: new Module()
    ..type(Contrib));
}
