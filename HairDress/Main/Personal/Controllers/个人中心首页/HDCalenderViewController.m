//
//  GGCalenderViewController.m
//  GoGo
//
//  Created by 张凯中 on 2020/4/28.
//  Copyright © 2020 张凯中. All rights reserved.
//

#import "HDCalenderViewController.h"

#import "NSDate+Extension.h"
#import "GGCalendarSubView.h"
#import "HDCalendarInfoModel.h"
#import "CalenderModel.h"
#import "DateTimePickerView.h"

@interface HDCalenderViewController ()<navViewDelegate,DateTimePickerViewDelegate>

@property (nonatomic,strong) HDBaseNavView *navView;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UIView *viewHeader;
@property (nonatomic,strong) UIView *viewYear;
@property (nonatomic,strong) UIView *viewMonths;
@property (nonatomic, weak) UILabel *lblYear;

@property (nonatomic,strong) HDCalendarInfoModel *infoModel;
@property (nonatomic, strong) DateTimePickerView *datePickerView;

@property (nonatomic, copy) NSString *startDay;
@property (nonatomic, copy) NSString *endDay;
@property (nonatomic, copy) NSString *year;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

static NSInteger nextCut = 0;

@implementation HDCalenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.navView];
    
    self.year = [self getYear];
    self.startDay = [NSString stringWithFormat:@"%@-01-01",self.year];
    self.endDay = [NSString stringWithFormat:@"%@-12-31",self.year];
    
    [self getCalendarData];
}

#pragma mark --加载控件
-(HDBaseNavView *)navView{
    if (!_navView) {
        _navView = [[HDBaseNavView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, NAVHIGHT) title:@"剪发日历" bgColor:RGBCOLOR(244, 244, 244) backBtn:YES rightBtn:@"" rightBtnImage:@"" theDelegate:self];
    }
    return _navView;
}

-(UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVHIGHT, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT)];
        _mainScrollView.backgroundColor = [UIColor clearColor];
        
        [_mainScrollView addSubview:self.viewHeader];
        [_mainScrollView addSubview:self.viewYear];
        [self createMonthView];
    }
    return _mainScrollView;
}

-(UIView *)viewHeader{
    if (!_viewHeader) {
        _viewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, 134*SCALE)];
        _viewHeader.layer.backgroundColor = [UIColor colorWithRed:244/255.0 green:244/255.0 blue:244/255.0 alpha:1.0].CGColor;
        _viewHeader.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.12].CGColor;
        _viewHeader.layer.shadowOffset = CGSizeMake(0,1);
        _viewHeader.layer.shadowOpacity = 1;
        _viewHeader.layer.shadowRadius = 6;
        
        UIImageView *imageHead = [[UIImageView alloc] initWithFrame:CGRectMake(16*SCALE, 0, 54*SCALE, 54*SCALE)];
        [imageHead sd_setImageWithURL:[NSURL URLWithString:self.infoModel.headImg] placeholderImage:[UIImage imageNamed:@"personal_default"]];
        imageHead.contentMode = 2;
        imageHead.layer.cornerRadius = 54*SCALE/2;
        imageHead.layer.masksToBounds = YES;
        [_viewHeader addSubview:imageHead];
        
        UILabel *lblName = [[UILabel alloc] initCommonWithFrame:CGRectMake(CGRectGetMaxX(imageHead.frame)+12*SCALE, 0, kSCREEN_WIDTH-CGRectGetMaxX(imageHead.frame)-12*SCALE-16*SCALE, 22*SCALE) title:self.infoModel.userName bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:16*SCALE textAlignment:NSTextAlignmentLeft isFit:NO];
        lblName.numberOfLines = 0;
        [lblName sizeToFit];
        lblName.centerY = imageHead.centerY;
        [_viewHeader addSubview:lblName];
        
        NSArray *arr = @[@{@"title":@"相识时间",@"content":[NSString stringWithFormat:@"%@天",self.infoModel.createLongTime]},@{@"title":@"服务发型师",@"content":[NSString stringWithFormat:@"%@位",self.infoModel.serviceTonyNum]},@{@"title":@"服务次数",@"content":[NSString stringWithFormat:@"%@次",self.infoModel.serviceNum]}];
        for (int i=0; i<arr.count; i++) {
            UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(i*_viewHeader.width/3, imageHead.bottom, _viewHeader.width/arr.count, _viewHeader.height-imageHead.bottom)];
            [_viewHeader addSubview:subView];
            subView.tag = 100+i;
            
            UILabel *lblTitle = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, 22*SCALE, subView.width, 12*SCALE) title:arr[i][@"title"] bgColor:[UIColor clearColor] titleColor:RGBCOLOR(135, 135, 137) titleFont:12*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
            [subView addSubview:lblTitle];
            UILabel *lblcontent = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, lblTitle.bottom+13*SCALE, subView.width, 14*SCALE) title:arr[i][@"content"] bgColor:[UIColor clearColor] titleColor:RGBTEXT titleFont:14*SCALE textAlignment:NSTextAlignmentCenter isFit:NO];
            lblcontent.font = TEXT_SC_TFONT(TEXT_SC_Medium, 14*SCALE);
            [subView addSubview:lblcontent];
        }
    }
    return _viewHeader;
}

