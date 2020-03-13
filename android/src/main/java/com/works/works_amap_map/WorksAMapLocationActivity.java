package com.works.works_amap_map;

import android.animation.ObjectAnimator;
import android.annotation.TargetApi;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.WindowManager;
import android.widget.*;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.maps.*;
import com.amap.api.maps.model.*;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.poisearch.PoiResult;
import com.amap.api.services.poisearch.PoiSearch;
import com.amap.api.services.core.PoiItem;

import java.util.ArrayList;

public class WorksAMapLocationActivity extends FragmentActivity implements View.OnClickListener {

    private MapView mMapView = null;
    private AMapLocation firstLocation = null;

    private TextView loadingTextView;

    private View biezhenView;
    private RecyclerView recyclerView;

    private PoiSearch poiSearch;
    private PoiSearch.Query poiQuery;
    private ActivityIndicatorView indicatorView;

    private int barColor;
    private  int titleColor;

    private  Marker selectedMarker;

    private boolean isFromClick = true;

    //声明AMapLocationClient类对象
    public AMapLocationClient mLocationClient = null;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        barColor = getIntent().getIntExtra("barColor",0);
        titleColor = getIntent().getIntExtra("titleColor",0xffffff);
        setContentView(R.layout.works_amap_location_activity);//设置对应的XML布局文件

        loadingTextView = findViewById(R.id.loading_text);
        loadingTextView.setVisibility(View.VISIBLE);
        biezhenView = findViewById(R.id.biezhen);
        recyclerView = findViewById(R.id.recycle_view);
        indicatorView = findViewById(R.id.indicator);

        indicatorView.setVisibility(View.GONE);

        LinearLayoutManager layoutManager = new LinearLayoutManager(this);

        recyclerView.setLayoutManager(layoutManager);

        DividerItemDecoration dividerItemDecoration = new DividerItemDecoration(this,layoutManager.getOrientation())
        {
            @Override
            public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {

                outRect.left = 16;
                outRect.right = 16;

//                super.getItemOffsets(outRect, view, parent, state);

            }
        };
        dividerItemDecoration.setDrawable(getResources().getDrawable(R.drawable.divider));
        recyclerView.addItemDecoration(dividerItemDecoration);


        recyclerView.setHasFixedSize(true);
        recyclerView.setAdapter(new AddressAdapter());

        initLocation();

        AMapUtil.transparentStatusBar(this,barColor);

        mMapView = findViewById(R.id.map);
        mMapView.onCreate(savedInstanceState);// 此方法必须重写

        ImageButton backBtn = findViewById(R.id.back_button);
        TextView titleTextView = findViewById(R.id.title);
        Button okButton = findViewById(R.id.ok_button);
        backBtn.setOnClickListener(this);
        okButton.setOnClickListener(this);

        titleTextView.setTextColor(titleColor);
        backBtn.setColorFilter(titleColor);
        findViewById(R.id.title_bar).setBackgroundColor(barColor);
        okButton.setTextColor(titleColor);

        AMap aMap = mMapView.getMap();
        UiSettings uiSettings = aMap.getUiSettings();
        uiSettings.setMyLocationButtonEnabled(false);
        uiSettings.setZoomInByScreenCenter(true);
        uiSettings.setGestureScaleByMapCenter(true);
        aMap.moveCamera(CameraUpdateFactory.zoomTo(15));

        aMap.setRoadArrowEnable(true);

        aMap.setOnCameraChangeListener(new AMap.OnCameraChangeListener() {
            @Override
            public void onCameraChange(CameraPosition cameraPosition) {
            }

            @Override
            public void onCameraChangeFinish(CameraPosition cameraPosition) {

                if(isFromClick)
                {
                    isFromClick = false;
                    return;
                }

                if(selectedMarker != null)
                {
                    selectedMarker.setVisible(false);
                }

                ObjectAnimator.ofFloat(biezhenView, "translationY", 0, -80,0)
                        .setDuration(500).start();


                ((AddressAdapter)recyclerView.getAdapter()).setAdapterData(null,-1);

                indicatorView.setVisibility(View.VISIBLE);
                poiSearch.setBound(new PoiSearch.SearchBound(new LatLonPoint(cameraPosition.target.latitude,
                        cameraPosition.target.longitude), 3000));//设置周边搜索的中心点以及半径

                poiSearch.searchPOIAsyn();
            }
        });

        findViewById(R.id.go_my).setOnClickListener(this);

