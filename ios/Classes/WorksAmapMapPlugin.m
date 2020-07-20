#import "WorksAmapMapPlugin.h"
#import "WorksAMapLocationViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "WorksAMapViewController.h"
#import <AMapLocationKit/AMapLocationKit.h>

@interface WorksAmapMapPlugin()

@property(nonatomic,strong) FlutterMethodCall* methodCall;
@property(nonatomic,strong) FlutterResult result;

@property(nonatomic,weak)FlutterViewController* controller;

@property(nonatomic,strong)AMapLocationManager* amapLocation;

@end

@implementation WorksAmapMapPlugin


-(AMapLocationManager*)amapLocation
{
    if(!_amapLocation)
    {
        _amapLocation = [[AMapLocationManager alloc] init];
        [_amapLocation setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    }
    
    return _amapLocation;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"works_amap_map"
            binaryMessenger:[registrar messenger]];
  WorksAmapMapPlugin* instance = [[WorksAmapMapPlugin alloc] init];
    instance.controller = (FlutterViewController*) (FlutterViewController*)UIApplication.sharedApplication.delegate.window.rootViewController;
  [registrar addMethodCallDelegate:instance channel:channel];
    //AMAPKEY
    
    NSDictionary *infoDicNew = [NSBundle mainBundle].infoDictionary;
    NSString* amapKey = infoDicNew[@"AMapkey"];
    if(amapKey)
    {
        [AMapServices sharedServices].apiKey = amapKey;
    }
    
    // Do any additional setup after loading the view.
    [AMapServices sharedServices].enableHTTPS = YES;
    
    
}

//#define UIColorFromRGBA(rgbaValue) [UIColor colorWithRed:((float)((rgbaValue & 0xFF000000) >> 24))/255.0 green:((float)((rgbaValue & 0xFF0000) >> 16))/255.0 blue:((float)((rgbaValue & 0xFF00) >> 8))/255.0 alpha:((float)(rgbaValue & 0xFF))/255.0]

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
//    _methodCall = call;
//    _result = result;
  if ([@"showLocationMap" isEqualToString:call.method]) {
      
      NSDictionary* info = call.arguments;
      
      NSNumber* barColor = info[@"barColor"];
      NSNumber* titleColor = info[@"titleColor"];
      
      
       WorksAMapLocationViewController* controller = [[UIStoryboard storyboardWithName:@"WorksAmap" bundle:nil] instantiateViewControllerWithIdentifier:@"WorksAMapLocationViewController"];
      
      controller.result = result;
      
      
      if(barColor)
      {
          NSInteger colorInt = barColor.integerValue;
          controller.barColor = [UIColor colorWithRed:((float)((colorInt & 0x00FF0000) >> 16))/255.0 green:((float)((colorInt & 0x0000FF00) >> 8))/255.0 blue:((float)(colorInt & 0x000000FF))/255.0 alpha:((float)((colorInt & 0xFF000000) >> 24))/255.0];
      }
      
      if(titleColor)
      {
          NSInteger colorInt = titleColor.integerValue;
          controller.titleColor = [UIColor colorWithRed:((float)((colorInt & 0x00FF0000) >> 16))/255.0 green:((float)((colorInt & 0x0000FF00) >> 8))/255.0 blue:((float)(colorInt & 0x000000FF))/255.0 alpha:((float)((colorInt & 0xFF000000) >> 24))/255.0];
      }
      
      UINavigationController* navi =[[UINavigationController alloc] initWithRootViewController:controller];
      
//      [navi.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
      [navi.navigationBar setShadowImage:[UIImage new]];

      
      [navi setModalPresentationStyle:UIModalPresentationFullScreen];
      
      

     [_controller presentViewController:navi animated:YES completion:nil];
      
  }else if([@"showPotMap" isEqualToString:call.method]) {
      
    NSDictionary* info = call.arguments;
      
      NSNumber* barColor = info[@"barColor"];
      NSNumber* titleColor = info[@"titleColor"];
      
      NSDictionary* locationInfo = info[@"location"];
      
      
    NSNumber* lat = locationInfo[@"lat"];
    NSNumber* lon = locationInfo[@"lon"];
      
      NSString* name = locationInfo[@"name"];
     NSString* address = locationInfo[@"address"];
      
      WorksAMapViewController* controller = [[UIStoryboard storyboardWithName:@"WorksAmap" bundle:nil] instantiateViewControllerWithIdentifier:@"WorksAMapViewController"];
      
      controller.lat = lat.floatValue;
      controller.lon = lon.floatValue;
      controller.name = name;
      controller.address = address;
      
      if(barColor)
      {
          NSInteger colorInt = barColor.integerValue;
          controller.barColor = [UIColor colorWithRed:((float)((colorInt & 0x00FF0000) >> 16))/255.0 green:((float)((colorInt & 0x0000FF00) >> 8))/255.0 blue:((float)(colorInt & 0x000000FF))/255.0 alpha:((float)((colorInt & 0xFF000000) >> 24))/255.0];
      }
      
      if(titleColor)
      {
          NSInteger colorInt = titleColor.integerValue;
          controller.titleColor = [UIColor colorWithRed:((float)((colorInt & 0x00FF0000) >> 16))/255.0 green:((float)((colorInt & 0x0000FF00) >> 8))/255.0 blue:((float)(colorInt & 0x000000FF))/255.0 alpha:((float)((colorInt & 0xFF000000) >> 24))/255.0];
      }
      
      UINavigationController* navi =[[UINavigationController alloc] initWithRootViewController:controller];
      
      [navi.navigationBar setShadowImage:[UIImage new]];
      
      
      [navi setModalPresentationStyle:UIModalPresentationFullScreen];
      
      [_controller presentViewController:navi animated:YES completion:nil];
      
      result(nil);

      
  }
  else if([@"startLocationOnce" isEqualToString:call.method])
  {
//      __weak typeof(self) weakSelf = self;
      [self.amapLocation requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
//          if (!weakSelf) {
//              result(@{@"code":[NSNumber numberWithInteger:code],@"msg":msg});
//              return;
//          }
          if (!error && location) {
              NSString* address = @"";
              if(regeocode && regeocode.formattedAddress.length)
              {
                  address = regeocode.formattedAddress;
              }
              result(@{@"code":[NSNumber numberWithInteger:0],
                       @"msg":@"",
                       @"lat":[NSNumber numberWithDouble:location.coordinate.latitude],
                       @"lon":[NSNumber numberWithDouble:location.coordinate.longitude],
                       @"district":regeocode.district ? regeocode.district:@"",
                       @"province":regeocode.province ? regeocode.province:@"",
                       @"city":regeocode.city ? regeocode.city:@"",
                       
                       @"address":address
              });
          }
          else
          {
              NSInteger code = error ? error.code : -2;
              NSString* msg = error ? error.localizedDescription : @"获取定位失败!";
              result(@{@"code":[NSNumber numberWithInteger:code],@"msg":msg});
          }
      }];
  }
  else {
    result(FlutterMethodNotImplemented);
//      _methodCall = nil;
//      _result = nil;
  }
}

@end
