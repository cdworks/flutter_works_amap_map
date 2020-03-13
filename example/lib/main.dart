import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:works_amap_map/works_amap_map.dart';

void main() {

  runApp(new MyApp());

}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
//    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await WorksAmapMap.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child:
              Column(
                children: <Widget>[
                  Text('Running on: $_platformVersion\n'),
                  MaterialButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: new Text('点我'),
                    onPressed: () async {
                      // ...
//                      WorksAmapMap.startLocationMap(Color(0xFF00D0C5)
//                          .value,0xffffffff);
                      WorksAmapMap.startPotMapMap(Color(0xFF00D0C5)
                          .value,0xffffffff,{"lat":30.7,"lon":104.09,"name"
                          :"复城国际","address":"剑南大道三段"});
                    },
                  )
                ],
              )

        ),
      ),
    );
  }
}
