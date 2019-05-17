//
//  LGPhotoPickerCustomToolBarView.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import "LGPhotoPickerCustomToolBarView.h"
#import "LGPhotoPickerBrowserPhoto.h"
#import "LGPhotoPickerCommon.h"

#pragma clang diagnostic ignored "-Wdeprecated"

@interface LGPhotoPickerCustomToolBarView()

@property (nonatomic, copy)  NSString *fileSize;

@property (nonatomic) UIButton *isOriginalBtn;

@property (nonatomic) UIButton *sendBtn;

@end

@implementation LGPhotoPickerCustomToolBarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        self.isOriginalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.isOriginalBtn setFrame:CGRectMake(20, 10, 150, 40)];
        self.isOriginalBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.isOriginalBtn addTarget:self action:@selector(originalAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.isOriginalBtn];
        
        CGFloat sendBtnWidth = 80;
        self.sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.sendBtn setFrame:CGRectMake(SCREEN_WIDTH - sendBtnWidth - 15, 10, sendBtnWidth, 40)];
        [self.sendBtn setTitle:@"发送(0)" forState:UIControlStateNormal];
        [self.sendBtn addTarget:self action:@selector(sendAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendBtn];
        
        [self updateToolbarWithOriginal:NO currentPage:0 selectedCount:0];
    }
    return self;
}

- (void)sendAction {
    if ([self.delegate respondsToSelector:@selector(customToolBarSendBtnTouched)]) {
        [self.delegate customToolBarSendBtnTouched];
    }
}

- (void)updateToolbarWithOriginal:(BOOL)isOriginal
                      currentPage:(NSInteger)currentPage
                    selectedCount:(NSInteger)count {
    //左边原图按钮
    if (isOriginal) {
 
        if (self.getSizeBlock) {
            self.fileSize = self.getSizeBlock();
        }
        
        NSString *titleStr = [NSString stringWithFormat:@"原图%@",self.fileSize];
        [self.isOriginalBtn setTitle:titleStr forState:UIControlStateNormal];
        [self.isOriginalBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
    } else {
        [self.isOriginalBtn setTitle:@"原图" forState:UIControlStateNormal];
        [self.isOriginalBtn setTitleColor:[UIColor colorWithRed:0xc7 green:0xc7 blue:0xc7 alpha:1] forState:UIControlStateNormal];
    }
    
    //发送按钮
    NSString *sendStr = [NSString stringWithFormat:@"发送(%ld)",(long)count];
    [self.sendBtn setTitle:sendStr forState:UIControlStateNormal];
    self.sendBtn.tintColor = [UIColor colorWithRed:0x45 green:0x9a blue:0x00 alpha:1];
    self.sendBtn.enabled = (count > 0);
}

- (void)originalAction {
    if ([self.delegate respondsToSelector:@selector(customToolBarIsOriginalBtnTouched)]) {
        [self.delegate customToolBarIsOriginalBtnTouched];
    }
}

#pragma mark setters

- (void)setNightMode:(BOOL)nightMode {
	_nightMode = nightMode;
}

@end
