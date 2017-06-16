//
//  LGPickerCollectionView.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>
#import "LGPhotoAssets.h"

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

//点击cell会调用
- (void) pickerCollectionCellTouchedIndexPath:(NSIndexPath *)indexPath;

// 点击拍照就会调用
- (void)pickerCollectionViewDidCameraSelect:(LGPhotoPickerCollectionView *) pickerCollectionView;

// 选中的图片
- (NSArray<LGPhotoAssets *> *)selectedAssests;
@end

@interface LGPhotoPickerCollectionView : UICollectionView<UICollectionViewDelegate>

// 保存所有的数据
@property (nonatomic, strong) NSArray<__kindof LGPhotoAssets*>        *dataArray;
// 最后保存的一次图片
//@property (nonatomic, strong) NSMutableArray *lastDataArray;
// delegate
@property (nonatomic, weak) id <LGPhotoPickerCollectionViewDelegate> collectionViewDelegate;
// 限制最大数
@property (nonatomic, assign) NSInteger maxCount;
// 置顶展示相册按钮
@property (nonatomic, assign) BOOL      topShowPhotoPicker;
// 记录选中的值
@property (nonatomic, assign) BOOL      isRecoderSelectPicker;

@end
