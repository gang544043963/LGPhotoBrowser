//
//  LGPhotoPickerGroupViewController.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#define CELL_ROW 4
#define CELL_MARGIN 5
#define CELL_LINE_MARGIN 5


#import "LGPhotoPickerGroupViewController.h"
#import "LGPhotoPickerCollectionView.h"
#import "LGPhotoPickerDatas.h"
#import "LGPhotoPickerGroupViewController.h"
#import "LGPhotoPickerGroup.h"
#import "LGPhotoPickerGroupTableViewCell.h"
#import "LGPhotoPickerAssetsViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface LGPhotoPickerGroupViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, weak) LGPhotoPickerAssetsViewController *collectionVc;

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, copy) NSString *selectGroupURL;

@end

@implementation LGPhotoPickerGroupViewController

#pragma mark - dealloc

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (instancetype)initWithShowType:(LGShowImageType)showType{
    self = [super init];
    if (self) {
        self.showType = showType;
    }
    return self;
}

- (UITableView *)tableView{
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.translatesAutoresizingMaskIntoConstraints = NO;
        tableView.delegate = self;
        [tableView registerClass:[LGPhotoPickerGroupTableViewCell class] forCellReuseIdentifier:NSStringFromClass([LGPhotoPickerGroupTableViewCell class])];
        [self.view addSubview:tableView];
        self.tableView = tableView;
        
        NSDictionary *views = NSDictionaryOfVariableBindings(tableView);
        
        NSString *heightVfl = @"V:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:nil views:views]];
        NSString *widthVfl = @"H:|-0-[tableView]-0-|";
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:nil views:views]];
        
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选择相册";
    // 设置按钮
    [self addNavBarCancelButton];
    
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied) {
        // 判断没有权限获取用户相册的话，就提示个View
        UIImageView *lockView = [[UIImageView alloc] init];
        lockView.image = [UIImage imageNamed:@"lock.png"];
        lockView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 200);
        lockView.contentMode = UIViewContentModeCenter;
        [self.view addSubview:lockView];
        
        UILabel *lockLbl = [[UILabel alloc] init];
        lockLbl.text = PICKER_PowerBrowserPhotoLibirayText;
        lockLbl.numberOfLines = 0;
        lockLbl.textAlignment = NSTextAlignmentCenter;
        lockLbl.frame = CGRectMake(20, 0, self.view.frame.size.width - 40, self.view.frame.size.height);
        [self.view addSubview:lockLbl];
    }else{
        [self tableView];
        // 获取图片
        [self getImgs];
    }
}

#pragma mark - 创建右边取消按钮
- (void)addNavBarCancelButton{
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                             target:self
                             action:@selector(cancelBtnTouched)];
    self.navigationItem.rightBarButtonItem = temporaryBarButtonItem;
}

#pragma mark - <UITableViewDataSource>
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.groups.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    LGPhotoPickerGroupTableViewCell *cell = (LGPhotoPickerGroupTableViewCell *)[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LGPhotoPickerGroupTableViewCell class])];
    
    if (cell == nil){
        cell = [[LGPhotoPickerGroupTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"LGPhotoPickerGroupTableViewCell"];
    }
    cell.group = self.groups[indexPath.row];
    return cell;
    
}

#pragma mark -<UITableViewDelegate>
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LGPhotoPickerGroup *group = self.groups[indexPath.row];
    self.selectGroupURL = [[group.group valueForProperty:ALAssetsGroupPropertyURL] absoluteString];
    
    LGPhotoPickerAssetsViewController *assetsVc = [[LGPhotoPickerAssetsViewController alloc] init];
    assetsVc.selectedAssetsBlock = ^(NSMutableArray *selectedAssets){
        //回传选择的照片，实现选择记忆
        self.selectAsstes = selectedAssets;
    };
    assetsVc.selectPickerAssets = self.selectAsstes;
    assetsVc.assetsGroup = group;
    assetsVc.topShowPhotoPicker = self.topShowPhotoPicker;
    assetsVc.maxCount = self.maxCount;
    [self.navigationController pushViewController:assetsVc animated:YES];
}

#pragma mark -<Images Datas>

-(void)getImgs{
    LGPhotoPickerDatas *datas = [LGPhotoPickerDatas defaultPicker];
    __weak typeof(self) weakSelf = self;
    if (self.status == PickerViewShowStatusVideo){
        // 获取所有的图片URLs
        [datas getAllGroupWithVideos:^(NSArray *groups) {
            self.groups = [[groups reverseObjectEnumerator] allObjects];
            if (self.status) {
                [self gotoHistoryGroup];
            }
            weakSelf.tableView.dataSource = self;
            [weakSelf.tableView reloadData];
        }];
        
    }else{
        // 获取所有的图片URLs
        [datas getAllGroupWithPhotos:^(NSArray *groups) {
            self.groups = [[groups reverseObjectEnumerator] allObjects];
            if (self.status) {
                [self gotoHistoryGroup];
            }
            weakSelf.tableView.dataSource = self;
            [weakSelf.tableView reloadData];
        }];
    }
}

#pragma mark 从上次选择的组别进入相册选择器
- (void) gotoHistoryGroup{
    //这里可以使用单例或者文件本地化存储实现记忆功能
    
    //当前用以下方法代替组别记忆功能
    LGPhotoPickerGroup *gp = nil;
    for (LGPhotoPickerGroup *group in self.groups) {
        if ((self.status == PickerViewShowStatusCameraRoll || self.status == PickerViewShowStatusVideo) && ([group.groupName isEqualToString:@"Camera Roll"] || [group.groupName isEqualToString:@"相机胶卷"])) {
            gp = group;
            break;
        }else if (self.status == PickerViewShowStatusSavePhotos && ([group.groupName isEqualToString:@"Saved Photos"] || [group.groupName isEqualToString:@"保存相册"])){
            gp = group;
            break;
        }else if (self.status == PickerViewShowStatusPhotoStream &&  ([group.groupName isEqualToString:@"Stream"] || [group.groupName isEqualToString:@"我的照片流"])){
            gp = group;
            break;
        }
    }
    if (!gp) return ;
    [self setupAssetsVCWithGroup:gp];
}

- (void)setupAssetsVCWithGroup:(LGPhotoPickerGroup *)group{
    LGPhotoPickerAssetsViewController *assetsVc = [[LGPhotoPickerAssetsViewController alloc] initWithShowType:self.showType];
    assetsVc.selectedAssetsBlock = ^(NSMutableArray *selectedAssets){
        //回传选择的照片，实现选择记忆
        self.selectAsstes = selectedAssets;
    };
    assetsVc.selectPickerAssets = self.selectAsstes;
    assetsVc.assetsGroup = group;
    assetsVc.topShowPhotoPicker = self.topShowPhotoPicker;
    assetsVc.maxCount = self.maxCount;
    [self.navigationController pushViewController:assetsVc animated:NO];
}

#pragma mark -<Navigation Actions>

- (void) cancelBtnTouched{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
