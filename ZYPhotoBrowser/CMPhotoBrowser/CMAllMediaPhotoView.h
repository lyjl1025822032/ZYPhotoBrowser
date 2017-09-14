//
//  CMAllMediaPhotoView.h
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/8/29.
//  Copyright © 2017年 liangscofield. All rights reserved.
//  展现的图片视图

#import <UIKit/UIKit.h>

@protocol CMAllMediaPhotoViewDelegate <NSObject>

- (void)photoViewSingleTap:(NSInteger)index;

- (BOOL)photoIsShowingPhotoViewAtIndex:(NSUInteger)index;

- (void)updatePhotoProgress:(CGFloat)progress andIndex:(NSInteger)index;
@end

@interface CMAllMediaPhotoView : UIView
@property(nonatomic, weak)id<CMAllMediaPhotoViewDelegate> photoViewDelegate;
//图片image
@property(nonatomic, strong)UIImage *itemImage;
//原图图片url
@property(nonatomic, copy)NSString *itemImageUrl;
//网络请求的进度
@property(nonatomic, assign)CGFloat itemImageProgress;
//点击视频播放回调
@property(nonatomic, copy)void(^playerBlock)(NSString *videoUrl, UIView *windowView);

- (void)resetSize;
@end
