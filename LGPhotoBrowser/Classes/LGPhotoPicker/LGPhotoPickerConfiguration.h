//
//  LGPhotoPickerConfiguration.h
//  LGPhotoBrowser
//
//  Created by Liujinlong on 19/06/2017.
//  Copyright © 2017 L&G. All rights reserved.
//  图片选择器的一个配置类

#import <UIKit/UIKit.h>
#import "LGPhotoPickerCommon.h"

@interface LGPhotoPickerConfiguration : NSObject


/**
 默认配置
 */
@property (nonatomic, strong, class, readonly) LGPhotoPickerConfiguration *defaultConfiguration;


/**
 是否显示底部footerView，默认显示
 */
@property (nonatomic, assign) BOOL showFooterView;


/**
 是否显示相机按钮，默认不显示
 */
@property (nonatomic, assign) BOOL showCameraButton;


/**
 最多选中的图片的个数，默认为9张
 */
@property (nonatomic, assign) NSInteger maxSelectCount;


/**
 决定以什么风格显示相册，有原图选择按钮？有多选功能
 */
@property (nonatomic, assign) LGShowImageType showType;


/**
 默认显示的相册
 */
@property (nonatomic, assign) LGPickerViewShowAlbum showAlbum;

@end
