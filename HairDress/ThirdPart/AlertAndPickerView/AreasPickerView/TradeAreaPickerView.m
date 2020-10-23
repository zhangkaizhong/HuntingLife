//
//  TradeAreaPickerView.h
//  HairDress
//
//  Created by 张凯中 on 2020/1/5.
//  Copyright © 2020 zhangkaizhong. All rights reserved.
//

#import "TradeAreaPickerView.h"

#define navigationViewHeight 42
#define pickViewViewHeight 200.0f
#define buttonWidth 60.0f

@interface TradeAreaPickerView ()

@property(nonatomic,strong)NSArray *dataArray;
@property(nonatomic,strong)UIView *bottomView;//包括导航视图和地址选择视图
@property(nonatomic,strong)UIPickerView *pickView;//地址选择视图
@property(nonatomic,strong)UIView *navigationView;//上面的导航视图

@end

@implementation TradeAreaPickerView

-(instancetype)initWithFrame:(CGRect)frame arrData:(NSArray *)arr
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.dataArray = arr;
        [self _addTapGestureRecognizerToSelf];
        [self _createView];
        [self showBottomView];
    }
    return self;
}

-(void)_addTapGestureRecognizerToSelf
{
    self.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hiddenBottomView)];
    [self addGestureRecognizer:tap];
}

-(void)_createView
{
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, kSCREEN_HEIGHT, kSCREEN_WIDTH, navigationViewHeight+pickViewViewHeight)];
    [self addSubview:_bottomView];
    //导航视图
    _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, navigationViewHeight)];
    _navigationView.backgroundColor = [UIColor whiteColor];
    [_bottomView addSubview:_navigationView];
    //这里添加空手势不然点击navigationView也会隐藏,
    UITapGestureRecognizer *tapNavigationView = [[UITapGestureRecognizer alloc]initWithTarget:self action:nil];
    [_navigationView addGestureRecognizer:tapNavigationView];
    
    UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, 150, navigationViewHeight) title:@"所在商圈" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:17 textAlignment:NSTextAlignmentCenter isFit:NO];
    lblText.centerX = _navigationView.width/2;
    [_navigationView addSubview:lblText];
    
    NSArray *buttonTitleArray = @[@"取消",@"确定"];
    for (int i = 0; i <buttonTitleArray.count ; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(i*(kSCREEN_WIDTH-buttonWidth), 0, buttonWidth, navigationViewHeight);
        [button setTitle:buttonTitleArray[i] forState:UIControlStateNormal];
        [_navigationView addSubview:button];
        
        button.tag = i;
        [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [button setTitleColor:RGBMAIN forState:UIControlStateNormal];
    }
    _pickView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, navigationViewHeight, kSCREEN_WIDTH, pickViewViewHeight)];
    _pickView.backgroundColor = [UIColor whiteColor];
    _pickView.dataSource = self;
    _pickView.delegate =self;
    [_bottomView addSubview:_pickView];
    
    
}
-(void)tapButton:(UIButton*)button
{
    //点击确定回调block
    if (button.tag == 1) {
        
        NSDictionary *trade = [self.dataArray objectAtIndex:[_pickView selectedRowInComponent:0]];
        
        if (_tradeblock) {
            _tradeblock(trade);
        }
    }
    
    [self hiddenBottomView];
}
-(void)showBottomView
{
    WeakSelf;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.bottomView.top = kSCREEN_HEIGHT-navigationViewHeight-pickViewViewHeight;
    } completion:^(BOOL finished) {

    }];
}
-(void)hiddenBottomView
{
    WeakSelf;
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.bottomView.top = kSCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
    
}


#pragma mark - UIPicker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _dataArray.count;
}


-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *lable=[[UILabel alloc]init];
    lable.textAlignment=NSTextAlignmentCenter;
    lable.font=[UIFont systemFontOfSize:17.0f];
    lable.text=[self.dataArray objectAtIndex:row][@"name"];
    //设置分割线的颜色
    for(UIView *singleLine in pickerView.subviews)
    {
        if (singleLine.frame.size.height < 1)
        {
            singleLine.backgroundColor = RGBCOLOR(241, 241, 241);
        }
    }

    return lable;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    CGFloat pickViewWidth = kSCREEN_WIDTH;

    return pickViewWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 42;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    [pickerView selectRow:0 inComponent:0 animated:YES];

}


@end
