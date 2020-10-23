//
//  HDPersonalHomeCell2.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/25.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDPersonalHomeCell2.h"

#import <SDCycleScrollView.h>

@interface HDPersonalHomeCell2 ()<SDCycleScrollViewDelegate>

@property (nonatomic,strong) SDCycleScrollView *bannerSCrollView;

@end

@implementation HDPersonalHomeCell2

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.bannerSCrollView];
    }
    return self;
}

-(SDCycleScrollView *)bannerSCrollView{
    if (!_bannerSCrollView) {
        NSArray *imageNames = @[];
        SDCycleScrollView *cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(16, 0, kSCREEN_WIDTH-32, 72) shouldInfiniteLoop:YES imageNamesGroup:imageNames];
        cycleScrollView.delegate = self;
        cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFill;
        cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleClassic;
        [self.contentView addSubview:cycleScrollView];
        cycleScrollView.layer.cornerRadius = 4;
        cycleScrollView.layer.masksToBounds = YES;
        
        _bannerSCrollView = cycleScrollView;
    }
    return _bannerSCrollView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
