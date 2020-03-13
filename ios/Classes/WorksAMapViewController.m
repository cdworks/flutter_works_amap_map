//
//  WorksAMapViewController.m
//  MJRefresh
//
//  Created by 李平 on 2020/2/25.
//

#import "WorksAMapViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapNaviKit/AMapNaviKit.h>
#import <MapKit/MapKit.h>

@interface WorksAMapViewController ()<AMapSearchDelegate,MAMapViewDelegate>

@property(nonatomic,weak)IBOutlet MAMapView* mapView;

@property(nonatomic,weak)IBOutlet UIButton* goMyPostionButton;
@property(nonatomic,weak)IBOutlet UIButton* scaleAddButton;
@property(nonatomic,weak)IBOutlet UIButton* scaleSubButton;

@property(nonatomic,weak)IBOutlet UILabel* nameLabel;
@property(nonatomic,weak)IBOutlet UILabel* addressLabel;

@property(nonatomic,strong)AMapSearchAPI* searchApi;

@property(nonatomic,strong)AMapNaviCompositeManager* compositeManager;

@property(nonatomic,strong)AMapNaviCompositeUserConfig* naviConfig;

@property(nonatomic)BOOL isChangeBarStyle;
@property(nonatomic)UIStatusBarStyle statusBarStyle;

@end

@implementation WorksAMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    
    self.navigationItem.leftBarButtonItem.tintColor = _titleColor ?_titleColor: [UIColor blackColor];
    
    [self.navigationController.navigationBar setBarTintColor:_barColor ?_barColor: [UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTintColor:_titleColor ?_titleColor: [UIColor blackColor]];
    
     [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : _titleColor ?_titleColor: [UIColor blackColor]}];
    
    self.navigationItem.title = @"位置信息";
    
    _scaleAddButton.layer.masksToBounds = YES;
    _scaleAddButton.layer.cornerRadius = 2;
    _scaleAddButton.layer.borderWidth = 1;
    _scaleAddButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _scaleSubButton.layer.masksToBounds = YES;
    _scaleSubButton.layer.cornerRadius = 2;
    _scaleSubButton.layer.borderWidth = 1;
    _scaleSubButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    _goMyPostionButton.layer.masksToBounds = YES;
    _goMyPostionButton.layer.cornerRadius = 4;
    _goMyPostionButton.layer.borderWidth = 1;
    _goMyPostionButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    [self initMapView];
    
    
}


-(void)viewDidAppear:(BOOL)animated{

    [super viewDidAppear:animated];
    if(_titleColor)
    {
        CGFloat red;
        CGFloat green;
        CGFloat blue;
        CGFloat alpha;
        
        if( [_titleColor getRed:&red green:&green blue:&blue alpha:&alpha])
        {
            _isChangeBarStyle = YES;
            
            _statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
            
            
            //自适应状态栏文本颜色
            
            if((0.2126 * red + 0.7152 * green + 0.0722 * blue) < 0.179) //dark
            {
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            }
            else
            {
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            }
                
        }
        
    }
    

}

-(void)viewWillDisappear:(BOOL)animated

{
    [super viewWillDisappear:animated];
    if(_isChangeBarStyle)
    {
        [UIApplication sharedApplication].statusBarStyle = _statusBarStyle;
    }

}

-(void)initMapView
{
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    _mapView.delegate = self;
    _mapView.showsCompass = NO;
    [_mapView setZoomLevel:15.5];
    _mapView.showsWorldMap = @(YES);
    _mapView.rotateEnabled = NO;
    
    if(_name && _address)
    {
        _nameLabel.text = _name;
        _addressLabel.text = _address;
    }
    else //逆地址解析
    {
        AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];

        regeo.location = [AMapGeoPoint locationWithLatitude:_lat longitude:_lon];
        regeo.requireExtension            = YES;
        [self.searchApi AMapReGoecodeSearch:regeo];
    }
    
    if(_lat >= -180 && _lon >= -180)
    {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_lat, _lon);
        MAPointAnnotation* pointAnnotation = [[MAPointAnnotation alloc] init];
        pointAnnotation.coordinate = coordinate;
        
        [_mapView addAnnotation:pointAnnotation];
        
        [_mapView setCenterCoordinate:coordinate];
    }
    
}

-(void)close
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(AMapSearchAPI*)searchApi
{
    if(!_searchApi)
    {
        _searchApi = [[AMapSearchAPI alloc] init];
        _searchApi.delegate = self;
        
        
    }
    return _searchApi;
}

