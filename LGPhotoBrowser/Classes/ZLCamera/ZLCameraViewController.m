//
//  BQCamera.m
//  BQCommunity
//
//  Created by ZL on 14-9-11.
//  Copyright (c) 2014年 beiqing. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>
#import <objc/message.h>
#import "ZLCameraViewController.h"
#import "ZLCameraImageView.h"
#import "ZLCameraView.h"
#import "LGPhoto.h"
#import "LGCameraImageView.h"

typedef void(^codeBlock)();
static CGFloat ZLCameraColletionViewW = 80;
static CGFloat ZLCameraColletionViewPadding = 20;
static CGFloat BOTTOM_HEIGHT = 60;

@interface ZLCameraViewController () <UIActionSheetDelegate,UICollectionViewDataSource,UICollectionViewDelegate,AVCaptureMetadataOutputObjectsDelegate,ZLCameraImageViewDelegate,ZLCameraViewDelegate,LGPhotoPickerBrowserViewControllerDataSource,LGPhotoPickerBrowserViewControllerDelegate,LGCameraImageViewDelegate>

@property (weak,nonatomic) ZLCameraView *caramView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIViewController *currentViewController;

// Datas
@property (strong, nonatomic) NSMutableArray *images;
@property (strong, nonatomic) NSMutableDictionary *dictM;

// AVFoundation
@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureStillImageOutput *captureOutput;
@property (strong, nonatomic) AVCaptureDevice *device;

@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (nonatomic, assign) XGImageOrientation imageOrientation;
@property (nonatomic, assign) NSInteger flashCameraState;

@property (nonatomic, strong) UIButton *flashBtn;
@end

@implementation ZLCameraViewController

#pragma mark - Getter
#pragma mark Data
- (NSMutableArray *)images{
    if (!_images) {
        _images = [NSMutableArray array];
    }
    return _images;
}

- (NSMutableDictionary *)dictM{
    if (!_dictM) {
        _dictM = [NSMutableDictionary dictionary];
    }
    return _dictM;
}

#pragma mark View
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(ZLCameraColletionViewW, ZLCameraColletionViewW);
        layout.minimumLineSpacing = ZLCameraColletionViewPadding;
        
        CGFloat collectionViewH = ZLCameraColletionViewW;
        CGFloat collectionViewY = self.caramView.height - collectionViewH - 10;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, collectionViewY, self.view.width, collectionViewH)
                                                              collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [self.caramView addSubview:collectionView];
        self.collectionView = collectionView;
    }
    return _collectionView;
}

- (void) initialize
{
    //1.创建会话层
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    self.captureOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [self.captureOutput setOutputSettings:outputSettings];
    
    // Session
    self.session = [[AVCaptureSession alloc]init];
    
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([self.session canAddInput:self.input])
    {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:_captureOutput])
    {
        [self.session addOutput:_captureOutput];
    }
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = viewWidth / 480 * 640;;
    self.preview =[AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.preview.frame = CGRectMake(0, 40,viewWidth, viewHeight);
    
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    ZLCameraView *caramView = [[ZLCameraView alloc] initWithFrame:CGRectMake(0, 40, viewWidth, viewHeight)];
    caramView.backgroundColor = [UIColor clearColor];
    caramView.delegate = self;
    [self.view addSubview:caramView];
    [self.view.layer insertSublayer:self.preview atIndex:0];
    self.caramView = caramView;
}

- (void)cameraDidSelected:(ZLCameraView *)camera{
    [self.device lockForConfiguration:nil];
    [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
    [self.device setFocusPointOfInterest:CGPointMake(50,50)];
    //操作完成后，记得进行unlock。
    [self.device unlockForConfiguration];
}

//对焦回调
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        NSLog(@"qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq");
    }
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self initialize];
    [self setup];
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark 初始化按钮
- (UIButton *) setupButtonWithImageName : (NSString *) imageName andX : (CGFloat ) x{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor clearColor];
    button.width = 80;
    button.y = 0;
    button.height = self.topView.height;
    button.x = x;
    [self.view addSubview:button];
    return button;
}

