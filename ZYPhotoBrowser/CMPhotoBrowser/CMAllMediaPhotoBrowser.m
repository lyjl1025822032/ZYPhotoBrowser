//
//  CMAllMediaPhotoBrowser.m
//  CmosAllMedia
//
//  Created by 王智垚 on 2017/8/29.
//  Copyright © 2017年 liangscofield. All rights reserved.
//

#import "CMAllMediaPhotoBrowser.h"
#import "CMAllMediaPhotoView.h"
#import "CMAllMediaVideoManager.h"

static CGFloat photoPadding = 10;

#pragma mark 用于视频播放屏幕切换
@implementation UINavigationController (Rotation)
- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}
@end

@interface CMAllMediaPhotoBrowser ()<CMAllMediaPhotoViewDelegate,UIScrollViewDelegate> {
    CMAllMediaVideoManager *videoManager;
    //是否正旋转
    BOOL isRotating;
    //是否是视频
    BOOL isVideo;
    //当前展示视图
    NSMutableSet *_visiblePhotoViews;
    //可重用视图
    NSMutableSet *_reusablePhotoViews;
    
    /** 判断是否滑动有效 **/
    //记录拖拽起始点
    CGFloat startContentOffsetX;
    //记录将要停止终止点
    CGFloat willEndContentOffsetX;
    //记录当前终止点
    CGFloat endContentOffsetX;
}
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)NSArray *imgRectArray;
@property(nonatomic, strong)NSMutableArray *imageProgressArray;
@property(nonatomic, assign)NSInteger curImgIndex;
@end

@implementation CMAllMediaPhotoBrowser

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    videoManager = [CMAllMediaVideoManager sharedInstance];
    isVideo = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  显示浏览器
- (void)showPhotoBrowser {
    [self viewWillShowPhotoBrowser];
    CGFloat bvW = self.scrollView.bounds.size.width - photoPadding;
    CGFloat bvH = self.scrollView.bounds.size.height;
    
    for(NSInteger i = 0; i < _thumbImgArr.count; i++){
        if (i == _tapImgIndex) {
            NSString *url = _sourceUrlArr[_tapImgIndex];
            isVideo = [url.pathExtension isEqualToString:@"mp4"]?YES:NO;
            [self showPhotoViewAtIndex:_tapImgIndex];
        }
    }
    _scrollView.contentSize = CGSizeMake(_thumbImgArr.count * (bvW + photoPadding), bvH);
    _scrollView.contentOffset = CGPointMake(_tapImgIndex * _scrollView.bounds.size.width, 0);
}

//将要显示浏览器的动画操作
- (void)viewWillShowPhotoBrowser {
    //设置模式展示风格
    [self setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    //必要配置
    self.providesPresentationContextTransitionStyle = YES;
    self.definesPresentationContext = YES;
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:self animated:NO completion:^{
        _curImgIndex = _tapImgIndex;
        
        UIImageView *originImageView = _thumbImgArr[_tapImgIndex];
        
        UIImage *animationImg = originImageView.image;
        
        CGRect tapImgRect = [_imgRectArray[_tapImgIndex] CGRectValue];
        
        UIView *animationBgView = [[UIView alloc] initWithFrame:tapImgRect];
        animationBgView.clipsToBounds = YES;
        [self.view addSubview:animationBgView];
        
        UIImageView *animationImgView = [[UIImageView alloc] initWithFrame:animationBgView.bounds];
        animationImgView.contentMode = UIViewContentModeScaleAspectFill;
        animationImgView.image = animationImg;
        [animationBgView addSubview:animationImgView];
        
        CGFloat imageX = 0;
        CGFloat imageY = 0;
        CGFloat imageW = animationBgView.bounds.size.width;
        CGFloat imageH = animationBgView.bounds.size.height;
        
        animationImgView.frame = CGRectMake(imageX, imageY, imageW, imageH);
        
        CGFloat animationW = [UIScreen mainScreen].bounds.size.width;
        CGFloat animationH = [UIScreen mainScreen].bounds.size.height;
        
        CGRect animationRect = CGRectMake(0, 0, animationW, animationH);
        
        CGFloat animationImgY = ([UIScreen mainScreen].bounds.size.height - [UIScreen mainScreen].bounds.size.width * animationImg.size.height / animationImg.size.width) / 2;
        CGFloat animationImgH = [UIScreen mainScreen].bounds.size.width * animationImg.size.height / animationImg.size.width;
        
        if (animationImgY < 0) {
            animationImgY = 0;
        }
        
        [UIView animateWithDuration:0.4 animations:^{
            animationBgView.frame = animationRect;
            animationImgView.frame = CGRectMake(0, animationImgY, animationW, animationImgH);
        } completion:^(BOOL finished) {
            [animationBgView removeFromSuperview];
            _scrollView.hidden = NO;
            [UIViewController attemptRotationToDeviceOrientation];
        }];
    }];
}

