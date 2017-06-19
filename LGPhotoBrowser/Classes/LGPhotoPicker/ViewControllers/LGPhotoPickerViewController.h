//
//  LGPickerViewController.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>
#import "LGPhotoPickerCommon.h"

@class LGPhotoPickerViewController;
@class LGPhotoPickerConfiguration;

// 回调
typedef void(^LGcallBackBlock)(id obj);


@protocol LGPhotoPickerViewControllerDelegate <NSObject>
/**
 *  返回所有的Asstes对象
 */
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets isOriginal:(BOOL)original;

@end

@interface LGPhotoPickerViewController : UIViewController

// 代理
@property (nonatomic, weak) id<LGPhotoPickerViewControllerDelegate> delegate;

// 可以用代理来返回值或者用block来返回值
@property (nonatomic, copy) LGcallBackBlock callBack;

// 记录选中的值
@property (nonatomic, strong) NSArray *selectPickers;

/**
 创建一个图片选择器

 @param showType 显示类型
 @param configuration 配置
 @return 返回一个图片选择器的实例
 */
- (instancetype)initWithConfiguration:(LGPhotoPickerConfiguration *)configuration;

// 展示控制器
//- (void)showPickerVc:(UIViewController *)vc;

@end
