package com.works.works_amap_map;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.os.Build;
import android.util.Log;
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

/** WorksAmapMapPlugin */
public class WorksAmapMapPlugin implements FlutterPlugin, MethodCallHandler ,
        ActivityAware , PluginRegistry.RequestPermissionsResultListener , PluginRegistry.ActivityResultListener {


  static final int REQUEST_AMAP = 3553;

  static  WorksAmapMapPlugin worksAmapMapPlugin;

  private Activity activity;
  private Context applicationContext;

  private MethodCall mMethodCall;
  private Result mResult;

  private static boolean isPermissionPresentInManifest(Context context, String permissionName) {
    try {
      PackageManager packageManager = context.getPackageManager();
      PackageInfo packageInfo =
              packageManager.getPackageInfo(context.getPackageName(), PackageManager.GET_PERMISSIONS);

      String[] requestedPermissions = packageInfo.requestedPermissions;
      return Arrays.asList(requestedPermissions).contains(permissionName);
    } catch (PackageManager.NameNotFoundException e) {
      e.printStackTrace();
      return false;
    }
  }

  static boolean needRequestCameraPermission(Context context) {
    boolean greatOrEqualM = Build.VERSION.SDK_INT >= Build.VERSION_CODES.M;
    return greatOrEqualM && isPermissionPresentInManifest(context, Manifest.permission.CAMERA);
  }

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {

    if(worksAmapMapPlugin == null)
    {
      worksAmapMapPlugin = this;
      worksAmapMapPlugin.applicationContext = flutterPluginBinding.getApplicationContext();

      final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "works_amap_map");
      channel.setMethodCallHandler(this);
    }
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    if (registrar.activity() == null) {
      // If a background flutter view tries to register the plugin, there will be no activity from the registrar,
      // we stop the registering process immediately because the ImagePicker requires an activity.
      return;
    }

    if(worksAmapMapPlugin == null) {
      final MethodChannel channel = new MethodChannel(registrar.messenger(), "works_amap_map");
      worksAmapMapPlugin = new WorksAmapMapPlugin();
      worksAmapMapPlugin.applicationContext = registrar.context();
      worksAmapMapPlugin.activity = registrar.activity();
      registrar.addActivityResultListener(worksAmapMapPlugin);
      channel.setMethodCallHandler(worksAmapMapPlugin);
    }

  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    mMethodCall = call;
    mResult = result;
   if(call.method.equals("showLocationMap")) {
      Map colorInfo = (Map) call.arguments;
      long barColor = (long) colorInfo.get("barColor");
      long titleColor = (long) colorInfo.get("titleColor");

      Intent intent = new Intent(activity, WorksAMapLocationActivity.class);
      intent.putExtra("barColor",(int)barColor);
      intent.putExtra("titleColor",(int)titleColor);
       activity.startActivityForResult(intent,REQUEST_AMAP);
    }
    else if(call.method.equals("showPotMap")) {
     Map arguments = (Map) call.arguments;
     long barColor = (long) arguments.get("barColor");
     long titleColor = (long) arguments.get("titleColor");

     Map locationInfo = (Map) arguments.get("location");


       Intent intent = new Intent(activity, WorksAMapActivity.class);

     double lat = (double) locationInfo.get("lat");
     double lon = (double) locationInfo.get("lon");

     if(locationInfo.containsKey("name"))
     {
         intent.putExtra("name",(String) locationInfo.get("name"));
     }

       if(locationInfo.containsKey("address"))
       {
           intent.putExtra("address",(String) locationInfo.get("address"));
       }


     intent.putExtra("barColor",(int)barColor);
     intent.putExtra("titleColor",(int)titleColor);

     intent.putExtra("lat",lat);
     intent.putExtra("lon",lon);
     activity.startActivity(intent);
       result.success(null);
       mMethodCall = null;
       mResult = null;
   } else{
      result.notImplemented();
      mMethodCall = null;
      mResult = null;
    }

  }


  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {

    if(worksAmapMapPlugin == this)
    {
      activity = binding.getActivity();
      binding.addRequestPermissionsResultListener(this);
      binding.addActivityResultListener(this);
    }

    Log.d("amap","onAttachedToActivity" + activity);
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    return false;
  }

  @Override
  public boolean onActivityResult(int requestCode, int resultCode, Intent data) {
    if(requestCode == REQUEST_AMAP)
    {
      if(mResult != null) {

        if (resultCode == 0) {
           Map info = new HashMap();
           info.put("lat",data.getDoubleExtra("lat",-100));
          info.put("lon",data.getDoubleExtra("lon",-100));
          String address = data.getStringExtra("address");
          String name = data.getStringExtra("name");
          info.put("address",name + "<-?->" + address);
           mResult.success(info);
        } else {
            mResult.success(null);
        }
      }
      mMethodCall = null;
      mResult = null;
    }
    return false;
  }
}
