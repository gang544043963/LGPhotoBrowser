//
//  LGPickerCollectionView.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import "LGPhotoPickerCollectionView.h"
#import "LGPhotoPickerCollectionViewCell.h"
#import "LGPhotoPickerImageView.h"
#import "LGPhotoPickerFooterCollectionReusableView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "LGPhotoAssets.h"
#import "LGPhoto.h"
#import <objc/runtime.h>

static NSString *const kPhotoCollectionCellIdentifier = @"kPhotoCollectionCellIdentifier";

@interface LGPhotoPickerCollectionView ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
LGPhotoPickerCollectionViewCellDelegate
>

@property (nonatomic , strong) LGPhotoPickerFooterCollectionReusableView *footerView;

// 判断是否是第一次加载
@property (nonatomic , assign , getter=isFirstLoadding) BOOL firstLoadding;

@end

@implementation LGPhotoPickerCollectionView

#pragma mark -setter
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    // 需要记录选中的值的数据
    if (self.isRecoderSelectPicker) {
        NSMutableArray *selectAssets = [NSMutableArray array];
        for (LGPhotoAssets *asset in self.selectAssets) {
            for (LGPhotoAssets *asset2 in self.dataArray) {
                
                if ([asset isKindOfClass:[UIImage class]] || [asset2 isKindOfClass:[UIImage class]]) {
                    continue;
                }
                if ([asset.asset.defaultRepresentation.url isEqual:asset2.asset.defaultRepresentation.url]) {
                    [selectAssets addObject:asset2];
                    break;
                }
            }
        }
        _selectAssets = selectAssets;
    }
    [self reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        _selectAssets = [NSMutableArray array];
        [self registerNib:[UINib nibWithNibName:@"LGPhotoPickerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kPhotoCollectionCellIdentifier];
    }
    return self;
}

- (void)setupPickerImageViewOnCell:(LGPhotoPickerCollectionViewCell *)cell
                           AtIndex:(NSIndexPath *)indexPath {

    LGPhotoAssets *asset = self.dataArray[indexPath.item];
    if ([asset isKindOfClass:[LGPhotoAssets class]]) {
        cell.imageView.image = asset.thumbImage;
    }

    for (NSInteger i = 0; i < self.selectAssets.count; i ++) {
        if ([((LGPhotoAssets *)self.selectAssets[i]).assetURL isEqual:asset.assetURL]) {
            [cell selectedWithNumber:(i + 1)];
            return;
        }
    }
    [cell deselected];
}
/**
 *  每个cell右上角的选择按钮
 */
//- (void)setupTickButtonOnCell:(LGPhotoPickerCollectionViewCell *)cell
//                      AtIndex:(NSIndexPath *)indexPath {
//    UIButton *tickButton = nil;
//    if (cell.contentView.subviews.count == 2 && [cell.contentView.subviews[1] isKindOfClass:[UIButton class]]) {//如果是重用cell，则不用再添加button
//        tickButton = cell.contentView.subviews[1];
//    } else {
//        tickButton = [[UIButton alloc] init];
//        tickButton.frame = CGRectMake(cell.frame.size.width - 40, 0, 40, 40);
//        [tickButton setBackgroundColor:[UIColor clearColor]];
//        [cell.contentView addSubview:tickButton];
//        [tickButton addTarget:self action:@selector(tickBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    tickButton.tag = indexPath.item;
//}

//- (void)tickBtnTouched:(UIButton *)btn {
//    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:btn.tag inSection:0];
//    
//    if (self.topShowPhotoPicker && indexPath.row == 0) {
//        if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidCameraSelect:)]) {
//            [self.collectionViewDelegate pickerCollectionViewDidCameraSelect:self];
//        }
//        return ;
//    }
//    
//    if (!self.lastDataArray) {
//        self.lastDataArray = [NSMutableArray array];
//    }
//    
//    LGPhotoPickerCollectionViewCell *cell = (LGPhotoPickerCollectionViewCell *) [self cellForItemAtIndexPath:indexPath];
//    
//    LGPhotoAssets *asset = self.dataArray[indexPath.item];
//    LGPhotoPickerImageView *pickerImageView = [cell.contentView.subviews objectAtIndex:0];
//    // 如果没有就添加到数组里面，存在就移除
//    if ([pickerImageView isKindOfClass:[LGPhotoPickerImageView class]] && pickerImageView.isMaskViewFlag) {
//        [self.selectAssets removeObject:asset];
//        [self.lastDataArray removeObject:asset];
//    }else{
//        // 1 判断图片数超过最大数或者小于0
//        NSUInteger maxCount = (self.maxCount < 0) ? KPhotoShowMaxCount :  self.maxCount;
//        if (self.selectAssets.count >= maxCount) {
//            NSString *format = [NSString stringWithFormat:@"最多只能选择%zd张图片",maxCount];
//            if (maxCount == 0) {
//                format = [NSString stringWithFormat:@"您最多只能选择9张图片"];
//            }
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:format delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
//            [alertView show];
//            return;
//        }
//        
//        [self.selectAssets addObject:asset];
//        [self.lastDataArray addObject:asset];
//    }
//    // 告诉代理现在被点击了!
//    if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidSelected: deleteAsset:)]) {
//        if (pickerImageView.isMaskViewFlag) {
//            // 删除的情况下
//            [self.collectionViewDelegate pickerCollectionViewDidSelected:self deleteAsset:asset];
//        }else{
//            [self.collectionViewDelegate pickerCollectionViewDidSelected:self deleteAsset:nil];
//        }
//    }
//    
//    pickerImageView.maskViewFlag = ([pickerImageView isKindOfClass:[LGPhotoPickerImageView class]]) && !pickerImageView.isMaskViewFlag;
//}

#pragma mark -<UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    LGPhotoPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCollectionCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
 
    [self setupPickerImageViewOnCell:cell AtIndex:indexPath];
    
    return cell;
}

