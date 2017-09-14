//
//  CMAllMediaPhotoBrowserManager.h
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/8/29.
//  Copyright © 2017年 liangscofield. All rights reserved.
//  图片浏览器单例

#import <Foundation/Foundation.h>

@interface CMAllMediaPhotoBrowserManager : NSObject
/** 初始化单例 **/
+ (CMAllMediaPhotoBrowserManager *)sharedInstance;

/**
 *  图片浏览器
 *
 *  @param thumbArray      缩略图数组
 *  @param sourceUrlArray  原图Url数组
 *  @param tapImgIndex     点击图片下标
 */
- (void)manageShowPhotoBrowserWithThumbArray:(NSArray *)thumbArray andSourceUrlArray:(NSArray *)sourceUrlArray andTapImgIndex:(NSInteger)tapImgIndex;

@end