#pragma mark -初始化界面
- (void) setup{
    CGFloat width = 50;
    CGFloat margin = 20;
    
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor blackColor];
    topView.frame = CGRectMake(0, 0, self.view.width, 40);
    [self.view addSubview:topView];
    self.topView = topView;
    
    // 头部View
    UIButton *deviceBtn = [self setupButtonWithImageName:@"xiang.png" andX:self.view.width - margin - width];
    [deviceBtn addTarget:self action:@selector(changeCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *flashBtn = [self setupButtonWithImageName:@"shanguangdeng2.png" andX:10];
    [flashBtn addTarget:self action:@selector(flashCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
    [flashBtn setTitle:@"关闭" forState:UIControlStateNormal];
    _flashBtn = flashBtn;
    
//    UIButton *closeBtn = [self setupButtonWithImageName:@"shanguangdeng2" andX:60];
//    [closeBtn addTarget:self action:@selector(closeFlashlight:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 底部View
    UIView *controlView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height-BOTTOM_HEIGHT, self.view.width, BOTTOM_HEIGHT)];
    controlView.backgroundColor = [UIColor blackColor];
    controlView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.controlView = controlView;
    
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = controlView.bounds;
    contentView.backgroundColor = [UIColor blackColor];
    contentView.alpha = 0.3;
    [controlView addSubview:contentView];
    
    CGFloat x = (self.view.width - width) / 3;
    //取消
    UIButton *cancalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancalBtn.frame = CGRectMake(0, 0, x, controlView.height);
    [cancalBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancalBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:cancalBtn];
    //拍照
    UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = CGRectMake(x+margin, margin / 4, x, controlView.height - margin / 2);
    cameraBtn.showsTouchWhenHighlighted = YES;
    cameraBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [cameraBtn setImage:[UIImage imageNamed:@"paizhao.png"] forState:UIControlStateNormal];
    [cameraBtn addTarget:self action:@selector(stillImage:) forControlEvents:UIControlEventTouchUpInside];
    [controlView addSubview:cameraBtn];
    // 完成
    if (self.cameraType == ZLCameraContinuous) {
        UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        doneBtn.frame = CGRectMake(self.view.width - 2 * margin - width, 0, width, controlView.height);
        [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [doneBtn addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
        [controlView addSubview:doneBtn];
    }
    
    [self.view addSubview:controlView];
}

- (NSInteger ) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger ) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.images.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    ZLCamera *camera = self.images[indexPath.item];
    
    ZLCameraImageView *lastView = [cell.contentView.subviews lastObject];
    if(![lastView isKindOfClass:[ZLCameraImageView class]]){
        // 解决重用问题
        UIImage *image = camera.thumbImage;
        ZLCameraImageView *imageView = [[ZLCameraImageView alloc] init];
        imageView.delegatge = self;
        imageView.edit = YES;
        imageView.image = image;
        imageView.frame = cell.bounds;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.contentView addSubview:imageView];
    }
    
    lastView.image = camera.thumbImage;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LGPhotoPickerBrowserViewController *browserVc = [[LGPhotoPickerBrowserViewController alloc] init];
    browserVc.dataSource = self;
    browserVc.delegate = self;
    browserVc.showType = LGShowImageTypeImageBroswer;
    browserVc.currentIndexPath = [NSIndexPath indexPathForItem:indexPath.item inSection:0];
    [self presentViewController:browserVc animated:NO completion:nil];
}


