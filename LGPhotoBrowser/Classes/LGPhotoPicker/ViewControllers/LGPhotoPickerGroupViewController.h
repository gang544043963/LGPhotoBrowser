//
//  LGPhotoPickerGroupViewController.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>
#import "LGPhotoPickerViewController.h"
@class LGPhotoPickerConfiguration;

@interface LGPhotoPickerGroupViewController : UIViewController

@property (nonatomic, weak) id<LGPhotoPickerViewControllerDelegate> delegate;

// 记录选中的值
@property (nonatomic, strong) NSMutableArray *selectAsstes;

- (instancetype)initWithConfiguration:(LGPhotoPickerConfiguration *)configuration;

@end
