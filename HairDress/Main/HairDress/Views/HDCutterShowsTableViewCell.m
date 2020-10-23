//
//  HDCutterShowsTableViewCell.m
//  HairDress
//
//  Created by 张凯中 on 2019/12/24.
//  Copyright © 2019 zhangkaizhong. All rights reserved.
//

#import "HDCutterShowsTableViewCell.h"
#import "HDCutterShowsCollectionViewCell.h"
#import "WSLWaterFlowLayout.h"

@interface HDCutterShowsTableViewCell ()<UICollectionViewDelegate,UICollectionViewDataSource,WSLWaterFlowLayoutDelegate>
{
    WSLWaterFlowLayout * _flow;
}
@property (nonatomic,strong)NSMutableArray *arrList;

@end

@implementation HDCutterShowsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.arrList = [NSMutableArray new];
        
        _flow = [[WSLWaterFlowLayout alloc] init];
        _flow.delegate = self;
        _flow.flowLayoutStyle = 0;
        
        [self.contentView addSubview:self.collectView];
    }
    
    return self;
}

#pragma mark -- 刷新数据
-(void)setArrData:(NSArray *)arrData{
    _arrData = arrData;
    
    [self.arrList removeAllObjects];
    [self.arrList addObjectsFromArray:arrData];
    [self.collectView reloadData];
}

-(UICollectionView *)collectView{
    if (!_collectView) {
//        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT-NAVHIGHT-49-KTarbarHeight-8) collectionViewLayout:_flow];
        _collectView.delegate = self;
        _collectView.dataSource = self;
        _collectView.backgroundColor = RGBBG;
        [_collectView registerClass:[HDCutterShowsCollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([HDCutterShowsCollectionViewCell class])];
    }
    return _collectView;
}

//-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
//    return 15;//可以根据section 设置不同section item的行间距
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
//    return 15;// 可以根据section 设置不同section item的列间距
//
//}
/** 列数*/
-(CGFloat)columnCountInWaterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout{
    return 2;
}
/** 列间距*/
-(CGFloat)columnMarginInWaterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout{
    return 15;
}
/** 行间距*/
-(CGFloat)rowMarginInWaterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout{
    return 15;
}
/** 边缘之间的间距*/
-(UIEdgeInsets)edgeInsetInWaterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout{
    return UIEdgeInsetsMake(8, 16, 8, 15);
}
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    HDCutterWorkShowsModel *model = self.arrData[indexPath.item];
//    return CGSizeMake((kSCREEN_WIDTH-32-15)/2, model.cellHegiht);//可以根据indexpath 设置item 的size
//}

//返回每个item大小
- (CGSize)waterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    HDCutterWorkShowsModel *model = self.arrData[indexPath.item];
    return CGSizeMake(0, model.cellHegiht);
}

- (CGSize)waterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout sizeForFooterViewInSection:(NSInteger)section {
    return CGSizeMake(0, 0);
}

- (CGSize)waterFlowLayout:(WSLWaterFlowLayout *)waterFlowLayout sizeForHeaderViewInSection:(NSInteger)section {
    return CGSizeMake(0, 0);
}

//-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UIEdgeInsetsMake(8, 16, 8, 15);
//}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;//设置section 个数
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrList.count;//根据section设置每个section的item个数
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HDCutterShowsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HDCutterShowsCollectionViewCell class]) forIndexPath:indexPath];
    cell.contentView.tag = 1000+indexPath.item;
    cell.model = self.arrList[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    HDCutterShowsCollectionViewCell *cell = (HDCutterShowsCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickShowBigImage:currentView:)]) {
        [self.delegate clickShowBigImage:indexPath.item currentView:cell.imageShow];
    }
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
