package com.works.works_amap_map;

import android.animation.ObjectAnimator;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Rect;
import android.location.Location;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.*;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;

import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.amap.api.maps.AMap;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.MapView;
import com.amap.api.maps.model.*;
import com.amap.api.navi.AmapNaviPage;
import com.amap.api.navi.AmapNaviParams;
import com.amap.api.navi.AmapNaviType;
import com.amap.api.navi.INaviInfoCallback;
import com.amap.api.navi.model.AMapNaviLocation;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.core.PoiItem;
import com.amap.api.services.geocoder.*;
import com.google.android.material.bottomsheet.BottomSheetDialog;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class WorksAMapActivity extends FragmentActivity implements View.OnClickListener, INaviInfoCallback {

    //百度 com.baidu.BaiduMap
    //高德 com.autonavi.minimap
    //腾讯 com.tencent.map
    //谷歌 com.google.android.apps.maps
    static final String BAIDU_PKG = "com.baidu.BaiduMap";
    static final String AMAP_PKG = "com.autonavi.minimap";
    static final String TENCENT_PKG = "com.tencent.map";
    static final String GOOGLE_PKG = "com.google.android.apps.maps";

    private MapView mMapView = null;

    private int barColor;
    private  int titleColor;


    private TextView nameText;
    private TextView addressText;

    private double mLat = -200;
    private double mLon = -200;
    private String mName;

    private double mMyLat = -200;
    private double mMyLon = -200;
    private String mMyAddress;

    private BottomSheetDialog mSheetDialog;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        barColor = getIntent().getIntExtra("barColor",0);
        titleColor = getIntent().getIntExtra("titleColor",0xffffff);


        setContentView(R.layout.works_amap_activity);//设置对应的XML布局文件

        AMapUtil.transparentStatusBar(this,barColor);

        nameText = findViewById(R.id.map_title);
        addressText = findViewById(R.id.map_location);

        mMapView = findViewById(R.id.map);
        mMapView.onCreate(savedInstanceState);// 此方法必须重写

        ImageButton backBtn = findViewById(R.id.back_button);
        TextView titleTextView = findViewById(R.id.title);


        titleTextView.setTextColor(titleColor);
        backBtn.setColorFilter(titleColor);
        backBtn.setOnClickListener(this);
        findViewById(R.id.title_bar).setBackgroundColor(barColor);

        AMap aMap = mMapView.getMap();
        aMap.getUiSettings().setMyLocationButtonEnabled(true);

        MyLocationStyle myLocationStyle;
        myLocationStyle = new MyLocationStyle();//初始化定位蓝点样式类
        myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATION_ROTATE_NO_CENTER);//连续定位、且将视角移动到地图中心点，定位点依照设备方向旋转，并且会跟随设备移动。（1秒1次定位）如果不设置myLocationType，默认也会执行此种模式。
        myLocationStyle.interval(3000); //设置连续定位模式下的定位间隔，只在连续定位模式下生效，单次定位模式下不会生效。单位为毫秒。
        myLocationStyle.radiusFillColor(0x3300ff00);
        myLocationStyle.myLocationIcon(BitmapDescriptorFactory.fromBitmap(BitmapFactory
                .decodeResource(getResources(),R.drawable.myposition2)));

        aMap.setMyLocationStyle(myLocationStyle);
        aMap.setMyLocationEnabled(true);
        aMap.setOnMyLocationChangeListener(new AMap.OnMyLocationChangeListener() {
            @Override
            public void onMyLocationChange(Location location) {

                Bundle bundle  = location.getExtras();


                if(bundle !=null && bundle.containsKey("Address"))
                {
                    mMyAddress = bundle.getString("Address");
                }
                mMyLat = location.getLatitude();
                mMyLon = location.getLongitude();
            }
        });

