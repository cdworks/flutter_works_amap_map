//
//  WorksAMapLocationViewController.m
//  Pods-Runner
//
//  Created by 李平 on 2020/2/24.
//

#import "WorksAMapLocationViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "POIItemCell.h"
#import "WorksAMapSearchPOIViewController.h"

@interface WorksAMapLocationViewController ()<UITableViewDelegate,UITableViewDataSource,MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate>

@property(nonatomic,weak)IBOutlet MAMapView* mapView;

@property(nonatomic,weak)IBOutlet UITableView* tableView;

@property(nonatomic,weak)IBOutlet UIButton* goMyPostionButton;
@property(nonatomic,weak)IBOutlet UIButton* scaleAddButton;
@property(nonatomic,weak)IBOutlet UIButton* scaleSubButton;

@property(nonatomic,weak)IBOutlet UILabel* localTipsLabel;

@property(nonatomic,weak)IBOutlet UIActivityIndicatorView* indicatorView;

@property(nonatomic,weak)IBOutlet UIView* pinView;  //别针

@property(nonatomic)UIStatusBarStyle statusBarStyle;

@property(nonatomic)BOOL isChangeBarStyle;

@property(nonatomic,strong)AMapLocationManager* locationManager;

@property(nonatomic,strong) CLLocation* firstLocation;

@property(nonatomic,strong)AMapSearchAPI* searchApi;

@property(nonatomic,strong)AMapPOIAroundSearchRequest* researchRequest;

@property(nonatomic,strong)NSArray<AMapPOI *> *poisDta;

@property(nonatomic,strong)MAPointAnnotation *selPointAnnotation;

@property(nonatomic)BOOL isGoMyPostion;


@end

@implementation WorksAMapLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _mapView.delegate = self;
    
    
    
    _indicatorView.hidesWhenStopped = YES;
        
    
    _tableView.backgroundColor = [UIColor whiteColor];
    
//    _tableView.separatorColor = [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
//
//    _tableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 16);
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [_tableView setTableFooterView:view];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
    
    self.navigationItem.leftBarButtonItem.tintColor = _titleColor ?_titleColor: [UIColor blackColor];
    
    [self.navigationController.navigationBar setBarTintColor:_barColor ?_barColor: [UIColor whiteColor]];
    
    [self.navigationController.navigationBar setTintColor:_titleColor ?_titleColor: [UIColor blackColor]];
    
     [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : _titleColor ?_titleColor: [UIColor blackColor]}];
    
    self.navigationItem.title = @"获取位置";
    
    UIBarButtonItem* sureBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(finish)];
    sureBtn.tintColor = _titleColor ?_titleColor: [UIColor blackColor];
    
    UIBarButtonItem* searchBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"sousuo"] style:UIBarButtonItemStylePlain target:self action:@selector(toSearch)];
    searchBtn.tintColor = _titleColor ?_titleColor: [UIColor blackColor];
    

    self.navigationItem.rightBarButtonItems = @[sureBtn,searchBtn];
    
    
    
    
    
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

-(AMapSearchAPI*)searchApi
{
    if(!_searchApi)
    {
        _searchApi = [[AMapSearchAPI alloc] init];
        _searchApi.delegate = self;
        
        
    }
    return _searchApi;
}

-(AMapPOIAroundSearchRequest*)researchRequest
{
    if(!_researchRequest)
    {
        _researchRequest = [[AMapPOIAroundSearchRequest alloc] init];
        _researchRequest.radius = 3000;
        _researchRequest.page = 1;
        _researchRequest.offset = 20;
    }
    return _researchRequest;
}

- (MAPointAnnotation *)selPointAnnotation
{
    if(!_selPointAnnotation)
    {
        _selPointAnnotation = [[MAPointAnnotation alloc] init];
        _selPointAnnotation.title = @"location";
    }
    return _selPointAnnotation;
}

-(void)initMapView
{
//    _mapView.showsUserLocation = ;
//    _mapView.userTrackingMode = MAUserTrackingModeNone;
    
    _mapView.showsCompass = NO;
    [_mapView setZoomLevel:15.5];
    _mapView.showsWorldMap = @(YES);
    _mapView.rotateEnabled = NO;
    
    self.locationManager = [[AMapLocationManager alloc] init];

    [self.locationManager setDelegate:self];
    
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //   定位超时时间，最低2s，此处设置为2s
    self.locationManager.locationTimeout =2;
    //   逆地理请求超时时间，最低2s，此处设置为2s
    self.locationManager.reGeocodeTimeout = 2;
    
    [self.locationManager startUpdatingLocation];

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
    if(_firstLocation)
    {
        if([_mapView.annotations containsObject:self.selPointAnnotation])
        {
            [_mapView removeAnnotation:self.selPointAnnotation];
        }
        _isGoMyPostion = YES;
        [_mapView setCenterCoordinate:_firstLocation.coordinate animated:YES];
        
        
        
    }
}

-(void)toSearch
{
    WorksAMapSearchPOIViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"WorksAMapSearchPOIViewController"];
    
    controller.barColor = _barColor;
    controller.titleColor = _titleColor;
    controller.didSelectPOI = ^(CGFloat lat, CGFloat lon) {
        if(lat < -180 || lon < -180)
        {
            return;
        }
        self->_isGoMyPostion = YES;
        [self->_mapView setCenterCoordinate:CLLocationCoordinate2DMake(lat, lon) animated:YES];
    };
    
    [self.navigationController pushViewController:controller animated:YES];
}

