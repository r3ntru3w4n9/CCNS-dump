import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image/image.dart' as img;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool get initFinish => conn != null;
  bool get initNotFinish => conn == null;

  Socket conn;

  _HomePageState() {
    Socket.connect('10.0.2.2', 9999).then((soc) {
      setState(() {
        conn = soc;
        conn
          ..writeln('SERV')
          ..flush().then((_) => print('connected'));
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => initNotFinish
      ? SpinKitWave(color: Colors.red, size: 50.0)
      : Scaffold(
          appBar: AppBar(
            title: Text('Flutter Final Demo'),
            backgroundColor: Colors.blue,
          ),
          body: MainPage(conn: conn));
}

class MyPainter extends CustomPainter {
  ui.Image image;

  MyPainter(Stream<ui.Image> images) {
    update(images);
  }

  Future<void> update(Stream<ui.Image> images) async {
    await for (var image in images) {
      if (image == null) {
        print('should not have happened');
      }
      this.image = image;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (image == null) {
      print('no paint and $size');
      return;
    }
    print('paint on $size');
    canvas.drawImage(
      image,
      Offset.zero,
      Paint(),
    );
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    if (old is MyPainter) {
      if (image == null) {
        image = old.image;
        return false;
      } else {
        return image != old.image;
      }
    } else {
      return true;
    }
  }
}

class MainPage extends StatefulWidget {
  final Socket conn;

  MainPage({@required this.conn});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int width, height;
  img.Image image;

  @override
  void initState() {
    super.initState();
    width = 1;
    height = 1;
    updateImageSize();
    updateImagePixels();
  }

  void updateImageSize() {
    if (image == null || image.width != width || image.height != height) {
      print('$width, $height');
      image = img.Image.fromBytes(width, height,
          List.generate(width * height * 4, (i) => (i + 1) % 4 == 0 ? 0xff : 0),
          format: img.Format.rgba);
      print('$width, $height');
      for (int i = 0; i < width; ++i) {
        for (int j = 0; j < height; ++j) {
          image.setPixelRgba(i, j, 0, 0, 0);
        }
      }
    }
  }

  Future<void> updateImagePixels() async {
    print(widget.conn);
    await for (var data in widget.conn) {
      String.fromCharCodes(data)
          .split('\n')
          .map((s) => s.toString().trim())
          .forEach((str) {
        if (str.isEmpty) {
          return;
        }

        var codes = str.split(' ').map(int.parse).toList();
        if (codes.length != 5) {
          print(codes.length);
          return;
        }

        var x = codes[0];
        var y = codes[1];
        var r = codes[2];
        var g = codes[3];
        var b = codes[4];
        print('$x, $y, $r, $g, $b');
        setState(() {
          image.setPixelRgba(x, height - y - 1, r, g, b);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var textcol = Column(children: [
      TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.swap_horiz),
          labelText: 'width',
        ),
        onChanged: (text) {
          width = int.parse(text, onError: (_) => 0);
          print('changed w $width');
        },
      ),
      TextFormField(
        decoration: InputDecoration(
          icon: Icon(Icons.swap_vert),
          labelText: 'height',
        ),
        onChanged: (text) {
          height = int.parse(text, onError: (_) => 0);
          print('changed w $height');
        },
      ),
    ]);
    return Center(
      child: Column(
        children: [
          CustomPaint(
            size: Size(width.toDouble(), height.toDouble()),
            painter: MyPainter(() async* {
              print(image);
              print(image.width);
              print(image.height);
              ui.Codec codec =
                  await ui.instantiateImageCodec(img.encodePng(image));
              ui.FrameInfo frameInfo = await codec.getNextFrame();
              print(frameInfo.image);
              yield frameInfo.image;
            }()),
          ),
          SizedBox(height: 30),
          Container(
            child: textcol,
            margin: EdgeInsets.symmetric(horizontal: 30),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 8),
                borderRadius: BorderRadius.circular(20.0)),
          ),
          SizedBox(height: 25),
          ClipOval(
            child: Material(
              color: Colors.blue, // button color
              child: InkWell(
                splashColor: Colors.red, // inkwell color
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: Icon(
                    Icons.keyboard_arrow_right,
                    size: 35,
                  ),
                ),
                onTap: () {
                  widget.conn
                    ..writeln("$width $height")
                    ..flush();
                  updateImageSize();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
