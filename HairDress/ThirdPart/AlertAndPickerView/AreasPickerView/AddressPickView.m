//
//  PopupView.m
//  买布易
//
//  Created by 张建 on 15/6/26.
//  Copyright (c) 2015年 张建. All rights reserved.
//

#import "AddressPickView.h"

#define navigationViewHeight 42
#define pickViewViewHeight 200.0f
#define buttonWidth 60.0f

@interface AddressPickView ()

@property(nonatomic,strong)NSArray *provinceArray;
@property(nonatomic,strong)NSArray *cityArray;
@property(nonatomic,strong)NSArray *townArray;
@property(nonatomic,strong)UIView *bottomView;//包括导航视图和地址选择视图
@property(nonatomic,strong)UIPickerView *pickView;//地址选择视图
@property(nonatomic,strong)UIView *navigationView;//上面的导航视图

@end

@implementation AddressPickView

-(instancetype)initWithFrame:(CGRect)frame arrData:(NSArray *)arr
{
    self = [super initWithFrame:frame];
    if (self) {
        self.frame = CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT);
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.provinceArray = arr;
        [self _addTapGestureRecognizerToSelf];
        [self _getPickerData];
        [self _createView];
        [self showBottomView];
    }
    return self;
  
}
#pragma mark - get data
- (void)_getPickerData
{
    if (self.provinceArray.count > 0) {
        self.cityArray = self.provinceArray[0][@"childrenList"];
    }

    if (self.cityArray.count > 0) {
        self.townArray = self.cityArray[0][@"areaList"];
    }

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
//    _bottomView.backgroundColor = RGBMAIN;
    [self addSubview:_bottomView];
    //导航视图
    _navigationView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, navigationViewHeight)];
    _navigationView.backgroundColor = [UIColor whiteColor];
    [_bottomView addSubview:_navigationView];
    //这里添加空手势不然点击navigationView也会隐藏,
    UITapGestureRecognizer *tapNavigationView = [[UITapGestureRecognizer alloc]initWithTarget:self action:nil];
    [_navigationView addGestureRecognizer:tapNavigationView];
    
    UILabel *lblText = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 0, 150, navigationViewHeight) title:@"所在区域" bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:17 textAlignment:NSTextAlignmentCenter isFit:NO];
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
        
        NSDictionary *province = [self.provinceArray objectAtIndex:[_pickView selectedRowInComponent:0]];
        NSDictionary *city = [self.cityArray objectAtIndex:[_pickView selectedRowInComponent:1]];
        NSDictionary *town = [self.townArray objectAtIndex:[_pickView selectedRowInComponent:2]];
        
        if (_addressblock) {
            _addressblock(province,city,town);
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
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return _provinceArray.count;
    } else if (component == 1) {
        return _cityArray.count;
    } else {
        return _townArray.count;
    }
}


-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel *lable=[[UILabel alloc]init];
    lable.textAlignment=NSTextAlignmentCenter;
    lable.font=[UIFont systemFontOfSize:17.0f];
    if (component == 0) {
        lable.text=[self.provinceArray objectAtIndex:row][@"name"];
    } else if (component == 1) {
        lable.text=[self.cityArray objectAtIndex:row][@"name"];
    } else {
        lable.text=[self.townArray objectAtIndex:row][@"name"];
    }
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
    CGFloat pickViewWidth = kSCREEN_WIDTH/3;

    return pickViewWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 42;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        if (self.provinceArray.count > 0) {
            self.cityArray = self.provinceArray[row][@"childrenList"];
        } else {
            self.cityArray = nil;
        }
        if (self.cityArray.count > 0) {
            self.townArray = self.cityArray[0][@"areaList"];
        } else {
            self.townArray = nil;
        }
        [pickerView selectRow:0 inComponent:1 animated:YES];
        [pickerView selectRow:1 inComponent:2 animated:YES];
    }
    [pickerView reloadComponent:1];
    
    if (component == 1) {
        if (self.provinceArray.count > 0 && self.cityArray.count > 0) {
            self.townArray = [self.cityArray objectAtIndex:row][@"areaList"];
        } else {
            self.townArray = nil;
        }
        [pickerView selectRow:1 inComponent:2 animated:YES];
    }
    
    [pickerView reloadComponent:2];
    
  
 
}


@end