-(void)finish
{
    if(_result)
    {
        NSDictionary* dic = nil;
        if(_poisDta.count)
        {
            NSIndexPath* indexPath = _tableView.indexPathForSelectedRow;
            if(indexPath && indexPath.row < _poisDta.count)
            {
                AMapPOI* poi = _poisDta[indexPath.row];
                NSString* address;
                if(poi.address.length)
                {
        
                    address = [NSString stringWithFormat:@"%@%@",poi.city,poi.address];
                }
                else
                {
                    address = @"";
                }
                dic = @{@"lat":@(poi.location.latitude),@"lon":@(poi.location.longitude),@"address":[NSString stringWithFormat:@"%@<-?->%@",poi.name,address]};
            }
        }
        
        self.result(dic);
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(CGFloat)computeLuminance:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return 0.2126 * red + 0.7152 * green + 0.0722 * blue;
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
            
            if([self computeLuminance:red green:green blue:blue] < 0.179) //dark
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

-(void)setMyLocation
{
    _isGoMyPostion = NO;
    [_mapView setCenterCoordinate:_firstLocation.coordinate animated:YES];
    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = _firstLocation.coordinate;

    [_mapView addAnnotation:pointAnnotation];
    
    [_indicatorView startAnimating];
    self.researchRequest.location = [AMapGeoPoint locationWithLatitude:_firstLocation.coordinate.latitude longitude:_firstLocation.coordinate.longitude];
    [self.searchApi AMapPOIAroundSearch:self.researchRequest];
    
}

#pragma mark - UITableViewDelegate

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _poisDta.count;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    AMapPOI* poi = _poisDta[indexPath.row];
    
    POIItemCell* cell = [tableView dequeueReusableCellWithIdentifier:@"POIItemCell" forIndexPath:indexPath];
    cell.titleLabel.text = poi.name;
    if(poi.address.length)
    {
        cell.addressLabel.text = [NSString stringWithFormat:@"%@%@",poi.city,poi.address];
    }
    else
    {
        cell.addressLabel.text = @"";
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapPOI* poi = _poisDta[indexPath.row];
    
    
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
    
    _isGoMyPostion = NO;
    
    [_mapView setCenterCoordinate:coordinate animated:YES];
    
    BOOL isAdd = [_mapView.annotations containsObject:self.selPointAnnotation];
    
    
    
    if(indexPath.row == 0)
    {
        if(isAdd)
        {
            [_mapView removeAnnotation:self.selPointAnnotation];
        }
    }
    else
    {
        self.selPointAnnotation.coordinate = coordinate;
        
        if(![_mapView.annotations containsObject:self.selPointAnnotation])
        {
            [_mapView addAnnotation:self.selPointAnnotation];
        }
    }
    
    
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}


#pragma mark - AMapLocationManagerDelegate

- (void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager*)locationManager
{
    [locationManager requestAlwaysAuthorization];
}

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
//    _localTipsLabel.text = @"定位失败!";
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        <#code to be executed after a specified delay#>
//    });
    _localTipsLabel.hidden = YES;
    
    NSLog(@"location didFailWithError:%@",error.localizedDescription);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    
    if(!_firstLocation)
    {
        _localTipsLabel.hidden = YES;
        _firstLocation = location;
        [self setMyLocation];
    }
    
    [self.locationManager stopUpdatingLocation];
    
}


- (void)amapLocationManager:(AMapLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse)
       {
           if(!_firstLocation)
           {
               _localTipsLabel.hidden = NO;
               [self.locationManager startUpdatingLocation];
           }
       }
        
}

#pragma mark - amapsearch
/* POI 搜索回调. */
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    [_indicatorView stopAnimating];
    if (response.pois.count == 0)
    {
        return;
    }
    
    _poisDta = response.pois;
    
    [self.tableView reloadData];
     [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    //解析response获取POI信息，具体解析见 Demo
}



- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    [_indicatorView stopAnimating];
    NSLog(@"search error:%@",error.localizedDescription);
}

#pragma mark - MAMapViewDelegate

- (void)mapViewRequireLocationAuth:(CLLocationManager *)locationManager
{
    [locationManager requestAlwaysAuthorization];
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
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
        
        if([annotation.title isEqualToString:@"location"])
        {
            annotationView.image = [UIImage imageNamed:@"location_select_pot"];
        }
        else
        {
            annotationView.image = [UIImage imageNamed:@"myposition"];
        }
        
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction
{
    if(wasUserAction || _isGoMyPostion)
    {
        CGPoint pt = _pinView.layer.position;
        
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.duration = 0.3;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSValue valueWithCGPoint:pt];
        animation.removedOnCompletion = YES;
        animation.autoreverses = true;
         
        
        animation.toValue = [NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y - 40)];
        [_pinView.layer addAnimation:animation forKey:nil];
        
        [_indicatorView startAnimating];
        
        
        _poisDta = nil;
        
        [self.tableView reloadData];
        
        [self.searchApi cancelAllRequests];
        
        self.researchRequest.location = [AMapGeoPoint locationWithLatitude:mapView.centerCoordinate.latitude longitude:mapView.centerCoordinate.longitude];
        [self.searchApi AMapPOIAroundSearch:self.researchRequest];
        
        
        if([_mapView.annotations containsObject:self.selPointAnnotation])
        {
            [_mapView removeAnnotation:self.selPointAnnotation];
        }
        
    }
}

-(void)close
{
      
    if(!_result)
    {
        self.result(nil);
    }
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