//是否成功显示图片
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
    for (CMAllMediaPhotoView *photoView in _visiblePhotoViews) {
        if (photoView.tag - 1 == index) {
            return YES;
        }
    }
    return  NO;
}

//根据下标展示图片
- (void)showPhotoViewAtIndex:(NSInteger)index {
    CGFloat bvW = self.scrollView.bounds.size.width - photoPadding;
    CGFloat bvH = self.scrollView.bounds.size.height;
    
    CMAllMediaPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) {
        photoView = [[CMAllMediaPhotoView alloc] initWithFrame:CGRectMake(index * (_scrollView.bounds.size.width), 0, bvW, bvH)];
    } else {
        photoView.frame = CGRectMake(index * (_scrollView.bounds.size.width), 0, bvW, bvH);
    }
    
    [_visiblePhotoViews addObject:photoView];
    photoView.tag = index + 1;
    photoView.photoViewDelegate = self;
    __weak typeof(self)weakSelf = self;
    photoView.playerBlock = ^(NSString *videoUrl, UIView *windowView) {
        videoManager.closeVideoBlock = ^{
            [weakSelf photoViewSingleTap:index+1];
        };
        [videoManager playWithUrl:[NSURL URLWithString:videoUrl] andShowView:windowView];
    };
    [_scrollView addSubview:photoView];
    
    UIImageView *originImageView = _thumbImgArr[index];
    
    photoView.itemImage = originImageView.image;
    photoView.itemImageProgress = [_imageProgressArray[index] floatValue];
    photoView.itemImageUrl = _sourceUrlArr[index];
}

- (CMAllMediaPhotoView *)dequeueReusablePhotoView {
    CMAllMediaPhotoView *photoView = [_reusablePhotoViews anyObject];
    if (photoView) {
        [_reusablePhotoViews removeObject:photoView];
    }
    
    return photoView;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutPhotoBrowser];
}

- (void)layoutPhotoBrowser {
    CGPoint point = _scrollView.contentOffset;
    CGFloat offsetX = point.x;
    NSInteger curIndex = offsetX / _scrollView.bounds.size.width;
    _scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width + 10, self.view.bounds.size.height);
    CGFloat bvW = _scrollView.bounds.size.width - 10;
    CGFloat bvH = _scrollView.bounds.size.height;
    
    for (CMAllMediaPhotoView *photoView in _visiblePhotoViews) {
        
        photoView.frame = CGRectMake((photoView.tag - 1) * (bvW + 10), 0, bvW, bvH);
        [photoView resetSize];
    }
    
    _scrollView.contentSize = CGSizeMake(_thumbImgArr.count * (bvW + 10), bvH);
    _scrollView.contentOffset = CGPointMake(curIndex * (bvW + 10), 0);
}

- (void)showPhotos {
    if (_thumbImgArr.count == 1) {
        return;
    }
    
    if (isRotating) {
        return;
    }
    
    CGRect visibleBounds = _scrollView.bounds;
    NSInteger firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+photoPadding) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-photoPadding-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _thumbImgArr.count) firstIndex = _thumbImgArr.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _thumbImgArr.count) lastIndex = _thumbImgArr.count - 1;
    
    NSInteger photoViewIndex;
    for (CMAllMediaPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = photoView.tag - 1;
        if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
            [_reusablePhotoViews addObject:photoView];
            [photoView removeFromSuperview];
        }
    }
    
    [_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
    
    for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingPhotoViewAtIndex:index]) {
            [self showPhotoViewAtIndex:index];
        }
    }
}

