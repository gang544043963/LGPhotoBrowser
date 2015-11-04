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
- (void) pickerCollectionViewDidSelected:(LGPhotoPickerCollectionView *) pickerCollectionView deleteAsset:(LGPhotoAssets *)deleteAssets;

//点击cell会调用
- (void) pickerCollectionCellTouchedIndexPath:(NSIndexPath *)indexPath;

// 点击拍照就会调用
- (void)pickerCollectionViewDidCameraSelect:(LGPhotoPickerCollectionView *) pickerCollectionView;
@end

@interface LGPhotoPickerCollectionView : UICollectionView<UICollectionViewDelegate>

// scrollView滚动的升序降序
@property (nonatomic , assign) LGPickerCollectionViewShowOrderStatus status;
// 保存所有的数据
@property (nonatomic , strong) NSArray *dataArray;
// 保存选中的图片
@property (nonatomic , strong) NSMutableArray *selectAssets;
// 最后保存的一次图片
@property (strong,nonatomic) NSMutableArray *lastDataArray;
// delegate
@property (nonatomic , weak) id <LGPhotoPickerCollectionViewDelegate> collectionViewDelegate;
// 限制最大数
@property (nonatomic , assign) NSInteger maxCount;
// 置顶展示图片
@property (assign,nonatomic) BOOL topShowPhotoPicker;
// 记录选中的值
@property (assign,nonatomic) BOOL isRecoderSelectPicker;

@end
