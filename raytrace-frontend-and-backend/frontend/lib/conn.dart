import 'dart:async';
import 'dart:io';

class Img {
  final int x, y;
  List<int> data;

  Img(int x, int y)
      : x = x,
        y = y,
        data = List.generate(x * y, (_) => 0);

  int getPixel(int i, int j) {
    assert(i >= 0);
    assert(j >= 0);
    assert(i < x);
    assert(j < y);
    return data[j * x + i];
  }

  setPixel(int i, int j, int val) {
    assert(i >= 0);
    assert(j >= 0);
    assert(i < x);
    assert(j < y);
    data[j * x + i] = val;
  }
}

Future<void> keepConn(Img img) async {
  Socket.connect('localhost', 9999)
      .then((Socket s) => s
        ..writeln('SERV')
        ..writeln('${img.x} ${img.y}')
        ..flush())
      .then((Socket s) async {
    await for (var data in s) {
      print('received');
      String.fromCharCodes(data).trim().split('\n').forEach((d) {
        var list = d.split(' ');
        print(list);
        var x = int.parse(list[0]);
        var y = int.parse(list[1]);
        var r = int.parse(list[2]);
        var g = int.parse(list[3]);
        var b = int.parse(list[4]);
      });
    }
  });
}

main() {
  var img = Img(200, 100);
  keepConn(img);
}
