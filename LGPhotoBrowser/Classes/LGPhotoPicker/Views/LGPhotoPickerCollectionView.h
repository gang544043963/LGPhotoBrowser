//
//  LGPickerCollectionView.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>
#import "LGPhotoAssets.h"
#import "LGPhotoPickerConfiguration.h"

// 展示状态
typedef NS_ENUM(NSUInteger, LGPickerCollectionViewShowOrderStatus){
    LGPickerCollectionViewShowOrderStatusTimeDesc = 0, // 升序
    LGPickerCollectionViewShowOrderStatusTimeAsc // 降序
};

@class LGPhotoPickerCollectionView;
@protocol LGPhotoPickerCollectionViewDelegate <NSObject>

// 选择相片就会调用
- (void) pickerCollectionViewDidSelected:(LGPhotoPickerCollectionView *) pickerCollectionView selectedAsset:(LGPhotoAssets *)assets;

// 取消选中照片
- (void) pickerCollectionViewDidDeselected:(LGPhotoPickerCollectionView *) pickerCollectionView deselectedAsset:(LGPhotoAssets *)assets;

// 点击cell会调用
- (void) pickerCollectionCellTouchedIndexPath:(NSIndexPath *)indexPath;

// 点击拍照就会调用
- (void)pickerCollectionViewDidCameraSelect:(LGPhotoPickerCollectionView *) pickerCollectionView;

/**
 选中的图片

 @param collectionView 相册的collectionView
 @return 返回已经选中的图片
 */
- (NSArray<LGPhotoAssets *> *)selectedAssestsForPhotoPickerCollectionView:(LGPhotoPickerCollectionView *)collectionView;;

@end

@interface LGPhotoPickerCollectionView : UICollectionView<UICollectionViewDelegate>

- (instancetype)initWithFrame:(CGRect)frame
         collectionViewLayout:(UICollectionViewLayout *)layout
                configuraiton:(LGPhotoPickerConfiguration *)configuration;

/**
 数据源
 */
@property (nonatomic, strong) NSArray<__kindof LGPhotoAssets*> *dataArray;


/**
 代理
 */
@property (nonatomic, weak) id <LGPhotoPickerCollectionViewDelegate> collectionViewDelegate;

@end
