//
//  LGPhotoPickerBrowserPhotoImageView.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LGPhotoPickerBrowserPhotoImageViewDelegate;

@interface LGPhotoPickerBrowserPhotoImageView : UIImageView {}

@property (nonatomic, weak) id <LGPhotoPickerBrowserPhotoImageViewDelegate> tapDelegate;
@property (assign,nonatomic) CGFloat progress;

- (void)addScaleBigTap;
- (void)removeScaleBigTap;
@end

@protocol LGPhotoPickerBrowserPhotoImageViewDelegate <NSObject>

@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;

@end