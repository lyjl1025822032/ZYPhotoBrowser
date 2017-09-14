//
//  CMAllMediaPhotoView.m
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/8/29.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "CMAllMediaPhotoView.h"
#import "CMAllMediaPhotoProgress.h"
#import "UIImage+CMAllMediaPhotoGif.h"

static CGFloat kMinProgress = 0.0001;

@interface CMAllMediaPhotoView ()<UIGestureRecognizerDelegate, UIScrollViewDelegate, NSURLSessionDownloadDelegate> {
    //触摸开始触碰到的点
    CGPoint _touchBeginPoint;
}
//点击关闭浏览器
@property(nonatomic, strong)UITapGestureRecognizer *singleTap;
//双击放大图片
@property(nonatomic, strong)UITapGestureRecognizer *doubleTap;
//拖拽手势
@property(nonatomic, strong)UIPanGestureRecognizer *panRecognizer;
/** 播放按钮 **/
@property(nonatomic, strong)UIButton *videoPlayBtn;
@property(nonatomic, strong)UIScrollView *scrollView;
//进度条
@property(nonatomic, strong)CMAllMediaPhotoProgress *progressView;
//图片视图
@property(nonatomic, strong)UIImageView *itemImageView;
//填充比例
@property(nonatomic, assign)CGFloat fillScale;
//图片适配后尺寸
@property(nonatomic, assign)CGSize  imageRealSize;
@property(nonatomic, strong)NSURLSessionDownloadTask *task;
@property(nonatomic, strong)NSURLSession *session;
@end

@implementation CMAllMediaPhotoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.scrollView];
        [_scrollView addSubview:self.itemImageView];
        
        _progressView = [[CMAllMediaPhotoProgress alloc] init];
        _progressView.center = CGPointMake((self.bounds.size.width) / 2, (self.bounds.size.height) / 2);
        
        [self addGestureRecognizer:self.singleTap];
        [self addGestureRecognizer:self.doubleTap];
        [self addGestureRecognizer:self.panRecognizer];
        
        [_singleTap requireGestureRecognizerToFail:_doubleTap];
        
    }
    return self;
}

#pragma mark setter
- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _scrollView.frame = self.bounds;
    _progressView.center = CGPointMake((self.bounds.size.width) / 2, (self.bounds.size.height) / 2);
    self.videoPlayBtn.frame = CGRectMake((self.bounds.size.width-60) / 2, (self.bounds.size.height-60) / 2, 60, 60);
}

- (void)setItemImage:(UIImage *)itemImage {
    _itemImage = itemImage;
}

- (void)setItemImageUrl:(NSString *)itemImageUrl {
    [self.task cancel];
    self.task = nil;
    _itemImageUrl = itemImageUrl;
    
    //这里自己写需要保存数据的路径
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@", dirPath, [itemImageUrl lastPathComponent]];
    BOOL imageExist = [[NSFileManager defaultManager] fileExistsAtPath:cachePath];
    
    _singleTap.enabled = YES;
    _doubleTap.enabled = [itemImageUrl.pathExtension isEqualToString:@"mp4"]?NO:YES;
    _panRecognizer.enabled = [itemImageUrl.pathExtension isEqualToString:@"mp4"]?NO:YES;
    
    if (_itemImageProgress == 1.0 || imageExist) {
        [_progressView removeFromSuperview];
        [_videoPlayBtn removeFromSuperview];
    } else {
        [_videoPlayBtn removeFromSuperview];
        _progressView.bounds = CGRectMake(0, 0, 50, 50);
        _progressView.center = CGPointMake((self.bounds.size.width) / 2, (self.bounds.size.height) / 2);
        [self addSubview:_progressView];
        
        _progressView.progress = _itemImageProgress;
    }
    
    _itemImageView.image = _itemImage;
    
    [self resetSize];
    
    __weak CMAllMediaPhotoView *photoView = self;
    
    NSInteger index = self.tag - 1;
    if (!imageExist) {
        NSURL *url = [NSURL URLWithString:[itemImageUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
        self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        // 2、创建任务(task)
        self.task = [_session downloadTaskWithURL:url];
        // 3、执行任务
        [_task resume];
    } else {
        NSData * data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:cachePath]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置图片
            UIImage *image = [cachePath.pathExtension isEqualToString:@"gif"]?[UIImage gif_animatedGIFWithData:data]:[UIImage imageWithData:data];
            if (image) {
                if ([photoView.photoViewDelegate respondsToSelector:@selector(photoIsShowingPhotoViewAtIndex:)]) {
                    BOOL isShow = [photoView.photoViewDelegate photoIsShowingPhotoViewAtIndex:index];
                    if (isShow) {
                        photoView.itemImageView.image = image;
                        [self resetSize];
                    }
                }
                if ([photoView.photoViewDelegate respondsToSelector:@selector(updatePhotoProgress:andIndex:)]) {
                    [photoView.photoViewDelegate updatePhotoProgress:1.0 andIndex:index];
                }
            } else {
                if ([cachePath.pathExtension isEqualToString:@"mp4"]) {
                    [_videoPlayBtn removeFromSuperview];
                    [self addSubview:_videoPlayBtn];
                }
            }
        });
    }
}


