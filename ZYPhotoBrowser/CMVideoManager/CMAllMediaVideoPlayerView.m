//
//  CMAllMediaVideoPlayerView.m
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/8/18.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "CMAllMediaVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation CMAllMediaVideoPlayerView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
@end