#pragma mark CMAllMediaPhotoViewDelegate
- (void)photoViewSingleTap:(NSInteger)index {
    CMAllMediaPhotoView *photoView = [self dequeueReusablePhotoView];
    NSInteger curIndex = index - 1;
    _scrollView.hidden = YES;
    
    UIImageView *originImageView = _thumbImgArr[curIndex];
    UIImage *animationImg = originImageView.image;
    
    UIView *animationBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    animationBgView.clipsToBounds = YES;
    
    [[UIApplication sharedApplication].keyWindow addSubview:animationBgView];
    
    CGFloat animationImgY = (self.view.bounds.size.height - self.view.bounds.size.width * animationImg.size.height / animationImg.size.width) / 2;
    CGFloat animationImgH = self.view.bounds.size.width * animationImg.size.height / animationImg.size.width;
    
    if (animationImgY < 0) {
        animationImgY = 0;
    }
    
    UIImageView *animationImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, animationImgY, self.view.bounds.size.width, animationImgH)];
    animationImgView.contentMode = UIViewContentModeScaleAspectFill;
    animationImgView.image = animationImg;
    [animationBgView addSubview:animationImgView];
    
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = [_imgRectArray[curIndex] CGRectValue].size.width;
    CGFloat imageH = [_imgRectArray[curIndex] CGRectValue].size.height;
    
    [UIView animateWithDuration:0.4 animations:^{
        animationBgView.frame = [_imgRectArray[curIndex] CGRectValue];
        animationImgView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    } completion:^(BOOL finished) {
        [videoManager stop];
        _scrollView.delegate = nil;
        photoView.photoViewDelegate = nil;
        [animationBgView removeFromSuperview];
    }];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (BOOL)photoIsShowingPhotoViewAtIndex:(NSUInteger)index {
    return [self isShowingPhotoViewAtIndex:index];
}

- (void)updatePhotoProgress:(CGFloat)progress andIndex:(NSInteger)index {
    _imageProgressArray[index] = [NSNumber numberWithFloat:progress];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self showPhotos];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    startContentOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    willEndContentOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    endContentOffsetX = scrollView.contentOffset.x;
    if ((endContentOffsetX < willEndContentOffsetX && willEndContentOffsetX < startContentOffsetX) || (endContentOffsetX > willEndContentOffsetX && willEndContentOffsetX > startContentOffsetX)) {
        for (UIView *view in scrollView.subviews) {
            if ([view isKindOfClass:[CMAllMediaPhotoView class]]) {
                CMAllMediaPhotoView *photoView = (CMAllMediaPhotoView *)view;
                if ([photoView.itemImageUrl.pathExtension isEqualToString:@"mp4"]) {
                    NSNumber *orientationUnknown = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
                    [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
                    NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
                    [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
                    isVideo = YES;
                } else {
                    isVideo = NO;
                }
            }
        }
        [videoManager stop];
    }
}

#pragma mark UIViewController (UIViewControllerRotation)
- (BOOL)shouldAutorotate {
    return !isVideo;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    isRotating = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    isRotating = NO;
}

//隐藏状态栏
- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark 懒加载
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width + photoPadding, self.view.bounds.size.height)];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.hidden = YES;
        _scrollView.delegate = self;
        [self.view addSubview:_scrollView];
    }
    return _scrollView;
}

#pragma mark private -- setter
- (void)setThumbImgArr:(NSArray *)thumbImgArr {
    _thumbImgArr = thumbImgArr;
    if (thumbImgArr.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    
    NSMutableArray *tmpImgRectArray = [NSMutableArray array];
    for(UIView *view in thumbImgArr){
        [tmpImgRectArray addObject:[NSValue valueWithCGRect:[view convertRect:view.bounds toView:nil]]];
    }
    _imgRectArray = [tmpImgRectArray copy];
}

- (void)setSourceUrlArr:(NSArray *)sourceUrlArr {
    _sourceUrlArr = sourceUrlArr;
    if (sourceUrlArr.count > 1) {
        NSMutableArray *array = [NSMutableArray array];
        
        for(int i = 0; i < sourceUrlArr.count; i++) {
            [array addObject:[NSNumber numberWithFloat:0.0]];
            
        }
        _imageProgressArray = array;
    }
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
