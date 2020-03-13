//
//  POIItemCell.h
//  Pods-Runner
//
//  Created by 李平 on 2020/2/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface POIItemCell : UITableViewCell

@property(nonatomic,weak)IBOutlet UILabel* titleLabel;
@property(nonatomic,weak)IBOutlet UILabel* addressLabel;
@property(nonatomic,weak)IBOutlet UIImageView* selectIcon;

@end

NS_ASSUME_NONNULL_END
