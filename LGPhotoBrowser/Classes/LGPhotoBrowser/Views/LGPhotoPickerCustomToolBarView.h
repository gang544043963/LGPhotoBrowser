//
//  LGPhotoPickerCustomToolBarView.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

/**
 *  Note: 图片游览器自定义View
 *  在里面创建的控件会添加到 ZLPhotoPickerBrowserViewController view里面
 */
#import <UIKit/UIKit.h>
#import "LGPhotoPickerCommon.h"

@protocol LGPhotoPickerCustomToolBarViewDelegate <NSObject>

- (void)customToolBarIsOriginalBtnTouched;
- (void)customToolBarSendBtnTouched;

@end

@interface LGPhotoPickerCustomToolBarView : UIView

@property (nonatomic, copy) NSString *(^getSizeBlock)(void);

@property (nonatomic) LGShowImageType showType;

@property (nonatomic, weak) id<LGPhotoPickerCustomToolBarViewDelegate>delegate;

//- (void)setupToolbar;
- (instancetype)initWithFrame:(CGRect)frame showType:(LGShowImageType)showType;

- (void)updateToolbarWithOriginal:(BOOL)isOriginal
                      currentPage:(NSInteger)currentPage
                    selectedCount:(NSInteger)count;
@end