#pragma mark - LGPhotoPickerCollectionViewCell
- (void)photoPickerCollectionViewCell:(LGPhotoPickerCollectionViewCell *)cell didSelectImage:(UIImage *)image {
    
    NSIndexPath *indexPath = [self indexPathForCell:cell];
    
    if (self.topShowPhotoPicker && indexPath.row == 0) {
        if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidCameraSelect:)]) {
            [self.collectionViewDelegate pickerCollectionViewDidCameraSelect:self];
        }
        return ;
    }
    
    if (!self.lastDataArray) {
        self.lastDataArray = [NSMutableArray array];
    }

    LGPhotoAssets *asset = self.dataArray[indexPath.item];
    if (cell.selected) {
        [cell deselected];
        [self.selectAssets removeObject:asset];
        [self.lastDataArray removeObject:asset];
        [self reloadData];
    }
    else {
        NSUInteger maxCount = (self.maxCount < 0) ? KPhotoShowMaxCount :  self.maxCount;
        if (self.selectAssets.count >= maxCount) {
            NSString *format = [NSString stringWithFormat:@"最多只能选择%zd张图片",maxCount];
            if (maxCount == 0) {
                format = [NSString stringWithFormat:@"您最多只能选择9张图片"];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:format delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [alertView show];
            return;
        }
        [self.selectAssets addObject:asset];
        [self.lastDataArray addObject:asset];
        [cell selectedWithNumber:self.selectAssets.count];
    }
    
    if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidSelected: deleteAsset:)]) {
        if (cell.selected == NO) {
            [self.collectionViewDelegate pickerCollectionViewDidSelected:self deleteAsset:asset];
        }else{
            [self.collectionViewDelegate pickerCollectionViewDidSelected:self deleteAsset:nil];
        }
    }
    
}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionCellTouchedIndexPath:)]) {
        [self.collectionViewDelegate pickerCollectionCellTouchedIndexPath:indexPath];
    }
}

#pragma mark 底部View
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    LGPhotoPickerFooterCollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionFooter) {
        LGPhotoPickerFooterCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        footerView.count = self.dataArray.count;
        reusableView = footerView;
        self.footerView = footerView;
    }else{
        
    }
    return reusableView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 时间置顶的话
    if (self.status == LGPickerCollectionViewShowOrderStatusTimeDesc) {
        if (!self.firstLoadding && self.contentSize.height > [[UIScreen mainScreen] bounds].size.height) {
            // 滚动到最底部（最新的）
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            // 展示图片数
            self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + 100);
            self.firstLoadding = YES;
        }
    } else if (self.status == LGPickerCollectionViewShowOrderStatusTimeAsc) {
        // 滚动到最底部（最新的）
        if (!self.firstLoadding && self.contentSize.height > [[UIScreen mainScreen] bounds].size.height) {
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
            // 展示图片数
            self.contentOffset = CGPointMake(self.contentOffset.x, -self.contentInset.top);
            self.firstLoadding = YES;
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
