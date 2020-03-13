//
//  WorksAMapLocationViewController.h
//  Pods-Runner
//
//  Created by 李平 on 2020/2/24.
//

#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface WorksAMapLocationViewController : UIViewController

@property(nonatomic,strong)UIColor* barColor;
@property(nonatomic,strong)UIColor* titleColor;

@property(nonatomic,copy)FlutterResult result;

@end

NS_ASSUME_NONNULL_END
