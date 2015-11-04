//
//  LGPhotoPickerBrowserViewController.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>
#import "LGPhotoPickerBrowserPhoto.h"
#import "LGPhotoPickerCommon.h"
#import "LGPhotoPickerCustomToolBarView.h"
#import "LGPhotoPickerBrowserPhotoScrollView.h"

@class LGPhotoPickerBrowserViewController;
@protocol LGPhotoPickerBrowserViewControllerDataSource <NSObject>

@optional
/**
 *  有多少组
 */
- (NSInteger) numberOfSectionInPhotosInPickerBrowser:(LGPhotoPickerBrowserViewController *) pickerBrowser;

@required
/**
 *  每个组多少个图片
 */
- (NSInteger) photoBrowser:(LGPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section;
/**
 *  每个对应的IndexPath展示什么内容
 */
- (id<LGPhotoPickerBrowserPhoto>)photoBrowser:(LGPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath;


@end

@protocol LGPhotoPickerBrowserViewControllerDelegate <NSObject>
@optional

/**
 *  发送按钮和返回按钮按下时调用，向上一级控制器传递selectedAssets
 */
- (void)photoBrowserWillExit:(LGPhotoPickerBrowserViewController *)pickerBrowser;

/**
 *  返回用户自定义的toolBarView(类似tableView FooterView)
 *
 *  @return 返回用户自定义的toolBarView
 */
- (LGPhotoPickerCustomToolBarView *)photoBrowserShowToolBarViewWithphotoBrowser:(LGPhotoPickerBrowserViewController *)photoBrowser;
/**
 *  滑动结束的页数
 *
 *  @param page         滑动的页数
 */
- (void)photoBrowser:(LGPhotoPickerBrowserViewController *)photoBrowser didCurrentPage:(NSUInteger)page;
/**
 *  滑动开始的页数
 *
 *  @param page         滑动的页数
 */
- (void)photoBrowser:(LGPhotoPickerBrowserViewController *)photoBrowser willCurrentPage:(NSUInteger)page;

/**
 *  点击发送执行此代理，向上一级控制器传递数据
 *
 *  @param pickerBrowser
 *  @param isOriginal     是否原图
 *  备注：这里不传selectedAssets,选择的照片每点击一次右上角的选择框就传第一次
 */
- (void)photoBrowserSendBtnTouched:(LGPhotoPickerBrowserViewController *)pickerBrowser isOriginal:(BOOL)isOriginal;

@end

@interface LGPhotoPickerBrowserViewController : UIViewController

// @require
// 数据源/代理
@property (nonatomic , weak) id<LGPhotoPickerBrowserViewControllerDataSource> dataSource;
@property (nonatomic , weak) id<LGPhotoPickerBrowserViewControllerDelegate> delegate;

// 展示的图片数组<ZLPhotoPickerBrowserPhoto> == [self.dataSource photoBrowser:photoAtIndexPath:]
@property (nonatomic, copy) NSArray *photos;

@property (nonatomic, strong) NSMutableArray *selectedAssets;
// 当前提供的组
@property (strong,nonatomic) NSIndexPath *currentIndexPath;

@property (nonatomic) LGShowImageType showType;
// 长按保存图片会调用sheet
@property (nonatomic, strong) UIActionSheet *sheet;
// 需要增加的导航高度
@property (nonatomic, assign) CGFloat navigationHeight;

@property (nonatomic, assign) NSInteger maxCount;
// 放大缩小一张图片的情况下（查看头像）
- (void)showHeadPortrait:(UIImageView *)toImageView;
// 放大缩小一张图片的情况下（查看头像）/ 缩略图是toImageView.image 原图URL
- (void)showHeadPortrait:(UIImageView *)toImageView originUrl:(NSString *)originUrl;

// 刷新数据
- (void)reloadData;

// Category Functions.
- (UIView *)getParsentView:(UIView *)view;
- (id)getParsentViewController:(UIView *)view;

@end
