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
@property (nonatomic, weak) UIView *topView;
// 底部View
@property (nonatomic, weak) UIView *controlView;
// 拍照的个数限制
@property (nonatomic, assign) NSInteger maxCount;
// 单张还是连拍
@property (nonatomic, assign) ZLCameraType cameraType;
// 完成后回调
@property (nonatomic, copy) ZLCameraCallBack callback;

- (void)showPickerVc:(UIViewController *)vc;

@end
