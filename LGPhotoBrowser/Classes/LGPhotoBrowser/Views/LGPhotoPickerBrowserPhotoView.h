//
//  LGPhotoPickerBrowserPhotoView.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.年 Tomy All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LGPhotoPickerBrowserPhotoViewDelegate;

@interface LGPhotoPickerBrowserPhotoView : UIView {}

@property (nonatomic, weak) id <LGPhotoPickerBrowserPhotoViewDelegate> tapDelegate;

@end

@protocol LGPhotoPickerBrowserPhotoViewDelegate <NSObject>

@optional

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;

@end