//
//  LGPhotoPickerBrowserPhotoScrollView.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LGPhotoPickerBrowserPhotoImageView.h"
#import "LGPhotoPickerBrowserPhotoView.h"
#import "LGPhotoPickerBrowserPhoto.h"
//#import "XGPhoto.h"
#import "LGPhoto.h"


typedef void(^scrollViewCallBackBlock)(id obj);
@class LGPhotoPickerBrowserPhotoScrollView;

@protocol LGPhotoPickerPhotoScrollViewDelegate <NSObject>
@optional
// 单击调用
- (void) pickerPhotoScrollViewDidSingleClick:(LGPhotoPickerBrowserPhotoScrollView *)photoScrollView;
- (void) pickerPhotoScrollViewDidLongPressed:(LGPhotoPickerBrowserPhotoScrollView *)photoScrollView;
@end

@interface LGPhotoPickerBrowserPhotoScrollView : UIScrollView <UIScrollViewDelegate, LGPhotoPickerBrowserPhotoImageViewDelegate,LGPhotoPickerBrowserPhotoViewDelegate>

@property (nonatomic,strong) LGPhotoPickerBrowserPhoto *photo;
@property (strong,nonatomic) LGPhotoPickerBrowserPhotoImageView *photoImageView;
@property (nonatomic, weak) id <LGPhotoPickerPhotoScrollViewDelegate> photoScrollViewDelegate;

@property (nonatomic) LGShowImageType showType;
// 单击销毁的block
@property (copy,nonatomic) scrollViewCallBackBlock callback;
- (void)setMaxMinZoomScalesForCurrentBounds;
@end
