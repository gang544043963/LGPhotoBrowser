//
//  PickerPhoto.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/9/27.
//  Copyright (c) 2015年 L&G. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "LGPhotoAssets.h"


#define LGPhotoImageDidStartLoad @"LGPhotoImageDidStartLoad"
#define LGPhotoImageDidFinishLoad @"LGPhotoImageDidFinishLoad"
#define LGPhotoImageDidFailLoadWithError @"LGPhotoImageDidFailLoadWithError"

@protocol LGPhotoPickerBrowserPhoto <NSObject>


@end

@interface LGPhotoPickerBrowserPhoto : NSObject<LGPhotoPickerBrowserPhoto>

@property (nonatomic, strong) UIView *photoLoadingView;
@property (nonatomic, strong) UIButton *loadOriginButton;

/**
 *  自动适配以下几种数据
 */
@property (nonatomic, strong) id photoObj;
/**
 *  传入对应的UIImageView,记录坐标
 */
@property (strong, nonatomic) UIImageView *toView;
/**
 *  保存相册模型
 */
@property (nonatomic, strong) LGPhotoAssets *asset;
/**
 *  URL地址
 */
@property (nonatomic, strong) NSURL *photoURL;
/**
 *  本地路径
 */
@property (nonatomic, copy) NSString *photoPath;
/**
 *  原图或全屏图，也就是要显示的图
 */
@property (nonatomic, strong) UIImage *photoImage;
/**
 *  缩略图
 */
@property (nonatomic, strong) UIImage *thumbImage;
/**
 *  是否被选中
 */
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL isLoading;
/**
 *  传入一个图片对象，可以是URL/UIImage/NSString，返回一个实例
 */
+ (instancetype)photoAnyImageObjWith:(id)imageObj;
- (instancetype)initWithAnyObj:(id)imageObj;
- (void)loadImageFromFileAsync:(NSString *)path;
- (void)loadImageFromURLAsync:(NSURL *)url;
- (void)notifyImageDidStartLoad;
- (void)notifyImageDidFinishLoad;
- (void)notifyImageDidFailLoadWithError:(NSError *)erro;

@end
