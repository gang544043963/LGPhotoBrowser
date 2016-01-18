//
//  LGPhotoPickerBrowserViewController.m
//  LGPhotoBrowser
//
//  Created by ligang on 15/10/27.
//  Copyright (c) 2015年 L&G. All rights reserved.

#import <AssetsLibrary/AssetsLibrary.h>
#import "LGPhotoPickerBrowserViewController.h"
#import "LGPhotoRect.h"
#import "LGImagePickerSelectView.h"
#import "LGPhotoPickerCustomToolBarView.h"
#import "LGPhotoAssets.h"
#import "LGPhotoPickerCommon.h"

static NSString *_cellIdentifier = @"collectionViewCell";

typedef NS_ENUM(NSInteger, DraggingDirect) {
    MIDDLE ,  //没有滑动
    LEFT ,
    RIGHT
};

@interface LGPhotoPickerBrowserViewController () <UIScrollViewDelegate,LGPhotoPickerPhotoScrollViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,LGPhotoPickerCustomToolBarViewDelegate>

// 控件
@property (nonatomic, weak)  UILabel          *pageLabel;
@property (nonatomic, weak)  UIButton         *backBtn;
@property (nonatomic, weak)  UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isNowRotation;
@property (nonatomic, weak)  LGImagePickerSelectView *imagePickerSelectView;
@property (nonatomic, strong) LGPhotoPickerCustomToolBarView *XGtoolbar;
@property (nonatomic, weak) LGPhotoPickerBrowserPhotoScrollView *cellScrollView;
@property (nonatomic, strong) UIImage *displayImage;
@property (nonatomic, assign) CGFloat beginDraggingContentOffsetX;
@property (nonatomic, assign) DraggingDirect draggingDirect;
@property (nonatomic, assign) BOOL scrollToEndFlag;
@property (nonatomic, assign) BOOL needHidenBar; // YES - 隐藏顶部和底部bar，单击照片dismiss
@property (nonatomic, assign) BOOL isOriginal;

@end

@implementation LGPhotoPickerBrowserViewController

#pragma mark - dealloc

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
    self.dataSource = nil;
}

#pragma mark - setter

- (void)setShowType:(LGShowImageType)showType
{
    _showType = showType;
    if (self.showType != LGShowImageTypeImagePicker){
        self.needHidenBar = YES;
    }
}

#pragma mark - getter
#pragma mark photos
- (NSArray *)photos{
    if (!_photos) {
        _photos = [self getPhotos];
    }
    return _photos;
}

#pragma mark setupCollectionView
- (void)setupCollectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = LGPickerColletionViewPadding;
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = self.view.size;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        CGRect frame = self.view.bounds;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width + LGPickerColletionViewPadding,self.view.height) collectionViewLayout:flowLayout];
        
        collectionView.showsHorizontalScrollIndicator = YES;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.backgroundColor = [UIColor blackColor];
        collectionView.bounces = YES;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];

        [self.view addSubview:collectionView];
        self.collectionView = collectionView;

        self.pageLabel.hidden = NO;
    }
}

#pragma mark pageLabel
- (UILabel *)pageLabel{
    if (!_pageLabel) {
        UILabel *pageLabel = [[UILabel alloc] init];
        pageLabel.font = [UIFont systemFontOfSize:18];
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.userInteractionEnabled = NO;
        pageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        pageLabel.backgroundColor = [UIColor clearColor];
        pageLabel.textColor = [UIColor whiteColor];
        [self.view addSubview:pageLabel];
        self.pageLabel = pageLabel;
        
        NSString *widthVfl = @"H:|-0-[pageLabel]-0-|";
        NSString *heightVfl = @"V:[pageLabel(ZLPickerPageCtrlH)]-20-|";
        NSDictionary *views = NSDictionaryOfVariableBindings(pageLabel);
        NSDictionary *metrics = @{@"ZLPickerPageCtrlH":@(LGPickerPageCtrlH)};
        
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:metrics views:views]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:metrics views:views]];
        
    }
    return _pageLabel;
}

#pragma mark getPhotos
- (NSArray *)getPhotos{
    NSMutableArray *photos = [NSMutableArray arrayWithArray:_photos];
    if ([self isDataSourceElsePhotos]) {
        NSInteger section = self.currentIndexPath.section;
        NSInteger rows = [self.dataSource photoBrowser:self numberOfItemsInSection:section];
        photos = [NSMutableArray arrayWithCapacity:rows];
        for (NSInteger i = 0; i < rows; i++) {
            [photos addObject:[self.dataSource photoBrowser:self photoAtIndexPath:[NSIndexPath indexPathForItem:i inSection:section]]];
        }
    }
    return photos;
}

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCollectionView];
    [self setupTopView];
    [self setupXGToolbar];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.navigationController.navigationBarHidden = YES;
    [self reloadData];
    [self updateXGToolbar];
    [self updateSelectBtn];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.photos.count == 0) {
        NSAssert(self.dataSource, @"你没成为数据源代理");
    }
    
    [self prepareLeftAndRighImage];
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    self.navigationController.navigationBarHidden = NO;
    self.scrollToEndFlag = 0;
}

