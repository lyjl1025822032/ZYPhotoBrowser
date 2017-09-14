//
//  CMAllMediaPhotoBrowserManager.m
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/8/29.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "CMAllMediaPhotoBrowserManager.h"
#import "CMAllMediaPhotoBrowser.h"

@implementation CMAllMediaPhotoBrowserManager

+ (CMAllMediaPhotoBrowserManager *)sharedInstance {
    static CMAllMediaPhotoBrowserManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CMAllMediaPhotoBrowserManager alloc]init];
    });
    
    return instance;
}

- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)manageShowPhotoBrowserWithThumbArray:(NSArray *)thumbArray andSourceUrlArray:(NSArray *)sourceUrlArray andTapImgIndex:(NSInteger)tapImgIndex {
    CMAllMediaPhotoBrowser *photoVC = [[CMAllMediaPhotoBrowser alloc] init];
    photoVC.tapImgIndex = tapImgIndex;
    photoVC.thumbImgArr = thumbArray;
    photoVC.sourceUrlArr = sourceUrlArray;
    [photoVC showPhotoBrowser];
}

@end
