//
//  ViewController.m
//  WXAlbum
//
//  Created by Jan on 15/8/16.
//  Copyright (c) 2015年 Jan. All rights reserved.
//

#import "ViewController.h"

#import "ImagePicker.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _btn.layer.cornerRadius = 8.0f;
    _btn.layer.masksToBounds = YES;
}
- (IBAction)pickAction:(UIButton *)button
{
    ImagePicker *picker = [[ImagePicker alloc] initWithCancelStr:@"取消" otherButtonTitles:@[@"拍摄",@"从相册选择"]];
    picker.SeletedImages = ^(NSArray *GetImages, NSInteger Buttonindex){
        
        //NSLog(@"GetImages-%@,Buttonindex-%ld",GetImages,(long)Buttonindex);
        
    for (int i = 0; i < GetImages.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(i%4*80+5, i/4*80+100, 79, 79)];
        imageView.image = GetImages[i];
        [self.view addSubview:imageView];
       }
    };
    [self.view insertSubview:picker atIndex:[[self.view subviews] count]];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
