//
//  LGPickerViewController.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>
#import "LGPhotoPickerCommon.h"
// 回调
typedef void(^LGcallBackBlock)(id obj);
@class LGPhotoPickerViewController;
// 状态组
typedef NS_ENUM(NSInteger , PickerViewShowStatus) {
    PickerViewShowStatusGroup = 0, // default groups .
    PickerViewShowStatusCameraRoll ,
    PickerViewShowStatusSavePhotos ,
    PickerViewShowStatusPhotoStream ,
    PickerViewShowStatusVideo,
};

@protocol LGPhotoPickerViewControllerDelegate <NSObject>
/**
 *  返回所有的Asstes对象
 */
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets isOriginal:(BOOL)original;
/**
 *  点击拍照
 */
@optional
- (void)pickerCollectionViewSelectCamera:(LGPhotoPickerViewController *)pickerVc;
@end

@interface LGPhotoPickerViewController : UIViewController

// @optional
@property (nonatomic , weak) id<LGPhotoPickerViewControllerDelegate>delegate;
// 决定你是否需要push到内容控制器, 默认显示组
@property (nonatomic , assign) PickerViewShowStatus status;
// 决定以什么风格显示相册，有原图选择按钮？有多选功能？
@property (nonatomic) LGShowImageType showType;
// 可以用代理来返回值或者用block来返回值
@property (nonatomic , copy) LGcallBackBlock callBack;
// 每次选择图片的最小数, 默认与最大数是9
@property (nonatomic , assign) NSInteger maxCount;
// 记录选中的值
@property (strong,nonatomic) NSArray *selectPickers;
// 置顶展示图片
@property (assign,nonatomic) BOOL topShowPhotoPicker;

// @function
- (instancetype)initWithShowType:(LGShowImageType)showType;
// 展示控制器
- (void)showPickerVc:(UIViewController *)vc;

@end
