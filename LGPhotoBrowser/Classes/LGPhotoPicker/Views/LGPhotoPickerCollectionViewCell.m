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
    self.selectTagLabel.layer.cornerRadius = 14.0;
    [self setupNormalUI];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTagLabel:)];
    [self.selectTagLabel addGestureRecognizer:gesture];
}

- (void)selectedWithNumber:(NSInteger)number {
    self.selected = YES;
    self.selectTagLabel.text = [NSString stringWithFormat:@"%@", @(number)];
    [self setupSelectedUI];
}

- (void)deselected {
    self.selected = NO;
    self.selectTagLabel.text = @"";
    [self setupNormalUI];
}

#pragma mark - Action 

- (void)tapTagLabel:(UITapGestureRecognizer *)gesture {
    if ([self.delegate respondsToSelector:@selector(photoPickerCollectionViewCell:didSelectImage:)]) {
        [self.delegate photoPickerCollectionViewCell:self didSelectImage:self.imageView.image];
    }
}

#pragma mark - Private Method

- (void)setupNormalUI {
    self.selectTagLabel.layer.borderWidth = 1.0;
    self.selectTagLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    self.selectTagLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}

- (void)setupSelectedUI {
    self.selectTagLabel.layer.borderWidth = 0;
    self.selectTagLabel.backgroundColor = [UIColor orangeColor];
}

@end