//        aMap.setTrafficEnabled(true);
        aMap.showBuildings(true);


        aMap.moveCamera(CameraUpdateFactory.zoomTo(15.2f));
        aMap.setRoadArrowEnable(true);


        mLat = getIntent().getDoubleExtra("lat",-1000);
        mLon = getIntent().getDoubleExtra("lon",-1000);

        mName = getIntent().getStringExtra("name");
        String address = getIntent().getStringExtra("address");

        if(mName != null && address != null && !mName.isEmpty() && !address.isEmpty())
        {
            nameText.setText(mName);
            addressText.setText(address);
        }
        else
        {
            GeocodeSearch geocoderSearch = new GeocodeSearch(this);
            geocoderSearch.setOnGeocodeSearchListener(new GeocodeSearch.OnGeocodeSearchListener() {
                @Override
                public void onRegeocodeSearched(RegeocodeResult regeocodeResult, int i) {
                    if(i == 1000)
                    {
                        RegeocodeAddress regeocodeAddress = regeocodeResult.getRegeocodeAddress();

                        List<PoiItem> pois = regeocodeAddress.getPois();
                        if(pois.isEmpty())
                        {
                            addressText.setText(regeocodeAddress.getFormatAddress());
                        }
                        else
                        {
                            PoiItem poi = pois.get(0);

                            mName = poi.getTitle();

                            nameText.setText(mName);

                            if(poi.getSnippet().isEmpty())
                            {
                                addressText.setText(regeocodeAddress.getProvince() + regeocodeAddress.getCity() + poi.getAdName());

                            }
                            else {
                                addressText.setText(regeocodeAddress.getCity() + poi.getSnippet());
                            }

                        }


                    }
                    else
                    {
                        Toast.makeText(WorksAMapActivity.this,"获取地址数据错误!",Toast.LENGTH_SHORT).show();
                    }
                }

                @Override
                public void onGeocodeSearched(GeocodeResult geocodeResult, int i) {

                }
            });

            RegeocodeQuery query = new RegeocodeQuery(new LatLonPoint(mLat,mLon), 200,GeocodeSearch.AMAP);

            geocoderSearch.getFromLocationAsyn(query);


        }

        if(mLat >= -180 && mLon >= -180)
        {
            MarkerOptions markerOption = new MarkerOptions();
            markerOption.position(new LatLng(mLat,mLon));
            markerOption.draggable(false);//设置Marker可拖动
            markerOption.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory
                    .decodeResource(getResources(),R.drawable.biezhen4)));
            // 将Marker设置为贴地显示，可以双指下拉地图查看效果
            markerOption.setFlat(true);//设置marker平贴地图效果
            aMap.addMarker(markerOption);

            aMap.animateCamera(CameraUpdateFactory.changeLatLng(new LatLng(mLat,mLon)));

        }