#pragma mark NSURLSessionDownloadDelegate
/*
 1.接收到服务器返回的数据
 bytesWritten: 当前这一次写入的数据大小
 totalBytesWritten: 已经写入到本地文件的总大小
 totalBytesExpectedToWrite : 被下载文件的总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    __weak CMAllMediaPhotoProgress *progressView = _progressView;
    __weak CMAllMediaPhotoView *photoView = self;
    NSInteger index = self.tag - 1;
    if ([photoView.photoViewDelegate respondsToSelector:@selector(photoIsShowingPhotoViewAtIndex:)]) {
        BOOL isShow = [photoView.photoViewDelegate photoIsShowingPhotoViewAtIndex:index];
        if (isShow) {
            if (totalBytesWritten > kMinProgress) {
                CGFloat progress = (CGFloat)totalBytesWritten/totalBytesExpectedToWrite;
                progressView.progress = progress;
            }
        }
    }
    if ([photoView.photoViewDelegate respondsToSelector:@selector(updatePhotoProgress:andIndex:)]) {
        [photoView.photoViewDelegate updatePhotoProgress:(float)totalBytesWritten/totalBytesExpectedToWrite andIndex:index];
    }
}

/*
 2.下载完成
 downloadTask:里面包含请求信息，以及响应信息
 location：下载后自动帮我保存的地址
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    __weak CMAllMediaPhotoView *photoView = self;
    NSInteger index = self.tag - 1;
    //这里自己写需要保存数据的路径
    NSString *dirPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cachePath = [NSString stringWithFormat:@"%@/%@", dirPath, [_itemImageUrl lastPathComponent]];
    //2、移动图片的存储地址
    [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    BOOL success = [[NSFileManager defaultManager] moveItemAtURL:location toURL:[NSURL fileURLWithPath:cachePath] error:nil];
    if (success) {
        NSData * data = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:cachePath]];
        dispatch_async(dispatch_get_main_queue(), ^{
            //设置图片
            UIImage *image = [cachePath.pathExtension isEqualToString:@"gif"]?[UIImage gif_animatedGIFWithData:data]:[UIImage imageWithData:data];
            if (image) {
                if ([photoView.photoViewDelegate respondsToSelector:@selector(photoIsShowingPhotoViewAtIndex:)]) {
                    BOOL isShow = [photoView.photoViewDelegate photoIsShowingPhotoViewAtIndex:index];
                    if (isShow) {
                        photoView.itemImageView.image = image;
                        [self resetSize];
                    }
                }
                if ([photoView.photoViewDelegate respondsToSelector:@selector(updatePhotoProgress:andIndex:)]) {
                    [photoView.photoViewDelegate updatePhotoProgress:1.0 andIndex:index];
                }
            } else {
                [_videoPlayBtn removeFromSuperview];
                [self addSubview:_videoPlayBtn];
            }
        });
    }
}

/** 3.请求完毕 如果有错误, 那么error有值 **/
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    //    if (error) {
    //        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData]) {
    //            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
    //            [self.resumeDic setObject:resumeData forKey:_itemImageUrl];
    //        }
    //    }
}

