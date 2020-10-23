//
//  TiRefreshView.m
//  RefreshTest
//
//  Created by CtreeOne on 15/11/18.
//  Copyright © 2015年 tion126. All rights reserved.
//

#import "TiRefreshView.h"
#import <ImageIO/ImageIO.h>

@interface TiRefreshView()

@property (nonatomic, strong) UILabel *stateLab;
@property(nonatomic,strong) UIImageView *refreshImageView;
@property(nonatomic,strong) NSMutableArray *gifImages;

@end

@implementation TiRefreshView

-(void)setup{
    
    _stateLab=[[UILabel alloc]init];
    [_stateLab setFont:[UIFont systemFontOfSize:12]];
    [_stateLab setTextColor:[UIColor colorWithRed:120/255.0f green:120/255.0f blue:120/255.0f alpha:1]];
    _stateLab.textAlignment=NSTextAlignmentCenter;
    _stateLab.text=DEFAULT_TITLE;
    _stateLab.frame=CGRectMake(0, self.bounds.size.height-20, SCREEN_WIDTH, 15);
    [self addSubview:_stateLab];
    
    _refreshImageView=[[UIImageView alloc]init];
    _refreshImageView.image=[UIImage imageNamed:@"home_bg"];
    _refreshImageView.frame=CGRectMake(0, 0, SCREEN_WIDTH, self.bounds.size.height-25);
    [self addSubview:_refreshImageView];
    
    self.gifImages=[NSMutableArray array];
    NSString *path=[[NSBundle mainBundle]pathForResource:@"frontpage_refresh@2x" ofType:@"gif"];
    self.gifImages=[self praseGIFDataToImageArray:[NSData dataWithContentsOfFile:path]];
    
    NSAssert(self.gifImages.count!=0, @"gif can be nil");
    
    if (self.gifImages) {
        _refreshImageView.image=self.gifImages[0];
        _refreshImageView.animationImages=self.gifImages;
        _refreshImageView.animationDuration=0.85f;
        _refreshImageView.animationRepeatCount=INTMAX_MAX;
    }
}

- (void)setRefreshState:(RefreshState)state {
    [super setRefreshState:state];

    switch (self.refreshState) {
        case State_normal:
            self.stateLab.text = DEFAULT_TITLE;
            
            if ([_refreshImageView isAnimating]) {
                [_refreshImageView stopAnimating];
            }
            
            int index=(-self.scrollView.contentOffset.y)/13;
            if (index<0) {
                index=0;
            }else if (index>self.gifImages.count-1){
                index=(int)self.gifImages.count-1;
            }
            _refreshImageView.image=self.gifImages[index];
            [self scrollViewContentInsets:self.superEdgeInsets];
            
            break;
        case State_trigger:
            self.stateLab.text = HOLDING_TITLE;
            
            if (!_refreshImageView.isAnimating) {
                [_refreshImageView startAnimating];
            }
            break;
        case State_Loading:
            self.stateLab.text = LOADING_TITLE;
            [self scrollViewContentInsets:UIEdgeInsetsMake(TITLE_HEIGHT+self.scrollView.contentInset.top, 0, 0, 0)];
            self.refreshedHandler();
            break;
        default:
            break;
    }
}

- (void)scrollViewContentInsets:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:.35 animations:^{
        [self.scrollView setContentInset:contentInset];
    }];
}


//gif 转数组、
-(NSMutableArray *)praseGIFDataToImageArray:(NSData *)data;
{
    NSMutableArray *frames = [[NSMutableArray alloc] init];
    CGImageSourceRef src = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    CGFloat animationTime = 0.f;
    if (src) {
        size_t l = CGImageSourceGetCount(src);
        frames = [NSMutableArray arrayWithCapacity:l];
        for (size_t i = 0; i < l; i++) {
            CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
            NSDictionary *properties = (NSDictionary *)CFBridgingRelease(CGImageSourceCopyPropertiesAtIndex(src, i, NULL));
            NSDictionary *frameProperties = [properties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
            NSNumber *delayTime = [frameProperties objectForKey:(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
            animationTime += [delayTime floatValue];
            if (img) {
                [frames addObject:[UIImage imageWithCGImage:img]];
                CGImageRelease(img);
            }
        }
        CFRelease(src);
    }
    return frames;
}



@end
