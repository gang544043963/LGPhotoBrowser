//
//  LGImagePickerSelectView.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>

@interface LGImagePickerSelectView : UIView

@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *selectBtn;

- (void)addTarget:(id)target backAction:(SEL)backAction selectAction:(SEL)selectAction forControlEvents:(UIControlEvents)controlEvents;

@end
