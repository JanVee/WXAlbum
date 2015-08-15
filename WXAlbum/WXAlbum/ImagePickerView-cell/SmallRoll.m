//
//  SmallRoll.m
//  WXAlbum
//
//  Created by Jan on 15/8/16.
//  Copyright (c) 2015年 Jan. All rights reserved.
//

#import "SmallRoll.h"

@interface SmallRoll ()

@property (nonatomic, weak) UIImageView *imageView; // 小圆

@end

@implementation SmallRoll

#pragma mark - 初始化
- (void)awakeFromNib
{
    [self setup];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - 尺寸
+ (CGSize)defaultSize;
{
    CGSize size = CGSizeMake([UIImage imageNamed:@"ImageResources.bundle/FriendsSendsPicturesSelectBigNIcon.png"].size.width/2, [UIImage imageNamed:@"ImageResources.bundle/FriendsSendsPicturesSelectBigNIcon.png"].size.height/2);
    return size;
}

#pragma mark - 设置小圆
- (void)setup
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ImageResources.bundle/FriendsSendsPicturesSelectBigNIcon.png"]];
    [self addSubview:imageView];
    self.imageView = imageView;
    [imageView setFrame:CGRectMake(0, 0, 28, 28)];
}

#pragma mark - 设置状态
- (void)setChecked:(BOOL)checked;
{
    if (checked) {
        UIImage *emptyCheckmark = [UIImage imageNamed:@"ImageResources.bundle/FriendsSendsPicturesSelectBigYIcon.png"];
        self.imageView.image = emptyCheckmark;
        
    } else {
        UIImage *fullCheckmark = [UIImage imageNamed:@"ImageResources.bundle/FriendsSendsPicturesSelectBigNIcon.png"];
        self.imageView.image = fullCheckmark;
    }
}

/**
 重写cell的prepareForReuse官方头文件中有说明.
 当前已经被分配的cell如果被重用了(通常是滚动出屏幕外了),
 会调用cell的prepareForReuse通知cell.
 */
#pragma mark - 非常重要的方法，重用的时候，将所有的cell全部改为不选中状态
- (void)prepareForReuse
{
    [self setChecked:NO];
}

@end