//适配图片尺寸
- (void)checkSize {
    if (_itemImageView.image) {
        _scrollView.zoomScale = 1.0;
        
        CGFloat imageViewW = self.bounds.size.width;
        CGFloat imageViewH = imageViewW * _itemImageView.image.size.height / _itemImageView.image.size.width;
        CGFloat imageViewX = 0;
        CGFloat imageViewY = 0;
        
        _itemImageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
        
        _imageRealSize = CGSizeMake(_itemImageView.image.size.width * _itemImageView.image.scale / kScreenScale, _itemImageView.image.size.height * _itemImageView.image.scale / kScreenScale);
        
        CGFloat maxScale = 1.0;
        CGFloat minScale = 1.0;
        
        if (kScreenWidth < kScreenHeight) {
            if (_itemImageView.bounds.size.height < _itemImageView.bounds.size.width) {
                
                _fillScale = kScreenHeight / _itemImageView.bounds.size.height;
                maxScale = _fillScale;
                minScale = _imageRealSize.width / _itemImageView.bounds.size.width;
                
                if (_imageRealSize.width * 3 / imageViewW > maxScale) {
                    maxScale = _imageRealSize.width * 3 / imageViewW;
                }
                if (minScale > 1.0) {
                    minScale = 1.0;
                }
            } else {
                maxScale = _imageRealSize.width * 3 / imageViewW;
                minScale = _imageRealSize.width / imageViewW;
                
                if (maxScale < 1.0) {
                    maxScale = 1.0;
                }
                if (minScale > 1.0) {
                    minScale = 1.0;
                }
            }
        } else {
            if (_itemImageView.bounds.size.width / _itemImageView.bounds.size.height > kScreenWidth / kScreenHeight) {
                
                _fillScale = kScreenHeight / _itemImageView.bounds.size.height;
                maxScale = _fillScale;
                minScale = _imageRealSize.width / _itemImageView.bounds.size.width;
                
                if (_imageRealSize.width * 3 / imageViewW > maxScale) {
                    maxScale = _imageRealSize.width * 3 / imageViewW;
                }
                if (minScale > 1.0) {
                    minScale = 1.0;
                }
            } else {
                maxScale = _imageRealSize.width * 3 / imageViewW;
                minScale = _imageRealSize.width / imageViewW;
                
                if (maxScale < 1.0) {
                    maxScale = 1.0;
                }
                if (minScale > 1.0) {
                    minScale = 1.0;
                }
            }
        }
        _scrollView.maximumZoomScale = maxScale;
        _scrollView.minimumZoomScale = minScale;
    } else {
        _itemImageView.frame = self.bounds;
    }
    _scrollView.contentSize = _itemImageView.bounds.size;
    [self centerContent];
    
}

- (void)centerContent {
    CGRect frame = _itemImageView.frame;
    CGFloat top = 0, left = 0;
    if (_scrollView.contentSize.width < _scrollView.bounds.size.width) {
        left = (_scrollView.bounds.size.width - _scrollView.contentSize.width) * 0.5f;
    }
    if (_scrollView.contentSize.height < _scrollView.bounds.size.height) {
        top = (_scrollView.bounds.size.height - _scrollView.contentSize.height) * 0.5f;
    }
    top -= frame.origin.y;
    left -= frame.origin.x;
    _scrollView.contentInset = UIEdgeInsetsMake(top, left, top, left);
}

- (void)resetSize {
    [self checkSize];
    if (_scrollView.contentInset.top == 0) {
        _scrollView.contentOffset = CGPointZero;
    }
}

#pragma mark UIGestureRecognizer
- (void)singleTap:(UITapGestureRecognizer *)singleTap {
    if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
        [self.photoViewDelegate photoViewSingleTap:self.tag];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)doubleTap {
    CGPoint location = [doubleTap locationInView:_itemImageView];
    if(kScreenWidth < kScreenHeight){
        if (_itemImageView.bounds.size.height < _itemImageView.bounds.size.width) {
            if (_scrollView.zoomScale == _scrollView.maximumZoomScale || fabs(_scrollView.zoomScale - _fillScale) < 0.00001) {
                [_scrollView setZoomScale:1.0 animated:YES];
                
            } else {
                CGFloat locationX = location.x;
                CGRect zoomRect = CGRectMake(locationX, 0, kScreenWidth / _fillScale, _itemImageView.bounds.size.height);
                
                [_scrollView zoomToRect:zoomRect animated:YES];
            }
        } else {
            if (_scrollView.zoomScale == _scrollView.maximumZoomScale) {
                if (_scrollView.maximumZoomScale == 1.0) {
                    CGRect zoomRect = CGRectMake(0, location.y - kScreenHeight / 2, _itemImageView.bounds.size.width, kScreenHeight);
                    
                    [_scrollView zoomToRect:zoomRect animated:YES];
                } else {
                    [_scrollView setZoomScale:1.0 animated:YES];
                }
            } else {
                CGFloat locationX = location.x;
                CGFloat locationY = location.y;
                CGRect zoomRect = CGRectMake(locationX, locationY, 1, 1);
                
                [_scrollView zoomToRect:zoomRect animated:YES];
            }
        }
    } else {
        if (_itemImageView.bounds.size.width / _itemImageView.bounds.size.height > kScreenWidth / kScreenHeight) {
            if (_scrollView.zoomScale == _scrollView.maximumZoomScale ||fabs(_scrollView.zoomScale - _fillScale) < 0.00001) {
                
                [_scrollView setZoomScale:1.0 animated:YES];
            } else {
                CGFloat locationX = location.x;
                CGRect zoomRect = CGRectMake(locationX, 0, kScreenWidth / _fillScale, _itemImageView.bounds.size.height);
                
                [_scrollView zoomToRect:zoomRect animated:YES];
            }
        } else if(_itemImageView.bounds.size.height < _itemImageView.bounds.size.width){
            CGRect zoomRect = CGRectMake(0, location.y - kScreenHeight / 2, _itemImageView.bounds.size.width, kScreenHeight);
            
            [_scrollView zoomToRect:zoomRect animated:YES];
        } else {
            if (_scrollView.zoomScale == _scrollView.maximumZoomScale) {
                if (_scrollView.maximumZoomScale == 1.0) {
                    CGRect zoomRect = CGRectMake(0, location.y - kScreenHeight / 2, _itemImageView.bounds.size.width, kScreenHeight);
                    [_scrollView zoomToRect:zoomRect animated:YES];
                } else {
                    [_scrollView setZoomScale:1.0 animated:YES];
                }
            } else {
                CGFloat locationX = location.x;
                CGFloat locationY = location.y;
                CGRect zoomRect = CGRectMake(locationX, locationY, 1, 1);
                
                [_scrollView zoomToRect:zoomRect animated:YES];
            }
        }
    }
}

