//
//  WorksAMapSearchPOIViewController.h
//  Pods-Runner
//
//  Created by 李平 on 2020/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface WorksAMapSearchPOIViewController : UIViewController

@property(nonatomic,strong)UIColor* barColor;
@property(nonatomic,strong)UIColor* titleColor;

@property(nonatomic,copy)void (^didSelectPOI)(CGFloat lat,CGFloat lon);

@end

NS_ASSUME_NONNULL_END