-(AMapNaviCompositeManager*)compositeManager
{
    if(!_compositeManager)
    {
        _compositeManager = [[AMapNaviCompositeManager alloc] init];
        
    }
    
    return _compositeManager;
}

-(AMapNaviCompositeUserConfig*)naviConfig
{
    if(!_naviConfig)
    {
        _naviConfig = [[AMapNaviCompositeUserConfig alloc] init];
        
        
        //传入终点，并且带高德POIId
        [_naviConfig setRoutePlanPOIType:AMapNaviRoutePlanPOITypeEnd location:[AMapNaviPoint locationWithLatitude:_lat longitude:_lon] name:_name.length ? _name : nil POIId:nil];
    }
    
    return _naviConfig;
}

#pragma mark - action

-(IBAction)toNavi:(id)sender
{
    
    if(_lat < -180 || _lon < -180)
    {
        return;
    }
    
    UIApplication* application = [UIApplication sharedApplication];
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    __weak typeof(self) weakSelf = self;
    
    UIAlertAction* innerAction = [UIAlertAction actionWithTitle:@"应用内地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf toInnerMap];
    }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:innerAction];
    
    if ([application canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
      UIAlertAction* action = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          [weakSelf toAmapMap];
      }];
        
        [alertController addAction:action];
    }
    
    if ([application canOpenURL:[NSURL URLWithString:@"baidumap://"]]) {
      UIAlertAction* action = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          [weakSelf toBaiduMap];
      }];
        
        [alertController addAction:action];
    }
    
    if ([application canOpenURL:[NSURL URLWithString:@"qqmap://"]]) {
      UIAlertAction* action = [UIAlertAction actionWithTitle:@"腾讯地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          [weakSelf toTencentMap];
      }];
        
        [alertController addAction:action];
    }
    
    
    
    if ([application canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]) {
      UIAlertAction* action = [UIAlertAction actionWithTitle:@"谷歌地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
          [weakSelf toGoogleMap];
      }];
        
        [alertController addAction:action];
    }
    
    UIAlertAction* systemAction = [UIAlertAction actionWithTitle:@"系统地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf toAppleMap];
    }];
    
    [alertController addAction:systemAction];
    
    
    

    [self presentViewController:alertController animated:YES completion:nil];
    
    //
//        [alertController addAction:albumAction];
}

-(void)toInnerMap
{
    if(_lat >= -180 && _lon >= -180)
    {
        MAUserLocation* userLocation = _mapView.userLocation;
        
        
        if(userLocation && userLocation.location)
        {
            [self.naviConfig setRoutePlanPOIType:AMapNaviRoutePlanPOITypeStart location:[AMapNaviPoint locationWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude] name:@"我的位置" POIId:nil];
        }
    
        [self.compositeManager presentRoutePlanViewControllerWithOptions:self.naviConfig];
    }
}

-(void)toAppleMap
{
    CLLocationCoordinate2D loc = CLLocationCoordinate2DMake(_lat, _lon);
    
    //用户位置
    MKMapItem *currentLoc = [MKMapItem mapItemForCurrentLocation];
    //终点位置
    MKMapItem *toLocation = [[MKMapItem alloc]initWithPlacemark:[[MKPlacemark alloc]initWithCoordinate:loc addressDictionary:nil] ];
    
    NSArray *items = @[currentLoc,toLocation];
    //第一个
    NSDictionary *dic = @{
                          MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving,
                          MKLaunchOptionsMapTypeKey : @(MKMapTypeStandard),
                          MKLaunchOptionsShowsTrafficKey : @(YES)
                          };
    //第二个，都可以用
    //    NSDictionary * dic = @{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
    //                           MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]};
    
    [MKMapItem openMapsWithItems:items launchOptions:dic];
}

-(void)toAmapMap
{
    NSString* amapString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=amaptest&dev=0&t=0&dlat=%f&dlon=%f",_lat,_lon];
    
    if(_name.length)
    {
        amapString = [amapString stringByAppendingFormat:@"&dname=%@",_name];
    }
    
    
    MAUserLocation* userLocation = _mapView.userLocation;
    
    
    if(userLocation && userLocation.location)
    {
        amapString = [amapString stringByAppendingFormat:@"&slat=%f&slon=%f&sname=我的位置",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
    }
    
    NSURL* myLocationScheme = [NSURL URLWithString:[amapString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]]];
    
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:myLocationScheme options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
        [[UIApplication sharedApplication] openURL:myLocationScheme];
    }
    

}


