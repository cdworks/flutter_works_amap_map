package com.works.works_amap_map_example;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.PersistableBundle;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    if (Build.VERSION.SDK_INT >= 23) {
      int REQUEST_CODE_CONTACT = 101;
      String[] permissions = {
              Manifest.permission.RECORD_AUDIO,
              Manifest.permission.WRITE_EXTERNAL_STORAGE,
              Manifest.permission.READ_EXTERNAL_STORAGE,
              Manifest.permission.INTERNET,
              Manifest.permission.ACCESS_NETWORK_STATE,
              Manifest.permission.ACCESS_WIFI_STATE,
              Manifest.permission.READ_PHONE_STATE,
              Manifest.permission.ACCESS_COARSE_LOCATION,
              Manifest.permission.ACCESS_FINE_LOCATION,
              Manifest.permission.ACCESS_LOCATION_EXTRA_COMMANDS,
              Manifest.permission.CHANGE_WIFI_STATE,

      };
      //验证是否许可权限
      for (String str : permissions) {
        if (this.checkSelfPermission(str) != PackageManager.PERMISSION_GRANTED) {
          //申请权限
          this.requestPermissions(permissions, REQUEST_CODE_CONTACT);
          return;
        }
      }
    }
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
  }
}
