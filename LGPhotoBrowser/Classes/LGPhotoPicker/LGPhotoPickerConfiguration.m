//
//  LGPhotoPickerConfiguration.m
//  LGPhotoBrowser
//
//  Created by Liujinlong on 19/06/2017.
//  Copyright © 2017 L&G. All rights reserved.
//

#import "LGPhotoPickerConfiguration.h"

@implementation LGPhotoPickerConfiguration

+ (LGPhotoPickerConfiguration *)defaultConfiguration {
    LGPhotoPickerConfiguration *instance = [[LGPhotoPickerConfiguration alloc] init];
    instance.showFooterView = YES;
    instance.showCameraButton = NO;
    instance.maxSelectCount = 9;
    return instance;
}

@end
