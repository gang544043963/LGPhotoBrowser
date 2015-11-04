//
//  LGPhotoPickerCustomToolBarView.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import "LGPhotoPickerCustomToolBarView.h"
#import "LGPhotoPickerBrowserPhoto.h"
#import "LGPhotoPickerCommon.h"

@interface LGPhotoPickerCustomToolBarView()

@property (nonatomic, strong) UIToolbar *toolbar;

@property (nonatomic, copy)  NSString *fileSize;

@property (nonatomic, strong) UIBarButtonItem *isOriginalBtn;

@property (nonatomic, strong) UIBarButtonItem *sendBtn;

@property (nonatomic , weak) UILabel *makeView;

@end

@implementation LGPhotoPickerCustomToolBarView


- (instancetype)initWithFrame:(CGRect)frame showType:(LGShowImageType)showType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.showType = showType;
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        NSLog(@"%@",NSStringFromCGRect(_toolbar.frame));
        if ([_toolbar respondsToSelector:@selector(setBarTintColor:)]) {
            _toolbar.barTintColor = nil;
        }
        if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
            [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
            [_toolbar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsLandscapePhone];
        }
        _toolbar.barStyle = UIBarStyleBlackTranslucent;
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        
        [self updateToolbarWithOriginal:NO currentPage:0 selectedCount:0];
        
        [self addSubview:_toolbar];
    }
    return self;
}

- (void)sendAction
{
    if ([self.delegate respondsToSelector:@selector(customToolBarSendBtnTouched)]) {
        [self.delegate customToolBarSendBtnTouched];
    }
}

- (void)updateToolbarWithOriginal:(BOOL)isOriginal
                      currentPage:(NSInteger)currentPage
                    selectedCount:(NSInteger)count
{
    UIButton *fileSizeButton = (UIButton *)self.isOriginalBtn.customView;
    
    //左边原图按钮
    if (isOriginal) {
 
        if (self.getSizeBlock) {
            self.fileSize = self.getSizeBlock();
        }
        
        [fileSizeButton setTitle:[NSString stringWithFormat:@"原图%@",self.fileSize] forState:UIControlStateNormal];
        [fileSizeButton setImageEdgeInsets:UIEdgeInsetsMake(13.0f, 0, 13.0f, 100-18)];
        
        NSString *text = [fileSizeButton titleForState:UIControlStateNormal];
        CGSize textSize = [text length] > 0 ? [text sizeWithFont:fileSizeButton.titleLabel.font] : CGSizeZero;
        [fileSizeButton setTitleEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 100-textSize.width-25)];
        
        self.isOriginalBtn = [self createSelecteOriginalItemWithImg:[UIImage imageNamed:@"btn_original.png"]
                                       title:[NSString stringWithFormat:@"原图%@",self.fileSize]
                                  titleColor:[UIColor whiteColor]
                                      target:self
                                      action:@selector(originalAction)];
    } else {
        self.isOriginalBtn = [self createSelecteOriginalItemWithImg:[UIImage imageNamed:@"btn_original_non.png"]
                                       title:@"原图"
                                  titleColor:[UIColor colorWithRed:0xc7 green:0xc7 blue:0xc7 alpha:1]
                                      target:self
                                      action:@selector(originalAction)];
    }
    
    //发送按钮
    NSString *rightBtnName = @"发送";
    self.sendBtn = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ (%ld)",rightBtnName,(long)count] style:UIBarButtonItemStyleBordered target:self action:@selector(sendAction)];
    self.sendBtn.tintColor = [UIColor colorWithRed:0x45 green:0x9a blue:0x00 alpha:1];
    
    UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.sendBtn.enabled = (count > 0);
    
    _toolbar.items = @[self.isOriginalBtn, fiexItem, self.sendBtn];
    
}


/* 创建一个原图缩略图选择item */
- (UIBarButtonItem *)createSelecteOriginalItemWithImg:(UIImage *)image
                                                title:(NSString *)title
                                           titleColor:(UIColor *)titleColor
                                               target:(id)target
                                               action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 100, 44.0f);
    [button setImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:titleColor forState:UIControlStateNormal];
    [button setImageEdgeInsets:UIEdgeInsetsMake(13.0f, 0, 13.0f, 100-18)];
    button.titleLabel.textAlignment = NSTextAlignmentLeft;
    CGSize textSize = XG_TEXTSIZE(title, button.titleLabel.font);
    [button setTitleEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 100-textSize.width-25)];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithCustomView:button];
    return barbutton;
}

#pragma mark makeView 红点标记View
- (UILabel *)makeView{
    if (!_makeView) {
        UILabel *makeView = [[UILabel alloc] init];
        makeView.textColor = [UIColor whiteColor];
        makeView.textAlignment = NSTextAlignmentCenter;
        makeView.font = [UIFont systemFontOfSize:13];
        makeView.frame = CGRectMake(-5, -5, 20, 20);
        makeView.hidden = YES;
        makeView.layer.cornerRadius = makeView.frame.size.height / 2.0;
        makeView.clipsToBounds = YES;
        makeView.backgroundColor = [UIColor redColor];
        [self addSubview:makeView];
        self.makeView = makeView;
        
    }
    return _makeView;
}

- (void)originalAction
{
    if ([self.delegate respondsToSelector:@selector(customToolBarIsOriginalBtnTouched)]) {
        [self.delegate customToolBarIsOriginalBtnTouched];
    }
}

@end
