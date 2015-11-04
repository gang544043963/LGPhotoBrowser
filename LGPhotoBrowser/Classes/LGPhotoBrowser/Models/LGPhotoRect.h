//
//  LGPhotoRect.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LGPhotoRect : NSObject
+ (CGRect)setMaxMinZoomScalesForCurrentBoundWithImage:(UIImage *)image;
+ (CGRect)setMaxMinZoomScalesForCurrentBoundWithImageView:(UIImageView *)imageView;
@end