#pragma mark - ImagePickerSelectView 相关
- (void)setupTopView {
    self.navigationController.navigationBarHidden = YES;
    if ((!_imagePickerSelectView) && (!self.needHidenBar)) {
        LGImagePickerSelectView *imagePickerSelectView = [[LGImagePickerSelectView alloc] init];
        _imagePickerSelectView = imagePickerSelectView;
        [_imagePickerSelectView addTarget:self backAction:@selector(back) selectAction:@selector(selectedButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_imagePickerSelectView];
    }
    [self updateSelectBtn];
}

- (void)back {
    // 执行代理，向上一级控制器传递selectedAssets
    if ([self.delegate respondsToSelector:@selector(photoBrowserWillExit:)]) {
        [self.delegate photoBrowserWillExit:self];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectedButtonTapped {
    LGPhotoAssets *selectAsset = ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage]).asset;
    
    // 0. 九张图片数量限制
    if (self.selectedAssets.count >= KPhotoShowMaxCount && !_imagePickerSelectView.selectBtn.selected) {
        NSString *format = [NSString stringWithFormat:@"最多只能选择%ld张图片",(long)self. maxCount];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:format delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        return ;
    }
    
    //1. 刷新选择按钮的图片
    _imagePickerSelectView.selectBtn.selected = !_imagePickerSelectView.selectBtn.selected;

    // 2. selectedAssets增加或删除
    if (_imagePickerSelectView.selectBtn.selected) {
        [self.selectedAssets addObject:selectAsset];
    } else {
        [self.selectedAssets removeObject:selectAsset];
    }

    // 3. 刷新底部toolbar
    [self updateXGToolbar];
}

#pragma mark - XGToolbar 相关
- (void)setupXGToolbar
{
    if ((!_XGtoolbar)  && (!self.needHidenBar)) {
        CGFloat height = 44;
        _XGtoolbar = [[LGPhotoPickerCustomToolBarView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) - height, CGRectGetWidth(self.view.bounds), height) showType:self.showType];
        _XGtoolbar.delegate = self;
        __weak LGPhotoPickerBrowserViewController * weakself = self;
        
        _XGtoolbar.getSizeBlock = ^(){
            LGPhotoPickerBrowserPhoto *photo = weakself.photos[weakself.currentPage];
            ALAssetRepresentation *rep = [photo.asset.asset defaultRepresentation];
            NSString *fileSize = [NSString stringWithFormat:@"(%@)",[weakself getFileSizeByBt:[NSNumber numberWithLongLong:rep.size]]];
            return fileSize;
        };
        
        [self.view addSubview:_XGtoolbar];
    }
}
- (NSString *)getFileSizeByBt:(NSNumber *)fileSize{
    CGFloat size = [fileSize floatValue];
    if (size >= 1024*1024*1024) {
        return [NSString stringWithFormat:@"%.2fG",size/(1024*1024*1024)];
    }else if (size >= 1024*1024) {
        return [NSString stringWithFormat:@"%.2fM",size/(1024*1024)];
    }else{
        return [NSString stringWithFormat:@"%.2fK",size/1024];
    }
}

#pragma mark - reloadData

