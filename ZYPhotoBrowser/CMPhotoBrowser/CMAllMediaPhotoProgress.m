//
//  CMAllMediaPhotoProgress.m
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/8/29.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "CMAllMediaPhotoProgress.h"

static CGFloat minProgress = 1.0 / 16.0;

@implementation CMAllMediaPhotoProgress

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _progress = minProgress;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextFillPath(context);
    CGRect aRect= CGRectMake(2, 2, self.bounds.size.width - 4, self.bounds.size.height - 4);
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.9);
    CGContextSetLineWidth(context, 2.0);
    CGContextAddEllipseInRect(context, aRect);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGFloat centerX = self.bounds.size.width / 2;
    CGFloat centerY = self.bounds.size.height / 2;
    
    UIColor *aColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    CGContextSetFillColorWithColor(context, aColor.CGColor);
    CGContextSetLineWidth(context, 0.0);
    CGContextMoveToPoint(context, centerX, centerY);
    CGContextAddArc(context, centerX, centerY, (self.bounds.size.width - 10) / 2,  - M_PI_2, - M_PI_2 + self.progress * 2 *M_PI, 0);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    if (_progress < minProgress) {
        _progress = minProgress;
    }
    if (_progress >= 1.0) {
        [self setNeedsDisplay];
        [self removeFromSuperview];
    } else {
        [self setNeedsDisplay];
    }
}

@end
