//
//  LGAssets.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface LGPhotoAssets : NSObject

@property (nonatomic) ALAsset *asset;
/**
 *  缩略图
 */
- (UIImage *)thumbImage;
/**
 *  压缩原图
 */
- (UIImage *)compressionImage;
/**
 *  原图
 */
- (UIImage *)originImage;

/**
 * 全屏图
 */
- (UIImage *)fullResolutionImage;
/**
 *  获取是否是视频类型, Default = false
 */
@property (nonatomic, assign) BOOL isVideoType;
/**
 *  获取相册的URL
 */
- (NSURL *)assetURL;

@end
