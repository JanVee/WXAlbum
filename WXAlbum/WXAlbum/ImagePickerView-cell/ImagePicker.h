//
//  ImagePicker.h
//  WXAlbum
//
//  Created by Jan on 15/8/16.
//  Copyright (c) 2015年 Jan. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CompleteAnimationBlock)(BOOL Complete); // 完成照片选择之后执行的动作
typedef void(^SeletedImages)(NSArray *GetImages, NSInteger Buttonindex); // 将照片传出去

@interface ImagePicker : UIView
@property (nonatomic,strong) SeletedImages SeletedImages;

// 根据界面选项初始化
-(instancetype) initWithCancelStr:(NSString *)str otherButtonTitles:(NSArray *)Titles;

// 退出界面
-(void)DismissBlock:(CompleteAnimationBlock)block;
@end
