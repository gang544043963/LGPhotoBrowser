//
//  LGPhotoPickerBrowserPhotoScrollView.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import "LGPhotoPickerBrowserPhotoScrollView.h"
#import "LGPhotoPickerDatas.h"
#import "DACircularProgressView.h"
#import "LGPhotoPickerCommon.h"
#import "LGPhotoRect.h"
#import "UIImageView+WebCache.h"


#define ORIGINALBTN_TAG 9999
#define LOADINGVIEW_TAG 8888

// Private methods and properties
@interface LGPhotoPickerBrowserPhotoScrollView () {
    LGPhotoPickerBrowserPhotoView *_tapView; // for background taps
    CGFloat maxScale;
    CGFloat minScale;
    CGFloat zoomScaleFromInit;
    BOOL isBigScale;
    BOOL isNotFirst;
}

@property (nonatomic, assign) CGFloat progress;
@property (strong,nonatomic) DACircularProgressView *progressView;
@property (nonatomic, assign) BOOL isLoadingDone;

@end

@implementation LGPhotoPickerBrowserPhotoScrollView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LGPhotoImageDidStartLoad object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LGPhotoImageDidFinishLoad object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:LGPhotoImageDidFailLoadWithError object:nil];
}

- (id)init{
    if ((self = [super init])) {
        
        // Setup
        // Tap view for background
        _tapView = [[LGPhotoPickerBrowserPhotoView alloc] initWithFrame:self.bounds];
        _tapView.tapDelegate = self;
        _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tapView.backgroundColor = [UIColor blackColor];
        [self addSubview:_tapView];
        
        // Image view
        _photoImageView = [[LGPhotoPickerBrowserPhotoImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.tapDelegate = self;
        _photoImageView.contentMode = UIViewContentModeCenter;
        _photoImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_photoImageView];
        
        // Setup
        self.backgroundColor = [UIColor blackColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        //Gesture  最后面添加
        UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGesture:)];
        [self addGestureRecognizer:longGesture];
        
        DACircularProgressView *progressView = [[DACircularProgressView alloc] init];
        progressView.frame = CGRectMake(0, 0, LGPickerProgressViewW, LGPickerProgressViewH);
        progressView.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
        progressView.roundedCorners = YES;
        if (iOS7gt) {
            progressView.thicknessRatio = 0.1;
            progressView.roundedCorners = NO;
        } else {
            progressView.thicknessRatio = 0.2;
            progressView.roundedCorners = YES;
        }
        progressView.hidden = YES;
        
        [self addSubview:progressView];
        self.progressView = progressView;
        
        //addObservers
        [self addObservers];
    }
    return self;
}

#pragma mark - setProgress
- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    
    self.progressView.hidden = NO;
    if (progress == 0) return ;
    if (progress / 1.0 != 1.0) {
        [self.progressView setProgress:progress animated:YES];
    }else{
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
}

- (void)addObservers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDownloadStartAction)
                                                 name:LGPhotoImageDidStartLoad
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDownloadDidFinishAction)
                                                 name:LGPhotoImageDidFinishLoad
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDownloadDidFailAction)
                                                 name:LGPhotoImageDidFailLoadWithError
                                               object:nil];
}

- (void)imageDownloadStartAction{
}

- (void)imageDownloadDidFinishAction{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _photoImageView.image = self.photo.photoImage;
        self.isLoadingDone = YES;
        [self displayImage];
    });
}

- (void)imageDownloadDidFailAction{

}

- (void)longGesture:(UILongPressGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([self.photoScrollViewDelegate respondsToSelector:@selector(pickerPhotoScrollViewDidLongPressed:)]) {
            [self.photoScrollViewDelegate pickerPhotoScrollViewDidLongPressed:self];
        }
    }
}



