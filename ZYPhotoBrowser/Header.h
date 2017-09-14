//
//  Header.h
//  ZYPhotoBrowser
//
//  Created by 王智垚 on 2017/9/14.
//  Copyright © 2017年 王智垚. All rights reserved.
//

#ifndef Header_h
#define Header_h

#import <UIKit/UIKit.h>
// 图片路径
#define kVideoViewPicName(file) [UIImage imageNamed:file inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:nil]
#define kScreenScale  [UIScreen mainScreen].scale
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#endif /* Header_h */