//保证拖动手势和UIScrollView上的拖动手势互不影响
- (BOOL)gestureRecognizer:(UIGestureRecognizer*) gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer {
    if ([gestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    CGPoint point = [recognizer translationInView:self];
    CGPoint location = [recognizer locationInView:self];
    
    UIScrollView *superScrollView = (UIScrollView *)recognizer.view.superview;
    UIView *superView = superScrollView.superview;
    if ((_scrollView.isDragging && _scrollView.contentOffset.y >= 0) || (!_scrollView.isDragging && _scrollView.scrollEnabled && (_scrollView.contentSize.height < kScreenHeight) && (point.y <= 0))|| superScrollView.isDragging) {
        return;
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            _touchBeginPoint = location;
            break;
        case UIGestureRecognizerStateChanged: {
            [_scrollView setScrollEnabled:NO];
            [superScrollView setScrollEnabled:NO];
            double percent = ((point.x<0&&point.y>=0) || (point.x>=0&&point.y>=0)) ? 1 - fabs(point.y) / _scrollView.frame.size.height:1;
            percent = MAX(percent, 0);
            double s = MAX(percent, 0.5);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(point.x/s, point.y/s);
            CGAffineTransform scale = CGAffineTransformMakeScale(s, s);
            _scrollView.transform = CGAffineTransformConcat(translation, scale);
            superView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:percent];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [_scrollView setScrollEnabled:YES];
            [superScrollView setScrollEnabled:YES];
            if (_scrollView.transform.a >= 0.6) {
                _scrollView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                superView.backgroundColor = [UIColor blackColor];
            } else {
                [self singleTap:_singleTap];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.itemImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerContent];
}

#pragma mark 懒加载
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
    }
    return _scrollView;
}
//图片view
- (UIImageView *)itemImageView {
    if (!_itemImageView) {
        _itemImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_itemImageView setContentMode:UIViewContentModeScaleAspectFill];
        _itemImageView.userInteractionEnabled = YES;
        _itemImageView.clipsToBounds = YES;
    }
    return _itemImageView;
}

//播放视频按钮
- (UIButton *)videoPlayBtn {
    if (!_videoPlayBtn) {
        _videoPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_videoPlayBtn addTarget:self action:@selector(recoverPlayClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_videoPlayBtn setImage:kVideoViewPicName(@"icon_center_play") forState:UIControlStateNormal];
    }
    return _videoPlayBtn;
}

- (UITapGestureRecognizer *)singleTap {
    if (!_singleTap) {
        _singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        _singleTap.delegate = self;
        _singleTap.numberOfTapsRequired = 1;
    }
    return _singleTap;
}

- (UITapGestureRecognizer *)doubleTap {
    if (!_doubleTap) {
        _doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        _doubleTap.delegate = self;
        _doubleTap.numberOfTapsRequired = 2;
    }
    return _doubleTap;
}

- (UIPanGestureRecognizer *)panRecognizer {
    if (!_panRecognizer) {
        _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        _panRecognizer.delegate = self;
        _panRecognizer.maximumNumberOfTouches = 1;
        _panRecognizer.minimumNumberOfTouches = 1;
    }
    return _panRecognizer;
}

#pragma mark 进入视频播放回调
- (void)recoverPlayClicked:(UIButton *)sender {
    if (_playerBlock) {
        _singleTap.enabled = NO;
        _doubleTap.enabled = NO;
        _panRecognizer.enabled = NO;
        [_videoPlayBtn removeFromSuperview];
        _itemImageView.image = nil;
        _scrollView.contentOffset = CGPointMake(0, 0);
        _playerBlock(_itemImageUrl, self);
    }
}

@end
