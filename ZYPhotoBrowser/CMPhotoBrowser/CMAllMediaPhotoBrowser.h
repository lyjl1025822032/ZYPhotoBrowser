//
//  CMAllMediaPhotoBrowser.h
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/8/29.
//  Copyright © 2017年 liangscofield. All rights reserved.
//  图片浏览器controller

#import <UIKit/UIKit.h>

@interface CMAllMediaPhotoBrowser : UIViewController
/** 缩略图数组 (UIImageView)**/
@property (nonatomic, strong)NSArray *thumbImgArr;
/** 原图Url数组 **/
@property (nonatomic, strong)NSArray *sourceUrlArr;
/** 点击进入的图片下标 **/
@property (nonatomic, assign)NSInteger tapImgIndex;

/** 显示图片浏览器 **/
- (void)showPhotoBrowser;
@end