- (void)reloadData{
    if (self.currentPage <= 0){
        self.currentPage = self.currentIndexPath.item;
    }else{
        --self.currentPage;
    }
    
    if (self.currentPage >= self.photos.count) {
        self.currentPage = self.photos.count - 1;
    }

    [self setPageLabelPage:self.currentPage];
    
    if (self.currentPage >= 0) {
        CGPoint point = CGPointMake(self.currentPage * self.collectionView.width, 0);
        NSLog(@"%ld,%f,%f",(long)self.currentPage , self.collectionView.width,point.x);
        self.collectionView.contentOffset = point;
        self.beginDraggingContentOffsetX = self.collectionView.contentOffset.x;
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([self isDataSourceElsePhotos]) {
        return [self.dataSource photoBrowser:self numberOfItemsInSection:self.currentIndexPath.section];
    }
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    if (collectionView.isDragging) {
        cell.hidden = NO;
    }
    if (self.photos.count) {
        LGPhotoPickerBrowserPhoto *photo = nil;
        photo = self.photos[indexPath.item];
        if([[cell.contentView.subviews lastObject] isKindOfClass:[UIView class]]){
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        
        CGRect tempF = [UIScreen mainScreen].bounds;
        UIView *scrollBoxView = [[UIView alloc] init];
        scrollBoxView.frame = tempF;
        scrollBoxView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:scrollBoxView];
        
        LGPhotoPickerBrowserPhotoScrollView *scrollView =  [[LGPhotoPickerBrowserPhotoScrollView alloc] init];
        [scrollBoxView addSubview:scrollView];
        scrollView.showType = self.showType;
        // 为了监听单击photoView事件
        scrollView.frame = tempF;
        scrollView.tag = 101;
        scrollView.photoScrollViewDelegate = self;
        scrollView.photo = photo;
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _cellScrollView = scrollView;
    }
    return cell;
}

- (NSUInteger)getRealPhotosCount{
    if ([self isDataSourceElsePhotos]) {
        return [self.dataSource photoBrowser:self numberOfItemsInSection:self.currentIndexPath.section];
    }
    return self.photos.count;
}

-(void)setPageLabelPage:(NSInteger)page{
    self.pageLabel.text = [NSString stringWithFormat:@"%ld / %ld",(unsigned long)(page + 1), (unsigned long)self.photos.count];
        self.title = self.pageLabel.text;
}

#pragma mark - <UIScrollViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(LGPickerColletionViewPadding, self.view.frame.size.height);
}

#pragma mark 滚动过程中重复调用
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.isNowRotation) {
        self.isNowRotation = NO;
        return;
    }
    CGRect tempF = self.collectionView.frame;
    NSInteger currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.frame.size.width) + 0.5);
    [self setPageLabelPage:currentPage];
    if (tempF.size.width < [UIScreen mainScreen].bounds.size.width){
        tempF.size.width = [UIScreen mainScreen].bounds.size.width;
    }

    self.collectionView.frame = tempF;
    self.draggingDirect = [self getDraggingDirect];
}

#pragma mark 将要减速
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    
}

#pragma mark 减速完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didCurrentPage:)]) {
        [self.delegate photoBrowser:self didCurrentPage:self.currentPage];
    }
    self.beginDraggingContentOffsetX = self.collectionView.contentOffset.x;
    [self updateSelectBtn];
    [self updateXGToolbar];
}

#pragma mark 将要结束拖拽
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    //如果滑动松开手后回滚动到下一个页面
    if (targetContentOffset->x != _beginDraggingContentOffsetX) {
        DraggingDirect direct = [self getDraggingDirect];
        //获得currentPage
        if (direct == LEFT) {
            self.currentPage = (NSInteger)(scrollView.contentOffset.x / (scrollView.frame.size.width) + 0.9);
            if (self.currentPage > self.photos.count - 1) {
                self.currentPage --;
            }
        } else if (direct == RIGHT) {
            self.currentPage = (NSInteger)(scrollView.contentOffset.x / (scrollView.frame.size.width));
        }
        
        //获得image
        dispatch_queue_t queue = dispatch_queue_create("BeginDecelerating", DISPATCH_QUEUE_SERIAL);
        dispatch_async(queue, ^{
            //获取下一张image
            [self loadNextImageWithDirect:direct];
        });
    }
}

- (void)updateSelectBtn {
    _imagePickerSelectView.selectBtn.selected = NO;
    LGPhotoAssets *photoAsset = ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage]).asset;
    
    for (LGPhotoAssets *asset in self.selectedAssets) {
        if ([[asset assetURL] isEqual:[photoAsset assetURL]]) {
            _imagePickerSelectView.selectBtn.selected = YES;
            break;
        }
    }
}

- (void)updateXGToolbar
{
    [self.XGtoolbar updateToolbarWithOriginal:self.isOriginal
                                  currentPage:self.currentPage
                                selectedCount:self.selectedAssets.count];
}

- (BOOL)isDataSourceElsePhotos{
    return self.dataSource != nil;
}

#pragma mark - <PickerPhotoScrollViewDelegate>
- (void)pickerPhotoScrollViewDidSingleClick:(LGPhotoPickerBrowserPhotoScrollView *)photoScrollView{
    if (self.needHidenBar) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    static CGFloat alphaValue = 1;
    alphaValue = alphaValue? 0 : 1;
    [UIView animateWithDuration:0.3 animations:^(void) {
        [_imagePickerSelectView setAlpha:alphaValue];
        [_XGtoolbar setAlpha:alphaValue];
    } completion:nil];
}

- (void) pickerPhotoScrollViewDidLongPressed:(LGPhotoPickerBrowserPhotoScrollView *)photoScrollView{
    [self longPressAction];
}

#pragma mark - ZLPhotoPickerCustomToolBarViewDelegate
- (void)customToolBarIsOriginalBtnTouched {
    self.isOriginal = !self.isOriginal;
    [self updateXGToolbar];
}

