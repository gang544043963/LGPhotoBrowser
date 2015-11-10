//
//  BQCamera.h
//  BQCommunity
//
//  Created by ZL on 14-9-11.
//  Copyright (c) 2014年 beiqing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZLCamera.h"

typedef NS_ENUM(NSInteger, ZLCameraType) {
    ZLCameraSingle,//单张
    ZLCameraContinuous,//连拍
};

typedef void(^ZLCameraCallBack)(id object);

@interface ZLCameraViewController : UIViewController

// 顶部View
@property (weak, nonatomic) UIView *topView;
// 底部View
@property (weak, nonatomic) UIView *controlView;
// 拍照的个数限制
@property (assign,nonatomic) NSInteger maxCount;
// 单张还是连拍
@property (nonatomic, assign) ZLCameraType cameraType;

// 完成后回调
@property (copy, nonatomic) ZLCameraCallBack callback;

- (void)showPickerVc:(UIViewController *)vc;
@end