-(void)toBaiduMap
{
    NSString* baiduString = [NSString stringWithFormat:@"baidumap://map/direction?mode=driving&coord_type=gcj02&src=%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]];
    
    
    MAUserLocation* userLocation = _mapView.userLocation;
    
    
    if(userLocation && userLocation.location)
    {
        baiduString = [baiduString stringByAppendingFormat:@"&origin=name:我的位置|latlng:%f,%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
    }
    
    if(_name.length)
    {
        baiduString = [baiduString stringByAppendingFormat:@"&destination=name:%@|latlng:%f,%f",_name, _lat,_lon];
    }
    else
    {
        baiduString = [baiduString stringByAppendingFormat:@"&destination=%f,%f",_lat,_lon];
    }
    
    
    
    NSURL* myLocationScheme = [NSURL URLWithString:[baiduString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]]];
    
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:myLocationScheme options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
        [[UIApplication sharedApplication] openURL:myLocationScheme];
    }
    
}

-(void)toTencentMap
{
    NSString* qqString = [NSString stringWithFormat:@"qqmap://map/routeplan?type=drive&referer=OB4BZ-D4W3U-B7VVO-4PJWW-6TKDJ-WPB77&tocoord=%f,%f",_lat,_lon];
    
    if(_name.length)
    {
        qqString = [qqString stringByAppendingFormat:@"&to=%@",_name];
    }
    
    
    MAUserLocation* userLocation = _mapView.userLocation;
    
    
    if(userLocation && userLocation.location)
    {
        qqString = [qqString stringByAppendingFormat:@"&fromcoord=%f,%f&from=我的位置",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
    }
    
    NSURL* myLocationScheme = [NSURL URLWithString:[qqString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet  URLQueryAllowedCharacterSet]]];
    
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:myLocationScheme options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
        [[UIApplication sharedApplication] openURL:myLocationScheme];
    }
}

-(void)toGoogleMap
{
    
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f&directionsmode=driving",_lat,_lon]] options:@{} completionHandler:nil];
    } else {
        // Fallback on earlier versions
        [[UIApplication sharedApplication] openURL:
        [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f&directionsmode=driving",_lat,_lon]]];
    }
    
    
}

-(IBAction)toIncreaseScale:(id)sender
{
//    3-20
    if(_mapView.zoomLevel < 20)
    {
        [_mapView setZoomLevel:MIN(20, _mapView.zoomLevel+1)  animated:YES];
    }
    
}

-(IBAction)toDecreaseScale:(id)sender
{
    if(_mapView.zoomLevel > 3)
    {
        [_mapView setZoomLevel:MAX(3, _mapView.zoomLevel-1)  animated:YES];
    }
}

-(IBAction)toGoMypostion:(id)sender
{
    
    MAUserLocation* userLocation = _mapView.userLocation;
    
    if(userLocation && userLocation.location)
    {
        [_mapView setCenterCoordinate:userLocation.coordinate animated:YES];
    }
}

#pragma mark - amapsearchdelegate

- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    AMapReGeocode* regeocode = response.regeocode;
    if (regeocode != nil)
    {
          if(regeocode.pois.count)
          {
              AMapPOI* poi = regeocode.pois.firstObject;
              
              _name = poi.name;
              _nameLabel.text = _name;
              if(poi.address.length)
              {
                  
                  _address = [NSString stringWithFormat:@"%@%@",poi.city,poi.address];
              }
              else
              {
                  _address = poi.formattedDescription;
              }
              
              _addressLabel.text = _address;
              
          }
        else
        {
             _addressLabel.text = regeocode.formattedAddress;
        }
    }
    else
    {
        _addressLabel.text = @"未能获取地址数据!";
        _addressLabel.textColor = [UIColor redColor];
    }
}

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    _addressLabel.text = @"获取地址数据错误!";
    _addressLabel.textColor = [UIColor redColor];
    NSLog(@"Error: %@", error);
}

#pragma mark - amapdelegate
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
       return nil;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAAnnotationView*annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.draggable = NO;        //设置标注可以拖动，默认为NO
        annotationView.canShowCallout = NO;
        annotationView.enabled = NO;
        annotationView.zIndex = 1;
        
        annotationView.centerOffset = CGPointMake(0, -25);
        
        annotationView.image = [UIImage imageNamed:@"biezhen2"];
        
        return annotationView;
    }
    return nil;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