- (void)setPhoto:(LGPhotoPickerBrowserPhoto *)photo{
    _photo = photo;
    
    __weak typeof(self) weakSelf = self;
    
    if (photo.photoPath.length) {
        //缓存路劲获取
        [photo loadImageFromFileAsync:photo.photoPath];
        _photoImageView.image = photo.photoImage;
        [self displayImage];
    } else if (photo.photoURL.absoluteString.length) {
        
        [photo loadImageFromURLAsync:photo.photoURL];
        
        _photoImageView.image = photo.photoImage;
        
        
        // 本地相册
        NSRange photoRange = [photo.photoURL.absoluteString rangeOfString:@"assets-library"];
        if (photoRange.location != NSNotFound){
            [[LGPhotoPickerDatas defaultPicker] getAssetsPhotoWithURLs:photo.photoURL callBack:^(UIImage *obj) {
                photo.photoImage = obj;
                _photoImageView.image = obj;
                self.isLoadingDone = YES;
                [weakSelf displayImage];
            }];
        } else {
            UIImage *thumbImage = photo.thumbImage;
            if (thumbImage == nil) {
                thumbImage = _photoImageView.image;
            }else{
                photo.photoImage = thumbImage;
                _photoImageView.image = thumbImage;
            }
            
            _photoImageView.contentMode = UIViewContentModeScaleAspectFit;
            _photoImageView.frame = [LGPhotoRect setMaxMinZoomScalesForCurrentBoundWithImageView:_photoImageView];
            
            if (_photoImageView.image == nil) {
                [self setProgress:0.01];
            }

            // 网络URL
            [_photoImageView sd_setImageWithURL:photo.photoURL placeholderImage:thumbImage options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                [self setProgress:(double)receivedSize / expectedSize];
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [self setProgress:1.0];
                self.isLoadingDone = YES;
                if (image) {
                    _photoImageView.image = image;
                    [weakSelf displayImage];
                }else{
                    [_photoImageView removeScaleBigTap];
                    _photoImageView.image = [UIImage imageNamed:@"icon_pic_break.png"];
                    [weakSelf displayImage];
                }
            }];
        }
        
    }  else {
        _photoImageView.image = photo.photoImage;
        self.isLoadingDone = YES;
        [self displayImage];
    }
}

#pragma mark - Image
// Get and display image
- (void)displayImage {
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    self.contentSize = CGSizeMake(0, 0);
    
    // Get image from browser as it handles ordering of fetching
    UIImage *img = _photoImageView.image;
    if (img) {
        
        // Set image
        _photoImageView.image = img;
        _photoImageView.hidden = NO;
        
        // Setup photo frame
        CGRect photoImageViewFrame;
        photoImageViewFrame.origin = CGPointZero;
        photoImageViewFrame.size = img.size;
        _photoImageView.frame = photoImageViewFrame;
        self.contentSize = photoImageViewFrame.size;
        
        // Set zoom to minimum zoom
        [self setMaxMinZoomScalesForCurrentBounds];
        // 安装‘查看原图’按钮
        [self layoutPhotoLoadOriginButton];
    }
    [self setNeedsLayout];
}

- (void)layoutPhotoLoadOriginButton
{
    [[self.superview viewWithTag:ORIGINALBTN_TAG] removeFromSuperview];
    if ([_photo respondsToSelector:@selector(loadOriginButton)])
    {
        UIButton *_loadOriginButton = (UIButton *)[_photo loadOriginButton];
        if (_loadOriginButton)
        {
            [_loadOriginButton setTag:ORIGINALBTN_TAG];
            [_loadOriginButton setFrame:CGRectMake((SCREEN_WIDTH - 148)/2, SCREEN_HEIGHT-42, 148, 32)];
            NSLog(@"%@",[self.superview class]);
            [self.superview addSubview:_loadOriginButton];
            [self.superview bringSubviewToFront:_loadOriginButton];
        }
    }
}

#pragma mark - Loading Progress
#pragma mark - Setup
- (CGFloat)initialZoomScaleWithMinScale {
    CGFloat zoomScale = self.minimumZoomScale;
    if (_photoImageView) {
        // Zoom image to fill if the aspect ratios are fairly similar
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _photoImageView.image.size;
        CGFloat boundsAR = boundsSize.width / boundsSize.height;
        CGFloat imageAR = imageSize.width / imageSize.height;
        CGFloat xScale = boundsSize.width / imageSize.width;

        if (ABS(boundsAR - imageAR) < 0.17) {
            zoomScale = xScale;
        }
    }
    return zoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds {
    // Reset
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    // Bail
    if (_photoImageView.image == nil) return;
    
    // Sizes
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.frame.size;
    _photoImageView.contentMode = UIViewContentModeCenter;
    
    // Calculate Min
    CGFloat xScale = boundsSize.width / imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / imageSize.height;  // the scale needed to perfectly fit the image height-wise
    minScale = MIN(xScale, yScale);                 // use minimum of these to allow the image to become fully visible
    // If image is smaller than the screen then ensure we show it at
    // min scale of 1
    if (xScale > 1 && yScale > 1) {
        minScale = 1.0;
    }
    maxScale = 2*minScale;
    
    if (imageSize.height > imageSize.width) {//超长图特殊处理
        if (imageSize.height/imageSize.width > [[UIScreen mainScreen] bounds].size.height/SCREEN_WIDTH) {
            minScale = xScale;
            maxScale = xScale*2;
        }
    }else if (imageSize.height < imageSize.width) {//超宽图特殊处理
        _photoImageView.contentMode = UIViewContentModeScaleAspectFill;
        if ((CGFloat)imageSize.width/imageSize.height > (CGFloat)16.0f/9.0f) {
            minScale = xScale;
            
            //            minScale = yScale/2; //超宽图默认高度为屏幕高度一半
        }
        maxScale = yScale;
    }
    
    // Set
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    zoomScaleFromInit = minScale;
    // Reset position
    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews {
    // Super
    [super layoutSubviews];
    
    // Center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
        _photoImageView.frame = frameToCenter;
    
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch{
    [self disMissTap:nil];
}

#pragma mark - disMissTap
- (void) disMissTap:(UITapGestureRecognizer *)tap{
    if (self.callback){
        self.callback(nil);
    }else if ([self.photoScrollViewDelegate respondsToSelector:@selector(pickerPhotoScrollViewDidSingleClick:)]) {
        [self.photoScrollViewDelegate pickerPhotoScrollViewDidSingleClick:self];
    }
}

// Image View
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {

    CGSize imageViewSize = _photoImageView.frame.size;
    if (imageViewSize.height < imageViewSize.width) {//宽图特殊处理  宽图放大 高要变成屏幕高度
        [self handleImageViewDoubleTap:[touch locationInView:nil]];//locationInView:传nil 传gesture.view坐标不对
    }else{
        [self handleImageViewDoubleTap:[touch locationInView:imageView]];
    }
}

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch{
    [self disMissTap:nil];
}

- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    // Translate touch location to image view location
    CGFloat touchX = [touch locationInView:view].x;
    CGFloat touchY = [touch locationInView:view].y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleImageViewDoubleTap:CGPointMake(touchX, touchY)];
}

#pragma mark - Tap Detection

- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    CGSize imageViewSize = _photoImageView.frame.size;
    if (imageViewSize.height < imageViewSize.width) {//宽图特殊处理  宽图放大 高要变成屏幕高度
        [self handleImageViewDoubleTap:[gesture locationInView:nil]];//locationInView:传nil 传gesture.view坐标不对
    }else{
        [self handleImageViewDoubleTap:[gesture locationInView:gesture.view]];
    }
}

