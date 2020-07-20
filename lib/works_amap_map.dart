import 'dart:async';

import 'package:flutter/services.dart';

class WorksAmapMap {
  static const MethodChannel _channel =
      const MethodChannel('works_amap_map');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<Map> startLocationMap(int barColor ,int titleColor)  async{
   return await _channel.invokeMethod('showLocationMap',{"barColor":barColor,"titleColor":
   titleColor});
  }

  //////省/直辖市
  //@property (nonatomic, copy) NSString *province;
  //
  /////市
  //@property (nonatomic, copy) NSString *city;
  //
  /////区
  //@property (nonatomic, copy) NSString *district;

  //info.put("code", 0);
  //        info.put("msg", "");
  //         info.put("lat", lat);
  //           info.put("lon", lon);
  //            info.put("district");
  //    info.put("province",);
  //       info.put("city",);
  //   info.put("address", address);
  static Future<Map> startLocationOnce()  async{
    return await _channel.invokeMethod('startLocationOnce');
  }

  static void startPotMapMap(int barColor ,int titleColor,Map locationInfo) {

//    location
   // lat :30.585,
    // lon :104.06,
    // name :"复城国际"  可选
    // address : 剑南大道三段 可选

    _channel.invokeMethod('showPotMap',{"barColor":barColor,"titleColor":
    titleColor,"location":locationInfo});
  }


}
