//
//  WorksAMapViewController.h
//  MJRefresh
//
//  Created by 李平 on 2020/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WorksAMapViewController : UIViewController

@property(nonatomic,strong)UIColor* barColor;
@property(nonatomic,strong)UIColor* titleColor;
@property(nonatomic)CGFloat lat;
@property(nonatomic)CGFloat lon;
@property(nonatomic,strong)NSString* name;
@property(nonatomic,strong)NSString* address;


@end

NS_ASSUME_NONNULL_END