//        aMap.setOnCameraChangeListener(new AMap.OnCameraChangeListener() {
//            @Override
//            public void onCameraChange(CameraPosition cameraPosition) {
//            }
//
//            @Override
//            public void onCameraChangeFinish(CameraPosition cameraPosition) {
//
//
//            }
//        });


        findViewById(R.id.go_navi).setOnClickListener(this);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        if(id == R.id.back_button)
        {
            setResult(1,new Intent());
            finish();
        }
       else if(id == R.id.go_navi)
        {

            if(mSheetDialog == null)
            {
                mSheetDialog = new BottomSheetDialog(this);

                LinearLayout contentView = new LinearLayout(this);
                contentView.setOrientation(LinearLayout.VERTICAL);
                LinearLayout.LayoutParams layoutParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
                contentView.setBackgroundColor(Color.WHITE);
                contentView.setLayoutParams(layoutParams);

                TextView innerMap = new TextView(this);

                LinearLayout.LayoutParams textParams = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, DensityUtil.dp2px(this,50));            //设置textview垂直居中

                innerMap.setGravity(Gravity.CENTER);

                innerMap.setTag("inner");
                innerMap.setLayoutParams(textParams);

                innerMap.setTextSize(16);
                innerMap.setTextColor(0xff333333);
                innerMap.setText("应用内地图");

                innerMap.setOnClickListener(this);

                contentView.addView(innerMap);

                Map<String,String> maps = getInstalledMap();

                if(maps.containsKey(AMAP_PKG))
                {
                    String appName = maps.get(AMAP_PKG);
                    TextView textView = new TextView(this);
                    textView.setGravity(Gravity.CENTER);
                    textView.setTag("amap");
                    textView.setLayoutParams(textParams);
                    textView.setTextSize(16);
                    textView.setTextColor(0xff333333);
                    textView.setText(appName.isEmpty() ? "高德地图" : appName);
                    textView.setOnClickListener(this);
                    contentView.addView(textView);
                }

                if(maps.containsKey(BAIDU_PKG))
                {
                    String appName = maps.get(BAIDU_PKG);
                    TextView textView = new TextView(this);
                    textView.setGravity(Gravity.CENTER);
                    textView.setTag("baidu");
                    textView.setLayoutParams(textParams);
                    textView.setTextSize(16);
                    textView.setTextColor(0xff333333);
                    textView.setText(appName.isEmpty() ? "百度地图" : appName);
                    textView.setOnClickListener(this);
                    contentView.addView(textView);
                }
                if(maps.containsKey(TENCENT_PKG))
                {
                    String appName = maps.get(TENCENT_PKG);
                    TextView textView = new TextView(this);
                    textView.setGravity(Gravity.CENTER);
                    textView.setTag("tencent");
                    textView.setLayoutParams(textParams);
                    textView.setTextSize(16);
                    textView.setTextColor(0xff333333);
                    textView.setText(appName.isEmpty() ? "腾讯地图":appName);
                    textView.setOnClickListener(this);
                    contentView.addView(textView);
                }
                if(maps.containsKey(GOOGLE_PKG))
                {
                    String appName = maps.get(GOOGLE_PKG);
                    TextView textView = new TextView(this);
                    textView.setGravity(Gravity.CENTER);
                    textView.setTag("google");
                    textView.setLayoutParams(textParams);
                    textView.setTextSize(16);
                    textView.setTextColor(0xff333333);
                    textView.setText(appName.isEmpty() ? "谷歌地图" :appName);
                    textView.setOnClickListener(this);
                    contentView.addView(textView);
                }


                mSheetDialog.setContentView(contentView);
            }

            mSheetDialog.show();
        }
       else
        {
            Object tag = view.getTag();
            if(tag != null)
            {
                if(mSheetDialog != null) {

                    mSheetDialog.dismiss();
                }

                if(mLat < -180 || mLon < -180)
                {
                    Toast.makeText(WorksAMapActivity.this,"无坐标点，不能导航!",Toast.LENGTH_SHORT).show();
                    return;
                }

                Intent intent = null;

                if(tag.equals("inner"))
                {
                    Poi start = null;
                    if(mMyLat >= -180 && mMyLon >= -180)
                    {

                        start = new Poi((mMyAddress != null && !mMyAddress.isEmpty()) ? mMyAddress :"", new LatLng(mMyLat,mMyLon), "");

                    }

                    Poi end = new Poi((mName != null && !mName.isEmpty()) ? mName :"", new LatLng(mLat, mLon), "");
                    AmapNaviPage.getInstance().showRouteActivity(this, new AmapNaviParams(start,null,end, AmapNaviType.DRIVER), this);
                }
                else if(tag.equals("baidu"))
                {
                    String packageName = getApplication().getPackageName();

                    intent = new Intent();
                    String baiduString = "baidumap://map/direction?mode=driving";

                    if(mMyLat >= -180 && mMyLon >= -180)
                    {
                        baiduString += "&origin=";
                        if(mMyAddress != null && !mMyAddress.isEmpty())
                        {
                            baiduString += "name:"+ mMyAddress + "|latlng:";
                        }
                        baiduString += mMyLat +"," + mMyLon;
                    }

                    baiduString += "&destination=";

                    if(mName != null && !mName.isEmpty())
                    {
                        baiduString += "name:"+ mName + "|latlng:";
                    }

                    intent.setData(Uri.parse(baiduString + mLat +"," + mLon +
                            "&coord_type=gcj02&src="+packageName));

                }
                else if(tag.equals("tencent"))
                {
                    String tencentString = "qqmap://map/routeplan?type=drive&referer=OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77&tocoord=";
                    tencentString += mLat +"," + mLon;
                    if(mName != null && !mName.isEmpty())
                    {
                        tencentString += "&to="+ mName;
                    }

                    if(mMyLat >= -180 && mMyLon >= -180)
                    {
                        tencentString += "&fromcoord=" + mMyLat + "," + mMyLon;
                        if(mMyAddress != null && !mMyAddress.isEmpty())
                        {
                            tencentString += "&from="+ mMyAddress;
                        }
                    }

                    intent = new Intent(Intent.ACTION_VIEW, Uri.parse(tencentString));
                }
                else if(tag.equals("amap"))
                {
                    String amapString = "amapuri://route/plan/?sourceApplication=amaptest&dev=0&t=0&dlat=" + mLat
                            + "&dlon=" + mLon;
                    if(mName != null && !mName.isEmpty())
                    {
                        amapString += "&dname="+ mName;
                    }

                    if(mMyLat >= -180 && mMyLon >= -180)
                    {
                        amapString += "&slat=" + mMyLat + "&slon=" + mMyLon;
                        if(mMyAddress != null && !mMyAddress.isEmpty())
                        {
                            amapString += "&sname="+ mMyAddress;
                        }
                    }
                    intent = new Intent(Intent.ACTION_VIEW, Uri.parse(amapString));
                    intent.setPackage(AMAP_PKG);
                }
                else if(tag.equals("google"))
                {

                    Uri gmmIntentUri = Uri.parse("google.navigation:q=" + mLat + "," + mLon);
                    intent = new Intent(Intent.ACTION_VIEW, gmmIntentUri);
                    intent.setPackage(GOOGLE_PKG);

                }
                if(intent != null)
                {
                    if(intent.resolveActivity(getPackageManager()) != null)
                    {
                        startActivity(intent);
                    }
                    else
                    {
                        Toast.makeText(WorksAMapActivity.this,"未能打开次地图，请选择其他地图!",Toast.LENGTH_SHORT).show();
                    }

                }
            }
        }

    }

    private boolean isInstalled(String packageName) {
        PackageManager manager = getPackageManager();
        //获取所有已安装程序的包信息
        List<PackageInfo> installedPackages = manager.getInstalledPackages(0);
        if (installedPackages != null) {
            for (PackageInfo info : installedPackages) {
                if (info.packageName.equals(packageName)) {
                    return true;
                }
            }
        }
        return false;
    }

    private Map<String ,String> getInstalledMap()
    {
        Map<String ,String> installMaps = new HashMap();
        PackageManager manager = getPackageManager();
        //获取所有已安装程序的包信息
        List<PackageInfo> installedPackages = manager.getInstalledPackages(0);
        if (installedPackages != null) {
            for (PackageInfo info : installedPackages) {

                String pkgName = info.packageName;
                String appName = null;
                if (pkgName.equals(BAIDU_PKG) || pkgName.equals(AMAP_PKG) || pkgName.equals(TENCENT_PKG) || pkgName.equals(GOOGLE_PKG)) {
                    try
                    {
                        appName = manager.getApplicationLabel(manager.getApplicationInfo(pkgName,PackageManager.GET_META_DATA)).toString();
                    }
                    catch (Exception e){
                        appName = "";
                    }
                    installMaps.put(pkgName,appName);

                }

                if(installMaps.size() >= 4 )
                {
                    break;
                }
            }
        }
        return installMaps;
    }

    @Override
    public void onInitNaviFailure() {

    }

    @Override
    public void onGetNavigationText(String s) {

    }

    @Override
    public void onLocationChange(AMapNaviLocation aMapNaviLocation) {

    }

    @Override
    public void onArriveDestination(boolean b) {

    }

    @Override
    public void onStartNavi(int i) {

    }

    @Override
    public void onCalculateRouteSuccess(int[] ints) {

    }

    @Override
    public void onCalculateRouteFailure(int i) {

    }

    @Override
    public void onStopSpeaking() {

    }

    @Override
    public void onReCalculateRoute(int i) {

    }

    @Override
    public void onExitPage(int i) {

    }

    @Override
    public void onStrategyChanged(int i) {

    }

    @Override
    public View getCustomNaviBottomView() {
        return null;
    }

    @Override
    public View getCustomNaviView() {
        return null;
    }

    @Override
    public void onArrivedWayPoint(int i) {

    }

    @Override
    public void onMapTypeChanged(int i) {

    }

    @Override
    public View getCustomMiddleView() {
        return null;
    }

    @Override
    public void onNaviDirectionChanged(int i) {

    }

    @Override
    public void onDayAndNightModeChanged(int i) {

    }

    @Override
    public void onBroadcastModeChanged(int i) {

    }

    @Override
    public void onScaleAutoChanged(boolean b) {

    }


    private static class DensityUtil {

        /**
         * 单位转换: dp -> px
         *
         * @param dp
         * @return
         */
        public static int dp2px(Context context, int dp) {
            return (int) (getDensity(context) * dp + 0.5);
        }

        /**
         * 单位转换: sp -> px
         *
         * @param sp
         * @return
         */
        public static int sp2px(Context context, int sp) {
            return (int) (getFontDensity(context) * sp + 0.5);
        }

        /**
         * 单位转换:px -> dp
         *
         * @param px
         * @return
         */
        public static int px2dp(Context context, int px) {
            return (int) (px / getDensity(context) + 0.5);
        }

        /**
         * 单位转换:px -> sp
         *
         * @param px
         * @return
         */
        public static int px2sp(Context context, int px) {
            return (int) (px / getFontDensity(context) + 0.5);
        }

        public static float getDensity(Context context) {
            return context.getResources().getDisplayMetrics().density;
        }

        public static float getFontDensity(Context context) {
            return context.getResources().getDisplayMetrics().scaledDensity;
        }

    }

//    @Override
//    public void finish() {
//        super.finish();
//        //注释掉activity本身的过渡动画
//        overridePendingTransition(R.anim.slide_in_from_left, R.anim.slide_out_to_right);
//    }

}
