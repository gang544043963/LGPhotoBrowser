//
//  LGPickerDatas.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>

@class LGPhotoPickerGroup;

// 回调
typedef void(^groupCallBackBlock)(id obj);

@interface LGPhotoPickerDatas : NSObject

/**
 *  获取所有组
 */
+ (instancetype) defaultPicker;

/**
 * 获取所有组对应的图片
 */
- (void) getAllGroupWithPhotos : (groupCallBackBlock ) callBack;

/**
 * 获取所有组对应的Videos
 */
- (void) getAllGroupWithVideos : (groupCallBackBlock ) callBack;

/**
 *  传入一个组获取组里面的Asset
 */
- (void) getGroupPhotosWithGroup : (LGPhotoPickerGroup *) pickerGroup finished : (groupCallBackBlock ) callBack;

/**
 *  传入一个AssetsURL来获取UIImage
 */
- (void) getAssetsPhotoWithURLs:(NSURL *) url callBack:(groupCallBackBlock ) callBack;

@end
