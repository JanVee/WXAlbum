//
//  ImagePicker.m
//  WXAlbum
//
//  Created by Jan on 15/8/16.
//  Copyright (c) 2015年 Jan. All rights reserved.
//

#import "ImagePicker.h"
#import "JanFlowLayout.h"
#import "JanCollectionViewCell.h"
#import "PickerTool.h"
#import "SmallRoll.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define kImageSpacing 5.0f // 间隔
#define kCollectionViewHeight 178.0f  // 总高度
#define kSubTitleHeight 65.0f
#define ItemHeight 50.0f
#define H [UIScreen mainScreen].bounds.size.height
#define W [UIScreen mainScreen].bounds.size.width
#define Color [UIColor colorWithRed:26/255.0f green:178.0/255.0f blue:10.0f/255.0f alpha:1]
#define Spacing 7.0f

@interface ImagePicker ()<UICollectionViewDataSource,UICollectionViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,copy)NSString *cancelStr;
@property (nonatomic,strong)NSArray *ButtonTitles;
@property (nonatomic,weak) UIView * BottomView;
@property (nonatomic,weak)UICollectionView *CollectionView;
@property (nonatomic, strong) NSMapTable *indexPathToCheckViewTable;
@property (nonatomic, strong) ALAssetsGroup *group;
@property (nonatomic,strong) NSMutableArray *allArr;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;
@property (nonatomic,strong)NSIndexPath	* lastIndexPath;
@property (nonatomic,strong)NSMutableArray *assetsGroups;
@property (nonatomic,strong)PickerTool *lib;
@end

@implementation ImagePicker

#pragma mark - 懒加载
-(NSMutableArray *)assetsGroups{
    if (!_assetsGroups) {
        _assetsGroups=[[NSMutableArray alloc]init];
    }
    return _assetsGroups;
}

#pragma mark - 懒加载
-(PickerTool *)lib{
    if (!_lib) {
        _lib = [[PickerTool alloc] init];
    }
    return _lib;
}

-(instancetype) initWithCancelStr:(NSString *)str otherButtonTitles:(NSArray *)Titles{
    self = [super init];
    if (self) {
        __weak ImagePicker *weakSlef = self;
        _lib = [[PickerTool alloc] init];
        _lib.dataBlock = ^(NSArray *ImgsData){
            if (ImgsData.count != 0) {
                weakSlef.cancelStr = str;
                weakSlef.ButtonTitles = Titles;
                [weakSlef LoadUI];
            }
        };
        if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusRestricted) {
            NSLog(@"This application is not authorized to access photo data.");
        }else if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied){
            NSLog(@"用户已经明确否认了这一应用程序访问数据的照片。");
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"读取失败"
                                                           message:@"请打开 设置-隐私-照片 来进行设置"
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:nil, nil];
            [alert show];
        }else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized){
            NSLog(@"SER已授权该应用程序访问数据的照片。");
            _cancelStr = str;
            _ButtonTitles = Titles;
            [self LoadUI];
        }else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined){
            NSLog(@"用户还没有做出选择的问候这个应用程序");
        }
    }
    return self;
}

#pragma mark - 布局
-(void)LoadUI{
    self.selectedIndexes = [NSMutableArray array];
    [self setFrame:CGRectMake(0, 0, W, H)];
    [self setBackgroundColor:[UIColor clearColor]];
    
    UIView *ButtomView = [[UIView alloc] init];
    
    ButtomView.backgroundColor = [UIColor colorWithRed:223.0f/255.0f green:226.0f/255.f blue:236.0f/255.0f alpha:1];
    CGFloat height = ((ItemHeight+0.5f)+Spacing) + (_ButtonTitles.count * (ItemHeight+0.5f)) + kCollectionViewHeight;
    [ButtomView setFrame:CGRectMake(0, H, W, height)];
    _BottomView = ButtomView;
    [self addSubview:ButtomView];
    
    UIButton *Cancebtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [Cancebtn setBackgroundColor:[UIColor whiteColor]];
    [Cancebtn setFrame:CGRectMake(0, CGRectGetHeight(ButtomView.bounds) - ItemHeight, W, ItemHeight)];
    [Cancebtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [Cancebtn setTitle:_cancelStr forState:UIControlStateNormal];
    [Cancebtn addTarget:self action:@selector(SelectedButtons:) forControlEvents:UIControlEventTouchUpInside];
    [Cancebtn setTag:100];
    [_BottomView addSubview:Cancebtn];
    
    for (NSString *Title in _ButtonTitles) {
        NSInteger index = [_ButtonTitles indexOfObject:Title];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        [btn setBackgroundColor:[UIColor whiteColor]];
        CGFloat hei = (50.5 * _ButtonTitles.count)+Spacing;
        CGFloat y = (CGRectGetMinY(Cancebtn.frame) + (index * (ItemHeight+0.5))) - hei;
        [btn setFrame:CGRectMake(0, y, W, ItemHeight)];
        [btn setTag:(index + 100)+1];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:Title forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(SelectedButtons:) forControlEvents:UIControlEventTouchUpInside];
        [_BottomView addSubview:btn];
    }
    
    JanFlowLayout *flow = [[JanFlowLayout alloc] init];
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = kImageSpacing;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flow];
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.allowsMultipleSelection = YES;
    collectionView.allowsSelection = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.collectionViewLayout = flow;
    [collectionView registerClass:[JanCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [collectionView registerClass:[SmallRoll class] forSupplementaryViewOfKind:@"check" withReuseIdentifier:@"CheckCell"];
    collectionView.contentInset = UIEdgeInsetsMake(0, 6, 0, 6);
    
    [ButtomView addSubview:collectionView];
    self.CollectionView = collectionView;
    self.CollectionView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    self.indexPathToCheckViewTable = [NSMapTable strongToWeakObjectsMapTable];
    [self.CollectionView setFrame:CGRectMake(0, 5, W, kCollectionViewHeight-10)];
    UIActivityIndicatorView *act = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.CollectionView.bounds)/2 - 10 , CGRectGetHeight(self.CollectionView.bounds)/2 - 10, 20, 20)];
    act.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [act startAnimating];
    [self.CollectionView addSubview:act];
    
    typeof(self) __weak weak = self;
    
    // 取出相册里面的图片
    _lib.dataBlock = ^(NSArray *ImgsData){
        weak.allArr = [NSMutableArray arrayWithArray:ImgsData];
        [weak.CollectionView reloadData];
        [act stopAnimating];
    };
    
    [UIView animateWithDuration:0.8f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [weak setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f]];
        [ButtomView setFrame:CGRectMake(0, H - height, W, height+10)];
    } completion:^(BOOL finished) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:weak action:@selector(dismiss:)];
        tap.delegate = self;
        [weak addGestureRecognizer:tap];
        [ButtomView setFrame:CGRectMake(0, H - height, W, height)];
    }];
}

