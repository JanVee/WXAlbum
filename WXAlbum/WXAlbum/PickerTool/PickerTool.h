//
//  PickerTool.h
//  WXAlbum
//
//  Created by Jan on 15/8/16.
//  Copyright (c) 2015年 Jan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^dataBlock)(NSArray *imageData);

@interface PickerTool : NSObject

@property (nonatomic, strong) dataBlock dataBlock;

@property (nonatomic,strong) NSMutableArray *UpDataImages;

-(instancetype) init;

@end
