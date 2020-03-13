//
//  POIItemCell.m
//  Pods-Runner
//
//  Created by 李平 on 2020/2/25.
//

#import "POIItemCell.h"


@implementation POIItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    self.selectIcon.hidden = !selected;
    
    // Configure the view for the selected state
}

@end
