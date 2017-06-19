//
//  LGPhotoPickerAssetsViewController.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>
#import "LGPhotoPickerCommon.h"
#import "LGPhotoPickerGroupViewController.h"

@class LGPhotoPickerGroup;

@interface LGPhotoPickerAssetsViewController : UIViewController

@property (nonatomic, strong) LGPhotoPickerGroup *assetsGroup;

// 需要记录选中的值的数据
@property (nonatomic, strong) NSArray *selectPickerAssets;

@property (nonatomic, copy) void(^selectedAssetsBlock)(NSMutableArray *selectedAssets);

- (instancetype)initWithConfiguration:(LGPhotoPickerConfiguration *)configuration;

@end
