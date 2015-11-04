//
//  LGPickerCollectionViewCell.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import "LGPhotoPickerCollectionViewCell.h"

static NSString *const _cellIdentifier = @"cell";

@implementation LGPhotoPickerCollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    LGPhotoPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];

//    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)]; //耗时较长
    
    return cell;
}
@end
