//
//  SmallRoll.h
//  WXAlbum
//
//  Created by Jan on 15/8/16.
//  Copyright (c) 2015年 Jan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmallRoll : UICollectionReusableView

+ (CGSize)defaultSize;            // 小圆尺寸
- (void)setChecked:(BOOL)checked; // 设置小圆是非为选中状态

@end
