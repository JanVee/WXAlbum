//
//  JanCollectionViewCell.m
//  WXAlbum
//
//  Created by Jan on 15/8/16.
//  Copyright (c) 2015年 Jan. All rights reserved.
//

#import "JanCollectionViewCell.h"

@implementation JanCollectionViewCell

#pragma mark - 初始化
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; // 设置界面
    }
    return self;
}
#pragma mark - 初始化
- (void)awakeFromNib
{
    [self setup];  // xib设置界面
}

#pragma mark - 设置界面
- (void)setup
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.layer.cornerRadius = 1.0f;
    imageView.layer.masksToBounds = true;
    [self.contentView addSubview:imageView];
    self.imageView = imageView;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(imageView);
    // 0垂直约束
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[imageView]|" options:0 metrics:nil views:views]];
    // 0水平约束
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[imageView]|" options:0 metrics:nil views:views]];
}

@end
