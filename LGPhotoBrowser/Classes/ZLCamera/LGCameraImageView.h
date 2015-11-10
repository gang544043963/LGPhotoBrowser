//
//  XGCameraImageView.h
//  XinGe
//
//  Created by ligang on 15/11/5.
//  Copyright © 2015年 Tomy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XGImageOrientation) {
    XGImageOrientationUp,            // default orientation
    XGImageOrientationDown,          // 180 deg rotation
    XGImageOrientationLeft,          // 90 deg CCW
    XGImageOrientationRight,         // 90 deg CW
    XGImageOrientationUpMirrored,    // as above but image mirrored along other axis. horizontal flip
    XGImageOrientationDownMirrored,  // horizontal flip
    XGImageOrientationLeftMirrored,  // vertical flip
    XGImageOrientationRightMirrored, // vertical flip
};

@protocol LGCameraImageViewDelegate <NSObject>

- (void)xgCameraImageViewSendBtnTouched;

- (void)xgCameraImageViewCancleBtnTouched;

@end

@interface LGCameraImageView : UIImageView

@property (nonatomic, weak) id<LGCameraImageViewDelegate>delegate;

@property (nonatomic, strong) UIImage *imageToDisplay;

@property (nonatomic, assign) XGImageOrientation imageOrientation;

@end