#pragma mark - <ZLPhotoPickerBrowserViewControllerDataSource>
- (NSInteger)photoBrowser:(LGPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{
    return self.images.count;
}

- (LGPhotoPickerBrowserPhoto *) photoBrowser:(LGPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    
    id imageObj = [[self.images objectAtIndex:indexPath.row] photoImage];
    LGPhotoPickerBrowserPhoto *photo = [LGPhotoPickerBrowserPhoto photoAnyImageObjWith:imageObj];
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    
    UIImageView *imageView = [[cell.contentView subviews] lastObject];
    photo.toView = imageView;
    photo.thumbImage = imageView.image;
    
    return photo;
}

- (void)deleteImageView:(ZLCameraImageView *)imageView{
    NSMutableArray *arrM = [self.images mutableCopy];
    for (ZLCamera *camera in self.images) {
        UIImage *image = camera.thumbImage;
        if ([image isEqual:imageView.image]) {
            [arrM removeObject:camera];
        }
    }
    self.images = arrM;
    [self.collectionView reloadData];
}

- (void)showPickerVc:(UIViewController *)vc{
    __weak typeof(vc)weakVc = vc;
    if (weakVc != nil) {
        [weakVc presentViewController:self animated:YES completion:nil];
    }
}

-(void)Captureimage
{
    //get connection
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.captureOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    
    //get UIImage
    [self.captureOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:
     ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
         
         CFDictionaryRef exifAttachments =
         CMGetAttachment(imageSampleBuffer, kCGImagePropertyExifDictionary, NULL);
         if (exifAttachments) {
             // Do something with the attachments.
         }
         
         // Continue as appropriate.
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *t_image = [UIImage imageWithData:imageData];
         t_image = [self cutImage:t_image];
         t_image = [self fixOrientation:t_image];
         NSData *data = UIImageJPEGRepresentation(t_image, 0.3);
         ZLCamera *camera = [[ZLCamera alloc] init];
         camera.photoImage = t_image;
         camera.thumbImage = [UIImage imageWithData:data];
         
         if (self.cameraType == ZLCameraSingle) {
             [self.images removeAllObjects];//由于当前只需要一张图片2015-11-6
             [self.images addObject:camera];
             [self displayImage:camera.photoImage];
         } else if (self.cameraType == ZLCameraContinuous) {
             [self.images addObject:camera];
             [self.collectionView reloadData];
             [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:self.images.count - 1 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionRight];
         }
     }];
}

//裁剪image
- (UIImage *)cutImage:(UIImage *)srcImg {
    //注意：这个rect是指横屏时的rect，即屏幕对着自己，home建在右边
    CGRect rect = CGRectMake((srcImg.size.height / CGRectGetHeight(self.view.frame)) * 70, 0, srcImg.size.width * 1.33, srcImg.size.width);
    CGImageRef subImageRef = CGImageCreateWithImageInRect(srcImg.CGImage, rect);
    CGFloat subWidth = CGImageGetWidth(subImageRef);
    CGFloat subHeight = CGImageGetHeight(subImageRef);
    CGRect smallBounds = CGRectMake(0, 0, subWidth, subHeight);
    //旋转后，画出来
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, subWidth);
    transform = CGAffineTransformRotate(transform, -M_PI_2);
    CGContextRef ctx = CGBitmapContextCreate(NULL, subHeight, subWidth,
                                             CGImageGetBitsPerComponent(subImageRef), 0,
                                             CGImageGetColorSpace(subImageRef),
                                             CGImageGetBitmapInfo(subImageRef));
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, smallBounds, subImageRef);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
    
//    CGImageRef subImageRef = CGImageCreateWithImageInRect(srcImg.CGImage, rect);
//    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
//    
//    UIGraphicsBeginImageContext(smallBounds.size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextDrawImage(context, smallBounds, subImageRef);
//    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef scale:1 orientation:UIImageOrientationRight];//由于直接从subImageRef中得到uiimage的方向是逆时针转了90°的
//    UIGraphicsEndImageContext();
//    CGImageRelease(subImageRef);
//    
//    return smallImage;
}

//旋转image
- (UIImage *)fixOrientation:(UIImage *)srcImg
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGFloat width = srcImg.size.width;
    CGFloat height = srcImg.size.height;
    
    CGContextRef ctx;
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationUnknown:
        case UIDeviceOrientationFaceUp:
        case UIDeviceOrientationFaceDown:
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown: //竖屏，不旋转
            ctx = CGBitmapContextCreate(NULL, width, height,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        case UIDeviceOrientationLandscapeLeft:  //横屏，home键在右手边，逆时针旋转90°
            transform = CGAffineTransformTranslate(transform, height, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            ctx = CGBitmapContextCreate(NULL, height, width,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        case UIDeviceOrientationLandscapeRight:  //横屏，home键在左手边，顺时针旋转90°
            transform = CGAffineTransformTranslate(transform, 0, width);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            ctx = CGBitmapContextCreate(NULL, height, width,
                                        CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                        CGImageGetColorSpace(srcImg.CGImage),
                                        CGImageGetBitmapInfo(srcImg.CGImage));
            break;
            
        default:
            break;
    }
    
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx, CGRectMake(0,0,width,height), srcImg.CGImage);
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    
    return img;
}

