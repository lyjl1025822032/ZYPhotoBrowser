//
//  UIScrollView+CMAllMediaQuickScrollView.m
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/9/5.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "UIScrollView+CMAllMediaQuickScrollView.h"

@implementation UIScrollView (CMAllMediaQuickScrollView)
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if([view isKindOfClass:[UISlider class]]) {
        //如果响应view是UISlider,则scrollview禁止滑动
        self.scrollEnabled = NO;
    } else {
        //如果不是,则恢复滑动
        self.scrollEnabled = YES;
    }
    return view;
}
@end
