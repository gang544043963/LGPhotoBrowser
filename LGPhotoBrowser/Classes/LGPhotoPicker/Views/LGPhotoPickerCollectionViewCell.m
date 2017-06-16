//
//  LGPickerCollectionViewCell.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import "LGPhotoPickerCollectionViewCell.h"

static NSString *const _cellIdentifier = @"cell";

@interface LGPhotoPickerCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *selectTagLabel;

@end

@implementation LGPhotoPickerCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectTagLabel.layer.cornerRadius = 10.0;
    self.selectTagLabel.layer.borderWidth = 1.0;
    self.selectTagLabel.layer.borderColor = [UIColor redColor].CGColor;
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTagLabel:)];
    [self.selectTagLabel addGestureRecognizer:gesture];
}

- (void)selectedWithNumber:(NSInteger)number {
    self.selected = YES;
    self.selectTagLabel.text = [NSString stringWithFormat:@"%@", @(number)];
    self.selectTagLabel.backgroundColor = [UIColor yellowColor];
}

- (void)deselected {
    self.selected = NO;
    self.selectTagLabel.text = @"";
    self.selectTagLabel.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Action 

- (void)tapTagLabel:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(photoPickerCollectionViewCell:didSelectImage:)]) {
        [self.delegate photoPickerCollectionViewCell:self didSelectImage:self.imageView.image];
    }
}

@end