//LG
- (void)displayImage:(UIImage *)images {
    LGCameraImageView *view = [[LGCameraImageView alloc] initWithFrame:self.view.frame];
    view.delegate = self;
    view.imageOrientation = _imageOrientation;
    view.imageToDisplay = images;
    [self.view addSubview:view];
    
}

-(void)CaptureStillImage
{
    [self  Captureimage];
}

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    return nil;
}

- (void)changeCameraDevice:(id)sender
{
    // 翻转
    [UIView beginAnimations:@"animation" context:nil];
    [UIView setAnimationDuration:.5f];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
    [UIView commitAnimations];
    
    NSArray *inputs = self.session.inputs;
    for ( AVCaptureDeviceInput *input in inputs ) {
        AVCaptureDevice *device = input.device;
        if ( [device hasMediaType:AVMediaTypeVideo] ) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            
            if (position == AVCaptureDevicePositionFront)
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            else
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
            [self.session beginConfiguration];
            
            [self.session removeInput:input];
            [self.session addInput:newInput];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.session commitConfiguration];
            break;
        }
    }
}

- (void) flashLightModel : (codeBlock) codeBlock{
    if (!codeBlock) return;
    [self.session beginConfiguration];
    [self.device lockForConfiguration:nil];
    codeBlock();
    [self.device unlockForConfiguration];
    [self.session commitConfiguration];
    [self.session startRunning];
}
- (void) flashCameraDevice:(UIButton *)sender{
    if (_flashCameraState < 0) {
        _flashCameraState = 0;
    }
    _flashCameraState ++;
    if (_flashCameraState >= 4) {
        _flashCameraState = 0;
    }
    AVCaptureFlashMode mode;
    
    switch (_flashCameraState) {
        case 1:
            mode = AVCaptureFlashModeOn;
            [_flashBtn setTitle:@"打开" forState:UIControlStateNormal];
            break;
        case 2:
            mode = AVCaptureFlashModeAuto;
            [_flashBtn setTitle:@"自动" forState:UIControlStateNormal];
            break;
        case 3:
            mode = AVCaptureFlashModeOff;
            [_flashBtn setTitle:@"关闭" forState:UIControlStateNormal];
            break;
        default:
            mode = AVCaptureFlashModeOff;
            [_flashBtn setTitle:@"关闭" forState:UIControlStateNormal];
            break;
    }
    if ([self.device isFlashModeSupported:mode])
    {
        [self flashLightModel:^{
            [self.device setFlashMode:mode];
        }];
    }
}

- (void)cancel:(id)sender
{
    [self flashLightModel:^{
        [self.device setFlashMode:AVCaptureFlashModeOff];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//拍照
- (void)stillImage:(id)sender
{
    // 判断图片的限制个数
    if (self.maxCount > 0 && self.images.count >= self.maxCount) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"拍照的个数不能超过%ld",(long)self.maxCount]delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
        return ;
    }
    
    [self Captureimage];
//    UIView *maskView = [[UIView alloc] init];
//    maskView.frame = self.view.bounds;
//    maskView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:maskView];
//    [UIView animateWithDuration:.5 animations:^{
//        maskView.alpha = 0;
//    } completion:^(BOOL finished) {
//        [maskView removeFromSuperview];
//    }];
}

- (BOOL)shouldAutorotate{
    return YES;
}

#pragma mark - 屏幕
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
// 支持屏幕旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
// 画面一开始加载时就是竖向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - XGCameraImageViewDelegate
- (void)xgCameraImageViewSendBtnTouched {
    [self doneAction];
}

- (void)xgCameraImageViewCancleBtnTouched {
    [self.images removeAllObjects];
}
//完成、取消
- (void)doneAction
{
    //关闭相册界面
    if(self.callback){
        self.callback(self.images);
    }
    [self cancel:nil];
}
@end

