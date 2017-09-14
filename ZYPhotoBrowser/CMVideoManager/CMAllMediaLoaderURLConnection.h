//
//  CMAllMediaLoaderURLConnection.h
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/9/4.
//  Copyright © 2017年 liangscofield. All rights reserved.
//  视频请求连接

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "CMAllMediaVideoRequestTask.h"

@protocol CMAllMediaLoaderURLConnectionDelegate <NSObject>

- (void)didFinishLoadingWithTask:(CMAllMediaVideoRequestTask *)task;
- (void)didFailLoadingWithTask:(CMAllMediaVideoRequestTask *)task withError:(NSInteger )errorCode;
@end

@interface CMAllMediaLoaderURLConnection : NSURLConnection<AVAssetResourceLoaderDelegate>
@property (nonatomic, strong) CMAllMediaVideoRequestTask *task;
@property (nonatomic, weak  ) id<CMAllMediaLoaderURLConnectionDelegate> delegate;
- (NSURL *)getSchemeVideoURL:(NSURL *)url;
@end