#pragma mark - 选项
-(void)SelectedButtons:(UIButton *)btns{
    if ([btns.titleLabel.text isEqualToString:@"拍摄"]) {
        NSLog(@"从相机拍摄");
        [self DismissBlock:^(BOOL Complete) {}];
        return;
    }
    typeof(self) __weak weak = self;
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < self.selectedIndexes.count;i++) {
        ALAsset *asset = [_allArr objectAtIndex:[self.selectedIndexes[i] integerValue]];
        UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
        [arr addObject:image];
    }
    
    [self DismissBlock:^(BOOL Complete) {
        weak.SeletedImages(arr,btns.tag-100);
    }];
}

#pragma mark - UICollectionViewDataSource-- 数据源方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    return _allArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    JanCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    ALAsset *asset = [_allArr objectAtIndex:indexPath.row];
    UIImage *image = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    cell.imageView.image = image;
    SmallRoll *checkmarkView = [self.indexPathToCheckViewTable objectForKey:indexPath];
    if ([self.selectedIndexes containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
        [checkmarkView setChecked:YES];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath;
{
    SmallRoll *checkView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CheckCell" forIndexPath:indexPath];
    [self.indexPathToCheckViewTable setObject:checkView forKey:indexPath];
    
    if ([[collectionView indexPathsForSelectedItems] containsObject:indexPath]) {
        [checkView setChecked:YES];
    }
    return checkView;
}

#pragma mark - UICollectionViewDelegate

// 取消选中
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    [self toggleSelectionAtIndexPath:indexPath];
}
// 选中
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    [self toggleSelectionAtIndexPath:indexPath];
}

- (void)toggleSelectionAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *Ti = (UIButton *)[_BottomView viewWithTag:101];
    SmallRoll *checkmarkView = [self.indexPathToCheckViewTable objectForKey:indexPath];
    
    // 根据数组的图片索引，判断是非已经存在图片了
    if ([self.selectedIndexes containsObject:[NSString stringWithFormat:@"%d",indexPath.row]]) {
        [self.selectedIndexes removeObject:[NSString stringWithFormat:@"%d",indexPath.row]];
        [checkmarkView setChecked:NO];
    }else{
        [self.selectedIndexes addObject:[NSString stringWithFormat:@"%d",indexPath.row]];
        [checkmarkView setChecked:YES];
    }
    if (self.selectedIndexes.count == 0) {
        [Ti setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [Ti setTitle:[_ButtonTitles objectAtIndex:Ti.tag-101] forState:UIControlStateNormal];
        
    }else{
        [Ti setTitle:[NSString stringWithFormat:@"选择(%ld张)",(unsigned long)self.selectedIndexes.count] forState:UIControlStateNormal];
        [Ti setTitleColor:Color forState:UIControlStateNormal];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    ALAsset *asset = [_allArr objectAtIndex:indexPath.row];
    UIImage *imageAtPath = [UIImage imageWithCGImage:[asset aspectRatioThumbnail]];
    CGFloat imageHeight = imageAtPath.size.height;
    CGFloat viewHeight = collectionView.bounds.size.height;
    CGFloat scaleFactor = viewHeight/imageHeight;
    CGSize scaledSize = CGSizeApplyAffineTransform(imageAtPath.size, CGAffineTransformMakeScale(scaleFactor, scaleFactor));
    return scaledSize;
}

-(void)DismissBlock:(CompleteAnimationBlock)block{
    typeof(self) __weak weak = self;
    CGFloat height = ((ItemHeight+0.5f)+Spacing) + (_ButtonTitles.count * (ItemHeight+0.5f)) + kCollectionViewHeight;
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:0.8f initialSpringVelocity:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        [weak setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f]];
        [_BottomView setFrame:CGRectMake(0, H, W, height)];
    } completion:^(BOOL finished) {
        block(finished);
        [self removeFromSuperview];
    }];
}

-(void)dismiss:(UITapGestureRecognizer *)tap{
    if( CGRectContainsPoint(self.frame, [tap locationInView:_BottomView])) {
        //NSLog(@"tap");
    } else{
        [self DismissBlock:^(BOOL Complete) {
        }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (touch.view != self) {
        return NO;
    }
    return YES;
}

@end
