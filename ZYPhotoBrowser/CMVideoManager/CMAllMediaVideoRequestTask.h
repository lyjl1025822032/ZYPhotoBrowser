//
//  CMAllMediaVideoRequestTask.h
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/9/4.
//  Copyright © 2017年 liangscofield. All rights reserved.
//  视频网络任务

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class CMAllMediaVideoRequestTask;
@protocol CMAllMediaVideoRequestTaskDelegate <NSObject>

- (void)task:(CMAllMediaVideoRequestTask *)task didReciveVideoLength:(NSUInteger)videoLength mimeType:(NSString *)mimeType;
- (void)didReciveVideoDataWithTask:(CMAllMediaVideoRequestTask *)task;
- (void)didFinishLoadingWithTask:(CMAllMediaVideoRequestTask *)task;
- (void)didFailLoadingWithTask:(CMAllMediaVideoRequestTask *)task withError:(NSInteger)errorCode;

@end

@interface CMAllMediaVideoRequestTask : NSObject
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, readonly) NSUInteger offset;

@property (nonatomic, readonly) NSUInteger videoLength;
@property (nonatomic, readonly) NSUInteger downLoadingOffset;
@property (nonatomic, readonly) NSString *mimeType;
@property (nonatomic, assign) BOOL isFinishLoad;

@property (nonatomic, weak) id<CMAllMediaVideoRequestTaskDelegate> delegate;

- (void)setUrl:(NSURL *)url offset:(NSUInteger)offset;

- (void)cancel;

- (void)continueLoading;

- (void)clearData;
@end