-(UIView *)viewYear{
    if (!_viewYear) {
        _viewYear = [[UIView alloc] initWithFrame:CGRectMake(0, _viewHeader.bottom, kSCREEN_WIDTH, 69*SCALE)];
        _viewYear.backgroundColor = [UIColor clearColor];
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(16*SCALE, _viewYear.height-1, kSCREEN_WIDTH-32*SCALE, 1)];
        line.backgroundColor = RGBCOLOR(238, 238, 238);
        [_viewYear addSubview:line];
        
        UILabel *lblYear = [[UILabel alloc] initCommonWithFrame:CGRectMake(16*SCALE, 0, 20, 28*SCALE) title:[NSString stringWithFormat:@"%@年",self.year] bgColor:[UIColor clearColor] titleColor:RGBMAIN titleFont:28*SCALE textAlignment:NSTextAlignmentLeft isFit:YES];
        lblYear.centerY = _viewYear.height/2;
        self.lblYear = lblYear;
        [_viewYear addSubview:lblYear];
        UIButton *btnClick = [[UIButton alloc] initSystemWithFrame:CGRectMake(CGRectGetMaxX(lblYear.frame)+4*SCALE, 0, 16*SCALE, 16*SCALE) btnTitle:@"" btnImage:@"common_ic_arrow_down_g" titleColor:[UIColor clearColor] titleFont:0];
        btnClick.centerY = lblYear.centerY;
        [_viewYear addSubview:btnClick];
        
        //点击
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapYearAction:)];
        lblYear.userInteractionEnabled = YES;
        [lblYear addGestureRecognizer:tap];
        [btnClick addTarget:self action:@selector(btnClickYearAction) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *lblNextTimeCut = [[UILabel alloc] initCommonWithFrame:CGRectMake(0, _viewYear.height-16*SCALE-10*SCALE, 10, 10*SCALE) title:@"推荐下次剪发时间" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(135, 135, 135) titleFont:10*SCALE textAlignment:NSTextAlignmentRight isFit:YES];
        lblNextTimeCut.x = kSCREEN_WIDTH-lblNextTimeCut.width-16*SCALE;
        lblNextTimeCut.height = 10*SCALE;
        [_viewYear addSubview:lblNextTimeCut];
        
        UIView *viewNextTime = [[UIView alloc] initWithFrame:CGRectMake(lblNextTimeCut.x-4*SCALE-8*SCALE, 0, 8*SCALE, 2*SCALE)];
        viewNextTime.backgroundColor = RGBMAIN;
        viewNextTime.centerY = lblNextTimeCut.centerY;
        [_viewYear addSubview:viewNextTime];
        
        UILabel *lblTimeCut = [[UILabel alloc] initCommonWithFrame:CGRectMake(lblNextTimeCut.x, 24*SCALE, 10, 10*SCALE) title:@"剪发日" bgColor:[UIColor clearColor] titleColor:RGBCOLOR(135, 135, 135) titleFont:10*SCALE textAlignment:NSTextAlignmentRight isFit:YES];
        lblTimeCut.height = 10*SCALE;
        [_viewYear addSubview:lblTimeCut];
        
        UIView *viewTime = [[UIView alloc] initWithFrame:CGRectMake(viewNextTime.x, 0, 8*SCALE, 2*SCALE)];
        viewTime.backgroundColor = RGBCOLOR(25, 24, 29);
        viewTime.centerY = lblTimeCut.centerY;
        [_viewYear addSubview:viewTime];
    }
    return _viewYear;
}

