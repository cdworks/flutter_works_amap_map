package com.works.works_amap_map;

import android.animation.ObjectAnimator;
import android.annotation.TargetApi;
import android.content.Intent;
import android.graphics.BitmapFactory;
import android.graphics.Rect;
import android.os.Build;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
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
import com.amap.api.maps.AMap;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.MapView;
import com.amap.api.maps.model.*;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.core.PoiItem;
import com.amap.api.services.poisearch.PoiResult;
import com.amap.api.services.poisearch.PoiSearch;
import com.scwang.smartrefresh.layout.api.RefreshLayout;
import com.scwang.smartrefresh.layout.constant.SpinnerStyle;
import com.scwang.smartrefresh.layout.footer.BallPulseFooter;
import com.scwang.smartrefresh.layout.footer.ClassicsFooter;
import com.scwang.smartrefresh.layout.listener.OnLoadMoreListener;
import com.scwang.smartrefresh.layout.listener.OnRefreshListener;

import java.util.ArrayList;

public class WorksAMapSearchPOIActivity extends FragmentActivity {

    private RecyclerView recyclerView;

    private SearchView searchView;

    private PoiSearch poiSearch;

    private RefreshLayout refreshLayout;

    private ActivityIndicatorView indicatorView;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        int barColor = getIntent().getIntExtra("barColor",0);
        int titleColor = getIntent().getIntExtra("titleColor",0xffffff);
        setContentView(R.layout.works_amap_search_poi_activity);//设置对应的XML布局文件

        searchView = findViewById(R.id.searchView);
        recyclerView = findViewById(R.id.recycle_view);
        indicatorView = findViewById(R.id.indicator);

        indicatorView.setVisibility(View.GONE);
        searchView = findViewById(R.id.searchView);

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

        AMapUtil.transparentStatusBar(this,barColor);

        ImageButton backBtn = findViewById(R.id.back_button);
        TextView titleTextView = findViewById(R.id.title);
        backBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                finish();
            }
        });
        titleTextView.setTextColor(titleColor);
        backBtn.setColorFilter(titleColor);
        findViewById(R.id.title_bar).setBackgroundColor(barColor);
        searchView.setIconified(false);
        searchView.setQueryHint("请输入地址");
        searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
                                              // 当点击搜索按钮时触发该方法
                                              @Override
                                              public boolean onQueryTextSubmit(String query) {
                                                  return false;
                                              }

                                              // 当搜索内容改变时触发该方法
                                              @Override
                                              public boolean onQueryTextChange(String newText) {
                                                  if (!TextUtils.isEmpty(newText)){
                                                      indicatorView.setVisibility(View.VISIBLE);
                                                      PoiSearch.Query query = poiSearch.getQuery();

                                                      PoiSearch.Query poiQuery = new PoiSearch.Query(newText,"","");
                                                      poiQuery.setPageNum(1);
                                                      poiQuery.setPageSize(query.getPageSize());

                                                      poiSearch.setQuery(poiQuery);
                                                      poiSearch.searchPOIAsyn();

                                                  }else{
                                                      ((AddressAdapter)recyclerView.getAdapter()).poiList.clear();
                                                      recyclerView.getAdapter().notifyDataSetChanged();
                                                  }
                                                  return false;
                                              }
                                          });

        PoiSearch.Query poiQuery = new PoiSearch.Query("","","");
        poiQuery.setPageSize(20);
        poiQuery.setPageNum(1);
        poiSearch = new PoiSearch(this,poiQuery);
        poiSearch.setOnPoiSearchListener(new PoiSearch.OnPoiSearchListener() {
            @Override
            public void onPoiSearched(PoiResult poiResult, int errorCode) {
                indicatorView.setVisibility(View.GONE);

                refreshLayout.finishLoadMore(true);

                if(errorCode == 1000)
                {

                    int num = poiResult.getQuery().getPageNum();
                    if(num ==1)
                    {
                        ((AddressAdapter)recyclerView.getAdapter()).poiList.clear();
                        if(poiResult.getPageCount() > 1)
                        {
                            Log.d("amap","truexxxx");
                            refreshLayout.setEnableLoadMore(true);
                        }
                        else
                        {
                            refreshLayout.setEnableLoadMore(false);
                            Log.d("amap","false...");
                        }
                    }
                    else
                    {
                        refreshLayout.setEnableLoadMore(poiResult.getPageCount() > num);

                    }

                    if(poiResult.getPois().size() > 0)
                    {
                        ((AddressAdapter)recyclerView.getAdapter()).poiList.addAll(poiResult.getPois());
                    }
                    else
                    {
                        refreshLayout.setEnableLoadMore(false);
                    }

                    recyclerView.getAdapter().notifyDataSetChanged();

                    Log.d("amap","total:" + poiResult.getPageCount() + " num:" + num);
                }
                else
                {
                    refreshLayout.finishLoadMore(false);//传入false表示加载失败

                    Toast.makeText(WorksAMapSearchPOIActivity.this,"查询错误！",Toast.LENGTH_SHORT).show();
                }
            }

            @Override
            public void onPoiItemSearched(com.amap.api.services.core.PoiItem poiItem, int i) {

            }
        });

        refreshLayout = findViewById(R.id.refreshLayout);
        refreshLayout.setEnableRefresh(false);

        refreshLayout.setRefreshFooter(new ClassicsFooter(this));