- (void)handleImageViewDoubleTap:(CGPoint)touchPoint
{
    CGSize imageViewSize = _photoImageView.frame.size;
    CGSize imageSize = _photoImageView.image.size;
    CGSize boundsSize = self.bounds.size;
    
    if (imageViewSize.height < imageViewSize.width) {//宽图特殊处理  宽图放大 高要变成屏幕高度
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.30];
        
        CGFloat photoImageViewX = 0;
        CGFloat photoImageViewY = 0;
        CGFloat photoImageViewWidth = 0;
        CGFloat photoImageViewHeight = 0;
        
        if (!isBigScale) {
            photoImageViewWidth = boundsSize.height * ((CGFloat)imageSize.width/imageSize.height);
            photoImageViewHeight = boundsSize.height;
            
            isBigScale = YES;
        }else{
            //            if ((CGFloat)imageSize.width/imageSize.height > (CGFloat)16.0f/9.0f) {  //超宽图默认高度为 屏幕高度的一半
            //                photoImageViewWidth = boundsSize.height * ((CGFloat)imageSize.width/imageSize.height)/2;
            //                photoImageViewHeight =  boundsSize.height/2;
            //            }else{
            photoImageViewWidth = boundsSize.width;
            photoImageViewHeight =  boundsSize.width * ((CGFloat)imageSize.height/imageSize.width);
            //            }
            
            isBigScale = NO;
        }
        
        // Horizontally
        if (photoImageViewWidth < boundsSize.width) {
            photoImageViewX = floorf((boundsSize.width - photoImageViewWidth) / 2.0);
        } else {
            photoImageViewX = 0;
        }
        
        // Vertically
        if (photoImageViewHeight < boundsSize.height) {
            photoImageViewY = floorf((boundsSize.height - photoImageViewHeight) / 2.0);
        } else {
            photoImageViewY = 0;
        }
        
        _photoImageView.frame = CGRectMake(photoImageViewX, photoImageViewY, photoImageViewWidth, photoImageViewHeight);
        
        CGFloat touchPointToImageViewX = touchPoint.x + self.contentOffset.x;
        CGFloat contentOffsetX = touchPointToImageViewX * photoImageViewWidth/imageViewSize.width - touchPoint.x;
        self.contentSize = _photoImageView.frame.size;
   
        if (contentOffsetX > photoImageViewWidth) {
            contentOffsetX = photoImageViewWidth;
        }
        
        if (contentOffsetX < 0) {
            contentOffsetX = 0;
        }
        [self setContentOffset:CGPointMake(contentOffsetX, 0)];
        
        
        [UIView commitAnimations];
    }else{
        if (!isBigScale) {
            float newScale = maxScale;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:touchPoint];
            [self zoomToRect:zoomRect animated:YES];
            isBigScale = YES;
        }else{
            float newScale = minScale;
            CGRect zoomRect = [self zoomRectForScale:newScale withCenter:touchPoint];
            [self zoomToRect:zoomRect animated:YES];
            isBigScale = NO;
        }
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);

    return zoomRect;
}
@end