        ImageButton searchBtn = findViewById(R.id.search_button);
        searchBtn.setOnClickListener(this);
        searchBtn.setColorFilter(titleColor);

    }

    private void initLocation()
    {
        //初始化定位
        mLocationClient = new AMapLocationClient(getApplicationContext());


        //异步获取定位结果
        AMapLocationListener mAMapLocationListener = new AMapLocationListener() {
            @Override
            public void onLocationChanged(AMapLocation amapLocation) {
                if (amapLocation != null) {
                    int errorCode = amapLocation.getErrorCode();
                    if (errorCode == 0) {

                        if(amapLocation.getLatitude() > 0 && amapLocation.getLatitude() > 0)
                        {
                            firstLocation = amapLocation;
                            Log.d("amap","first location:" + "{" + amapLocation.getLatitude() + "," + amapLocation.getLongitude() + "}");
                            mLocationClient.stopLocation();
                            loadingTextView.setVisibility(View.INVISIBLE);
                            setMyLocation();
                        }
                        else {
                            Log.d("amap", "suc location:" + "{" + amapLocation.getLatitude() + "," + amapLocation.getLongitude() + "}");
                        }

                    }
                    else
                    {
                        Log.d("amap","location Error, ErrCode:"
                                + amapLocation.getErrorCode() + ", errInfo:"
                                + amapLocation.getErrorInfo());
                    }
                }
            }
        };

        //设置定位回调监听
        mLocationClient.setLocationListener(mAMapLocationListener);


        AMapLocationClientOption mLocationOption = new AMapLocationClientOption();
        mLocationOption.setNeedAddress(true);
        mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);
        mLocationClient.setLocationOption(mLocationOption);

        //启动定位
        mLocationClient.startLocation();


    }

    void setMyLocation()
    {
        LatLng myLocation = new LatLng(firstLocation.getLatitude(),firstLocation.getLongitude());
//        mMapView.getMap().animateCamera(CameraUpdateFactory.changeLatLng(myLocation));
//        mMapView.getMap().setPointToCenter(myLocation.latitude);


        MarkerOptions markerOption = new MarkerOptions();
        markerOption.position(myLocation);

        markerOption.draggable(false);//设置Marker可拖动
        markerOption.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory
                .decodeResource(getResources(),R.drawable.myposition2)));
        // 将Marker设置为贴地显示，可以双指下拉地图查看效果
        markerOption.setFlat(true);//设置marker平贴地图效果
        markerOption.anchor(0.5f,0.5f);
        mMapView.getMap().addMarker(markerOption);

        poiQuery = new PoiSearch.Query("","","");
        poiQuery.setPageSize(20);
        poiQuery.setPageNum(1);
        poiSearch = new PoiSearch(this,poiQuery);
        poiSearch.setOnPoiSearchListener(new PoiSearch.OnPoiSearchListener() {
            @Override
            public void onPoiSearched(PoiResult poiResult, int errorCode) {
                indicatorView.setVisibility(View.GONE);
                if(errorCode == 1000)
                {
                    Log.d("amap","poisearched total pageCount:" + poiResult.getPageCount() + " num:" + poiResult.getPois().size());
                    ((AddressAdapter)recyclerView.getAdapter()).setAdapterData(poiResult.getPois(),0);
                }
                else
                {
                    Toast.makeText(WorksAMapLocationActivity.this,"查询错误！",Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onPoiItemSearched(com.amap.api.services.core.PoiItem poiItem, int i) {

            }
        });


        mMapView.getMap().moveCamera(CameraUpdateFactory.changeLatLng(myLocation));

        indicatorView.setVisibility(View.VISIBLE);
        poiSearch.setBound(new PoiSearch.SearchBound(new LatLonPoint(firstLocation.getLatitude(),
                firstLocation.getLongitude()), 3000));//设置周边搜索的中心点以及半径

        poiSearch.searchPOIAsyn();

    }



    @Override
    public void onBackPressed() {
        super.onBackPressed();
        setResult(1,new Intent());
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        mMapView.onDestroy();
    }

    @Override
    protected void onPause() {
        super.onPause();
        mMapView.onPause();

    }

    @Override
    protected void onResume() {
        super.onResume();
        mMapView.onResume();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        mMapView.onSaveInstanceState(outState);
    }

    @Override
    public void onClick(View view) {
        int id = view.getId();
        if(id == R.id.ok_button)
        {
            AddressAdapter adapter = (AddressAdapter) recyclerView.getAdapter();

            if(adapter.poiList != null && adapter.poiList.size() > 0 && adapter.currentIndex >=0 && adapter.currentIndex < adapter.poiList.size())
            {
                PoiItem item = adapter.poiList.get(adapter.currentIndex);
                Intent intent = new Intent();
                intent.putExtra("lat",item.getLatLonPoint().getLatitude());
                intent.putExtra("lon",item.getLatLonPoint().getLongitude());
                intent.putExtra("name",item.getTitle());

                if(item.getSnippet().isEmpty())
                {
                    intent.putExtra("address",item.getProvinceName() + item.getCityName() + item.getAdName());
                }
                else {
                    intent.putExtra("address",item.getCityName() + item.getSnippet());
                }

                setResult(0,intent);
                finish();
            }
            else
            {
               Toast toast = Toast.makeText(this,"未能获取位置信息",Toast.LENGTH_SHORT);
               toast.setGravity(Gravity.CENTER,0,0);
               toast.show();
            }

        }
        else if(id == R.id.back_button)
        {
            setResult(1,new Intent());
            finish();
        }
        else if(id == R.id.go_my) //回到我的位置
        {
            if(firstLocation != null)
            {
                mMapView.getMap().animateCamera(CameraUpdateFactory.changeLatLng(new LatLng(firstLocation.getLatitude(),firstLocation.getLongitude())));
            }
        }
        else if(id == R.id.search_button)
        {
            Intent intent = new Intent(this,WorksAMapSearchPOIActivity.class);
            intent.putExtra("barColor",barColor);
            intent.putExtra("titleColor",titleColor);
            startActivityForResult(intent,12);
        }
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if(resultCode == 2 && data != null)
        {

            double lat = data.getDoubleExtra("lat",-1000);
            double lon = data.getDoubleExtra("lon",-1000);

            if(lat < -180 || lon < -180)
            {
                return;
            }

            mMapView.getMap().animateCamera(CameraUpdateFactory.changeLatLng(new LatLng(lat,lon)));


        }
    }

    private class POIViewHolder extends RecyclerView.ViewHolder
    {
        private TextView title,subTitle;
        private ImageView selectIcon;

        public POIViewHolder(@NonNull View itemView) {
            super(itemView);
            title = itemView.findViewById(R.id.location_title);
            subTitle = itemView.findViewById(R.id.location_subtitle);
            selectIcon = itemView.findViewById(R.id.select_icon);
        }


        public void setHolderWithPOIItem(PoiItem item,boolean isSelect)
        {
            title.setText(item.getTitle());
            if(item.getSnippet().isEmpty())
            {
                subTitle.setText(item.getProvinceName() + item.getCityName() + item.getAdName());
            }
            else {
                subTitle.setText(item.getCityName() + item.getSnippet());
            }
            selectIcon.setVisibility(isSelect ? View.VISIBLE : View.INVISIBLE);
        }

    }

    private  class AddressAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>
    {

        private ArrayList<PoiItem> poiList;

        private int currentIndex;  //当前选中的序号

        public AddressAdapter() {
            currentIndex = -1;
        }

        public void setAdapterData(ArrayList<PoiItem> list,int index)
        {
            poiList = list;
            currentIndex = index;
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {

            View itemView = getLayoutInflater().inflate(R.layout.poi_cell, parent, false);

            return new POIViewHolder(itemView);
        }

        @Override
        public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, final int position) {
            ((POIViewHolder) holder).setHolderWithPOIItem(poiList.get(position),position == currentIndex);

            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    if(currentIndex != position)
                    {
                        LatLng latLng = new LatLng(poiList.get(position).getLatLonPoint().getLatitude(),poiList.get(position).getLatLonPoint().getLongitude());

                        currentIndex = position;
                        notifyDataSetChanged();

                        isFromClick = true;

                        if(position != 0)
                        {
                            MarkerOptions markerOption = new MarkerOptions();
                            markerOption.position(latLng);
                            markerOption.draggable(false);//设置Marker可拖动
                            markerOption.icon(BitmapDescriptorFactory.fromBitmap(BitmapFactory
                                    .decodeResource(getResources(),R.drawable.myposition3)));
                            // 将Marker设置为贴地显示，可以双指下拉地图查看效果
                            markerOption.setFlat(true);//设置marker平贴地图效果
                            markerOption.anchor(0.5f,0.5f);

                            if(selectedMarker == null)
                            {
                                selectedMarker = mMapView.getMap().addMarker(markerOption);
                            }
                            else
                            {
                                selectedMarker.setVisible(true);
                                selectedMarker.setMarkerOptions(markerOption);
                            }
                        }
                        else if(selectedMarker != null)
                        {
                            selectedMarker.setVisible(false);
                        }

                        mMapView.getMap().animateCamera(CameraUpdateFactory.changeLatLng(latLng));

                    }
                }
            });

        }


        @Override
        public int getItemCount() {
            return poiList !=null ? poiList.size():0;
        }
    }

}