//        refreshLayout.setEnableAutoLoadMore(false);
        refreshLayout.setEnableLoadMore(false);
//        refreshLayout.setOnRefreshListener(new OnRefreshListener() {
//            @Override
//            public void onRefresh(RefreshLayout refreshlayout) {
//                refreshlayout.finishRefresh(2000/*,false*/);//传入false表示刷新失败
//            }
//        });
        refreshLayout.setOnLoadMoreListener(new OnLoadMoreListener() {
            @Override
            public void onLoadMore(RefreshLayout refreshlayout) {


                PoiSearch.Query query = poiSearch.getQuery();

                PoiSearch.Query poiQuery = new PoiSearch.Query(query.getQueryString(),"","");
                poiQuery.setPageNum(query.getPageNum() + 1);
                poiQuery.setPageSize(query.getPageSize());

                poiSearch.setQuery(poiQuery);
                poiSearch.searchPOIAsyn();
            }
        });
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


        public void setHolderWithPOIItem(PoiItem item)
        {
            title.setText(item.getTitle());
            if(item.getSnippet().isEmpty())
            {
                subTitle.setText(item.getProvinceName() + item.getCityName() + item.getAdName());
            }
            else {
                subTitle.setText(item.getCityName() + item.getSnippet());
            }
            selectIcon.setVisibility(View.GONE);
        }

    }

    private  class AddressAdapter extends RecyclerView.Adapter<RecyclerView.ViewHolder>
    {

        ArrayList<PoiItem> poiList = new ArrayList<>();

        @NonNull
        @Override
        public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {

            View itemView = getLayoutInflater().inflate(R.layout.poi_cell, parent, false);

            return new POIViewHolder(itemView);
        }

        @Override
        public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, final int position) {
            ((POIViewHolder) holder).setHolderWithPOIItem(poiList.get(position));


            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view) {
                    setResult(2,new Intent().putExtra("lat",poiList.get(position).getLatLonPoint().getLatitude()).putExtra("lon",poiList.get(position).getLatLonPoint().getLongitude()));
                    finish();
                }
            });

        }


        @Override
        public int getItemCount() {
            return  poiList.size();
        }
    }

//    @Override
//    public void finish() {
//        super.finish();
//        //注释掉activity本身的过渡动画
//        overridePendingTransition(R.anim.slide_in_from_left, R.anim.slide_out_to_right);
//    }
}
