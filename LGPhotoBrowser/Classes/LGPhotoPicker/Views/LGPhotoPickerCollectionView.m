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
#import "LGPhotoPickerConfiguration.h"

static NSString *const kPhotoCollectionCellIdentifier = @"kPhotoCollectionCellIdentifier";

@interface LGPhotoPickerCollectionView ()
<
UICollectionViewDataSource,
UICollectionViewDelegate,
LGPhotoPickerCollectionViewCellDelegate
>

@property (nonatomic, strong) LGPhotoPickerFooterCollectionReusableView *footerView;
@property (nonatomic, strong) LGPhotoPickerConfiguration *configuration;

@end

@implementation LGPhotoPickerCollectionView

- (instancetype)initWithFrame:(CGRect)frame
         collectionViewLayout:(UICollectionViewLayout *)layout
                configuraiton:(LGPhotoPickerConfiguration *)configuration {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        self.configuration = configuration;

        [self registerNib:[UINib nibWithNibName:@"LGPhotoPickerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kPhotoCollectionCellIdentifier];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupPickerImageViewOnCell:(LGPhotoPickerCollectionViewCell *)cell
                           AtIndex:(NSIndexPath *)indexPath {

    LGPhotoAssets *asset = self.dataArray[indexPath.item];
    NSArray *selectedAssets = [self.collectionViewDelegate selectedAssestsForPhotoPickerCollectionView:self];
    if ([asset isKindOfClass:[LGPhotoAssets class]]) {
        cell.imageView.image = asset.thumbImage;
    }
    
    for (NSInteger i = 0; i < selectedAssets.count; i ++) {
        if ([((LGPhotoAssets *)selectedAssets[i]).assetURL isEqual:asset.assetURL]) {
            [cell selectedWithNumber:(i + 1)];
            return;
        }
    }
    [cell deselected];
}

#pragma mark - UICollectionViewDataSource
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
    LGPhotoAssets *asset = self.dataArray[indexPath.item];
    
    if (self.configuration.showCameraButton && indexPath.row == 0) {
        if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidCameraSelect:)]) {
            [self.collectionViewDelegate pickerCollectionViewDidCameraSelect:self];
        }
        return ;
    }
    
    if (cell.selected) {
        
        if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidDeselected:deselectedAsset:)]) {
            [self.collectionViewDelegate pickerCollectionViewDidDeselected:self deselectedAsset:asset];
        }
        
        [cell deselected];
        [self reloadData];
    }
    else {
        
        NSArray *selectedAssests = [self.collectionViewDelegate selectedAssestsForPhotoPickerCollectionView:self];
        NSUInteger maxCount = (self.configuration.maxSelectCount < 0) ? KPhotoShowMaxCount :  self.configuration.maxSelectCount;
        if (selectedAssests.count >= maxCount) {
            NSString *format = [NSString stringWithFormat:@"最多只能选择%zd张图片",maxCount];
            if (maxCount == 0) {
                format = [NSString stringWithFormat:@"您最多只能选择9张图片"];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:format delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [alertView show];
            return;
        }
        
        if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidSelected:selectedAsset:)]) {
            [self.collectionViewDelegate pickerCollectionViewDidSelected:self selectedAsset:asset];
        }
        
        [cell selectedWithNumber:selectedAssests.count];
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
        if (!self.configuration.showFooterView) {
            self.footerView.hidden = YES;
        }
    }

    return reusableView;
}

#pragma mark - Setter and Getter
- (void)setDataArray:(NSArray *)dataArray {
    _dataArray = dataArray;
    
    // 需要记录选中的值的数据
    NSArray *selectedAssest = [self.collectionViewDelegate selectedAssestsForPhotoPickerCollectionView:self];
    NSMutableArray *selectAssets = [NSMutableArray array];
    for (LGPhotoAssets *asset in selectedAssest) {
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

    [self reloadData];
}


@end
