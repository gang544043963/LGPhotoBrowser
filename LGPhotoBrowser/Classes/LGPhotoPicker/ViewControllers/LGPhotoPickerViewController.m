//
//  LGPickerViewController.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import "LGPhotoPickerViewController.h"
#import "LGPhoto.h"

@interface LGPhotoPickerViewController ()

@property (nonatomic , weak) LGPhotoPickerGroupViewController *groupVc;
//是否发送原图，1 原图 0 压缩过图
@property (nonatomic, assign) BOOL isOriginal;

@end

@implementation LGPhotoPickerViewController

- (instancetype)initWithShowType:(LGShowImageType)showType{
    self = [super init];
    if (self) {
        self.showType = showType;
        self.groupVc.showType = showType;
    }
    return self;
}

#pragma mark - Life cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor whiteColor];
    [self addNotification];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init Action
- (void) createNavigationController{
    LGPhotoPickerGroupViewController *groupVc = [[LGPhotoPickerGroupViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:groupVc];
    
    nav.view.frame = self.view.bounds;
    [self addChildViewController:nav];
    [self.view addSubview:nav.view];
    self.groupVc = groupVc;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self createNavigationController];
    }
    return self;
}

- (void)setSelectPickers:(NSArray *)selectPickers{
    _selectPickers = selectPickers;
    self.groupVc.selectAsstes = [selectPickers mutableCopy];
}

- (void)setStatus:(PickerViewShowStatus)status{
    _status = status;
    self.groupVc.status = status;
}

- (void)setMaxCount:(NSInteger)maxCount{
    if (maxCount <= 0) return;
    _maxCount = maxCount;
    self.groupVc.maxCount = maxCount;
}

- (void)setTopShowPhotoPicker:(BOOL)topShowPhotoPicker{
    _topShowPhotoPicker = topShowPhotoPicker;
    self.groupVc.topShowPhotoPicker = topShowPhotoPicker;
}

#pragma mark - 展示控制器
- (void)showPickerVc:(UIViewController *)vc{
    __weak typeof(vc)weakVc = vc;
    if (weakVc != nil) {
        [weakVc presentViewController:self animated:YES completion:nil];
    }
}

- (void) addNotification{
    // 监听异步done通知
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(done:) name:PICKER_TAKE_DONE object:nil];
    });
    
    // 监听异步点击第一个Cell的拍照通知
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectCamera:) name:PICKER_TAKE_PHOTO object:nil];
    });
}

#pragma mark - 监听点击第一个Cell进行拍照
- (void)selectCamera:(NSNotification *)noti{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([self.delegate respondsToSelector:@selector(pickerCollectionViewSelectCamera:)]){
            [self.delegate pickerCollectionViewSelectCamera:self];
        }
    });
}

#pragma mark - 监听点击Done按钮
- (void)done:(NSNotification *)note{
    NSArray *selectArray =  note.userInfo[@"selectAssets"];
    self.isOriginal = [note.userInfo[@"isOriginal"] boolValue];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(pickerViewControllerDoneAsstes:isOriginal:)]) {
            [self.delegate pickerViewControllerDoneAsstes:selectArray  isOriginal:self.isOriginal];
        }else if (self.callBack){
            self.callBack(selectArray);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)setDelegate:(id<LGPhotoPickerViewControllerDelegate>)delegate{
    _delegate = delegate;
    self.groupVc.delegate = delegate;
}
@end
