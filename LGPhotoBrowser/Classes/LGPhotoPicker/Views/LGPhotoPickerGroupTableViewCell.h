//
//  LGPickerGroupTableViewCell.h
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <UIKit/UIKit.h>

@class LGPhotoPickerGroup;

@interface LGPhotoPickerGroupTableViewCell : UITableViewCell

/**
 *  赋值xib
 */
@property (nonatomic , strong) LGPhotoPickerGroup *group;

@end
