//
//  LGPickerCollectionViewCell.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>
@class LGPhotoPickerCollectionViewCell;

@protocol LGPhotoPickerCollectionViewCellDelegate <NSObject>

- (void)photoPickerCollectionViewCell:(LGPhotoPickerCollectionViewCell *)cell didSelectImage:(UIImage *)image;

@end


@interface LGPhotoPickerCollectionViewCell : UICollectionViewCell

@property (nonatomic, weak) id<LGPhotoPickerCollectionViewCellDelegate> delegate;
@property (nonatomic , strong) UIImage *cellImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/**
 标示选中

 @param number 选中的序号
 */
- (void)selectedWithNumber:(NSInteger)number;


/**
 取消选中
 */
- (void)deselected;

@end