-(void)createMonthView{
    if (self.viewMonths) {
        for (UIView *view in self.viewMonths.subviews) {
            if ([view isKindOfClass:[GGCalendarSubView class]]) {
                [view removeFromSuperview];
            }
        }
    }else{
        self.viewMonths = [[UIView alloc] initWithFrame:CGRectMake(0, _viewYear.bottom, kSCREEN_WIDTH, 100)];
        [_mainScrollView addSubview:self.viewMonths];
    }
    
    for (int i=0; i<self.dataSource.count; i++) {
        GGCalendarSubView *subView = [[GGCalendarSubView alloc] initWithFrame:CGRectMake(12*SCALE+i*((kSCREEN_WIDTH-24*SCALE)/3), 0, (kSCREEN_WIDTH-24*SCALE)/3, 100) withDateArr:self.dataSource[i]];
        subView.tag = 100+i;
        
        GGCalendarSubView *viewLast = (GGCalendarSubView *)[_viewMonths viewWithTag:100+i-1];
        
        if (i == 0) {
            subView.x = 12*SCALE;
            subView.y = 0;
        }else{
            subView.x = CGRectGetMaxX(viewLast.frame);
            if (CGRectGetMaxX(subView.frame)+12*SCALE > kSCREEN_WIDTH) {
                subView.x = 12*SCALE;
                subView.y = CGRectGetMaxY(viewLast.frame);
            }else{
                subView.y = viewLast.y;
            }
        }
        
        [_viewMonths addSubview:subView];
        _viewMonths.height = subView.bottom;
    }
    _mainScrollView.contentSize = CGSizeMake(kSCREEN_WIDTH, _viewMonths.bottom+16*SCALE);
}

#pragma mark -- 请求日历数据
-(void)getCalendarData{
    if ([HDToolHelper StringIsNullOrEmpty:[HDUserDefaultMethods getData:@"userId"]]) {
        return;
    }
    NSDictionary *params = @{@"userId":[HDUserDefaultMethods getData:@"userId"]};
    [MHNetworkManager postReqeustWithURL:URL_StoreTimeCalendarData params:params successBlock:^(NSDictionary *returnData) {
        DTLog(@"%@",returnData);
        if ([returnData[@"respCode"] integerValue] == 200) {
            self.infoModel = [HDCalendarInfoModel mj_objectWithKeyValues:returnData[@"data"]];
            //获取年月日时间表
            [self setupDatasouce];
            [self.view addSubview:self.mainScrollView];
        }
    } failureBlock:^(NSError *error) {
        
    } showHUD:YES];
}

