//
//  LGPhotoPickerGroupViewController.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>
#import "LGPhotoPickerViewController.h"

@interface LGPhotoPickerGroupViewController : UIViewController

@property (nonatomic, weak) id<LGPhotoPickerViewControllerDelegate> delegate;
@property (nonatomic, assign) PickerViewShowStatus status;
@property (nonatomic) LGShowImageType showType;
@property (nonatomic, assign) NSInteger maxCount;
// 记录选中的值
@property (nonatomic, strong) NSMutableArray *selectAsstes;
// 置顶展示图片
@property (nonatomic, assign) BOOL topShowPhotoPicker;
// 夜间模式
@property (nonatomic ,assign) BOOL nightMode;

- (instancetype)initWithShowType:(LGShowImageType)showType;

@end