- (void)customToolBarSendBtnTouched{
    
    [self dismissViewControllerAnimated:NO completion:nil];
    if ([self.delegate respondsToSelector:@selector(photoBrowserSendBtnTouched:isOriginal:)]) {
        [self.delegate photoBrowserSendBtnTouched:self isOriginal:self.isOriginal];
    }
}

- (DraggingDirect)getDraggingDirect
{
    DraggingDirect direct;
    if (self.beginDraggingContentOffsetX == self.collectionView.contentOffset.x
        ) {
        direct = MIDDLE;
    } else if (self.beginDraggingContentOffsetX > self.collectionView.contentOffset.x) {
        direct = RIGHT;
    } else {
        direct = LEFT;
    }
    return direct;
}

#pragma mark - 照片预加载相关
/**
 *  在viewDidAppear中调用
 *  准备当前页面两边的imange
 */
- (void)prepareLeftAndRighImage {
    if (self.photos.count > 1) {
        if (self.currentPage == 0) {//从第一张进入
            if (!((LGPhotoPickerBrowserPhoto *)self.photos[1]).photoImage) {
                LGPhotoAssets *asset = ((LGPhotoPickerBrowserPhoto *)self.photos[1]).asset;
                ((LGPhotoPickerBrowserPhoto *)self.photos[1]).photoImage = [asset originImage];
            }
        } else if (self.currentPage == self.photos.count - 1) {//从第最后一张进入
            if (!((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).photoImage) {
                LGPhotoAssets *asset = ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).asset;
                ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).photoImage = [asset originImage];
            }
        } else {
            if (!((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage + 1]).photoImage) {
                LGPhotoAssets *asset = ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage + 1]).asset;
                ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage + 1]).photoImage = [asset originImage];
            }
            if (!((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).photoImage) {
                LGPhotoAssets *asset1 = ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).asset;
                ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).photoImage = [asset1 originImage];
            }
        }
    }
    if (self.photos.count == 2) {//两张图片时，在这里做预处理
        self.scrollToEndFlag = 1;
    }
}


/**
 *  根据上一次的滑动方向，加载下一张图
 */
- (void)loadNextImageWithDirect:(DraggingDirect)direct {
    if (direct == LEFT && self.currentPage < self.photos.count - 1){
        if (!((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage + 1]).photoImage) {
            LGPhotoAssets *asset = ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage + 1]).asset;
            ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage + 1]).photoImage = [asset originImage];
        }
    } else if(direct == RIGHT && self.currentPage > 0){
        if (!((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).photoImage) {
            LGPhotoAssets *asset = ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).asset;
            ((LGPhotoPickerBrowserPhoto *)self.photos[self.currentPage - 1]).photoImage = [asset originImage];
        }
    } else ;
}

#pragma mark - 长按动作
- (void)longPressAction {
    NSLog(@"long pressed");
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        if([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
            UIImageWriteToSavedPhotosAlbum(_cellScrollView.photoImageView.image, nil, nil, nil);
            if (_cellScrollView.photoImageView.image) {
                [self showMessageWithText:@"保存成功"];
            }
        }else{
            if (_cellScrollView.photoImageView.image) {
                [self showMessageWithText:@"没有用户权限,保存失败"];
            }
        }
    }
}

- (void)showMessageWithText:(NSString *)text{
    UILabel *alertLabel = [[UILabel alloc] init];
    alertLabel.font = [UIFont systemFontOfSize:15];
    alertLabel.text = text;
    alertLabel.textAlignment = NSTextAlignmentCenter;
    alertLabel.layer.masksToBounds = YES;
    alertLabel.textColor = [UIColor whiteColor];
    alertLabel.bounds = CGRectMake(0, 0, 100, 80);
    alertLabel.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    alertLabel.backgroundColor = [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1.0];
    alertLabel.layer.cornerRadius = 10.0f;
    [[UIApplication sharedApplication].keyWindow addSubview:alertLabel];
    
    [UIView animateWithDuration:.5 animations:^{
        alertLabel.alpha = 0.0;
    } completion:^(BOOL finished) {
        [alertLabel removeFromSuperview];
    }];
}

- (id<LGPhotoPickerBrowserPhoto>)currentPhoto{
    return _cellScrollView.photo;
}

- (void)forwardImageChatMessage{
    
}

- (void)hiddenSavingStatusView{
    for (UIView *view in [self.view subviews]) {
        if (view.tag == 100) {
            [view removeFromSuperview];
        }
    }
}


- (UIView *)getParsentView:(UIView *)view{
    return nil;
}
- (id)getParsentViewController:(UIView *)view{
    return nil;
}
- (void)showHeadPortrait:(UIImageView *)toImageView {

}

- (void)showHeadPortrait:(UIImageView *)toImageView originUrl:(NSString *)originUrl{

}
@end