#pragma mark -- 数据源
-(void)setupDatasouce{
    [self.dataSource removeAllObjects];
    nextCut = 0;
    
    if (!self.startDay.length || !self.endDay.length) {
        self.startDay = [NSDate timeStringWithInterval:[NSDate date].timeIntervalSince1970];
        self.endDay   = [NSDate timeStringWithInterval:[NSDate date].timeIntervalSince1970];
    }
    NSArray   *startArray = [self.startDay componentsSeparatedByString:@"-"];
    NSArray   *endArray   = [self.endDay componentsSeparatedByString:@"-"];
    NSInteger month       = ([endArray[0] integerValue] - [startArray[0] integerValue])* 12 + ([endArray[1] integerValue] - [startArray[1] integerValue]) + 1;
    
    for (int i = 0; i < month; i++) {
        NSMutableArray *array = [[NSMutableArray alloc]init];
        [self.dataSource addObject:array];
    }
    
    for (int i = 0; i < month; i++) {
        int              month       = ((int)[NSDate month:self.startDay] + i)%12;
        NSDateComponents *components = [[NSDateComponents alloc]init];
        
        //获取下个月的年月日信息,并将其转为date
        components.month = month ? month : 12;
        components.year  = (int)[NSDate year:self.startDay] + i/12;
        components.day   = 1;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDate     *nextDate = [calendar dateFromComponents:components];
        
        //获取该月第一天星期几
        NSInteger firstDayInThisMounth = [NSDate firstWeekdayInThisMonth:nextDate];
        
        //该月的有多少天daysInThisMounth
        NSInteger daysInThisMounth = [NSDate totaldaysInMonth:nextDate];
        NSString  *string          = [[NSString alloc]init];
        for (int j = 0; j < (daysInThisMounth > 29 && (firstDayInThisMounth == 6 || firstDayInThisMounth == 5) ? 42 : 35); j++) {
            CalenderModel *model = [[CalenderModel alloc] init];
            model.year  = components.year;
            model.month = components.month;
            if (j < firstDayInThisMounth || j > daysInThisMounth + firstDayInThisMounth - 1) {
                string    = @"";
                model.day = string;
            } else {
                string    = [NSString stringWithFormat:@"%ld", j - firstDayInThisMounth + 1];
                model.day = string;
                 
                NSString *dateStr = [NSString stringWithFormat:@"%zd-%02zd-%@",model.year, model.month, model.day];
                
                if ([NSDate isToday:dateStr]) {
                    model.isToday = YES;
                    model.isSelected = YES;
                }
                
                for (NSDictionary *dicDate in self.infoModel.dateList) {
                    if ([self isSameDay:dicDate[@"yuyueTime"] Time2:dateStr]) {
                        model.isCutDay = YES;
                    }
                }
                
                if ([self isSameDay:self.infoModel.nextDate Time2:dateStr]) {
                    model.isTuijianDay = YES;
                    nextCut ++;
                }
                if (nextCut > 0 && nextCut < 8) {
                    model.isTuijianDay = YES;
                    nextCut ++;
                }
            }
            [[self.dataSource objectAtIndex:i]addObject:model];
        }
    }
}

#pragma mark -- delagete action
-(void)navBackClicked{
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

//选择年份
-(void)tapYearAction:(UIGestureRecognizer *)sender{
    [self btnClickYearAction];
}

-(void)btnClickYearAction{
    DateTimePickerView *pickerView = [[DateTimePickerView alloc] init];
    self.datePickerView = pickerView;
    pickerView.delegate = self;
    pickerView.pickerViewMode = DatePickerViewYearMode;
    [self.view addSubview:pickerView];
    [pickerView showDateTimePickerView];
}

// 选择时间回调
- (void)didClickFinishDateTimePickerView:(NSString *)date{
    self.lblYear.text = [NSString stringWithFormat:@"%@年",date];
    self.lblYear.adjustsFontSizeToFitWidth = YES;
    
    self.startDay = [NSString stringWithFormat:@"%@-01-01",date];
    self.endDay = [NSString stringWithFormat:@"%@-12-31",date];
    
    [self setupDatasouce];
    [self createMonthView];
}

//获取当前年份
-(NSString *)getYear{
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy"];
    NSString *thisYearString=[dateformatter stringFromDate:senddate];
    return thisYearString;
}

- (BOOL)isSameDay:(NSString *)iTime1 Time2:(NSString *)iTime2{
    //传入时间毫秒数
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *pDate1 = [formatter dateFromString:iTime1];
    NSDate *pDate2 = [formatter dateFromString:iTime2];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:pDate1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:pDate2];
    
    return [comp1 day]   == [comp2 day] &&
    [comp1 month] == [comp2 month] &&
    [comp1 year]  == [comp2 year];
}

@end
