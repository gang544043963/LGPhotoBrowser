# LGPhotoBrowser

#前言
 **此框架经过实际项目锤炼，使用过程中改善了众多bug，在稳定性、流畅性以及内存消耗方面做了大量优化。
 但难免还有缺陷，希望同仁们在使用过程中发现并指正，并提issue！**
 
 **注意：如果照相机不需要连拍功能，建议采用系统相机，经测试，自定义相机的体验和内存消耗均劣于系统相机。**
 
 **相册优化方法：[iOS中自定义相册功能性能优化](http://blog.csdn.net/gang544043963/article/details/49329261)**

#简介
- 此框架包含三个模块：图片浏览器，相册选择器，自定义照相机（支持单拍、连拍）； 

- 界面仿照微信的样式； 

- 加载本地照片速度快； 

- 图片浏览器采用后台预加载手段，完全消除大图浏览的卡顿现象； 

- 具备相册已选组别记忆功能； 

#1.图片浏览器
<img src="https://github.com/gang544043963/MyDataSource/blob/master/browser.gif?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>


#2.相册选择器

<img src="https://github.com/gang544043963/MyDataSource/blob/master/picker.gif?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/> <img src="https://github.com/gang544043963/MyDataSource/blob/master/browser1.gif?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>


#3.自定义相机

<img src="https://github.com/gang544043963/MyDataSource/blob/master/IMG_2653.PNG?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>  <img src="https://github.com/gang544043963/MyDataSource/blob/master/IMG_2652.PNG?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/> <img src="https://github.com/gang544043963/MyDataSource/blob/master/IMG_2651.PNG?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>

# 添加到工程
第一步：拷贝class文件夹到工程.

第二步：'#import "LGPhoto.h"'

备注：

- 暂不支持cocoaPods

- 用到的第三方：
  
  |图片下载|等待框            |
  |:------:|:--------------------:|
  |SDWebImage  |DACircularProgressView|

  如果你的项目中已经存在这两个框架，请手动删除Third文件夹中对应的框架。
  
# 初始化

6行代码初始化相册选择器，里面包括大图浏览
```
/**
 *  初始化相册选择器
 */
- (void)presentPhotoPickerViewControllerWithStyle:(LGShowImageType)style {
    LGPhotoPickerViewController *pickerVc = [[LGPhotoPickerViewController alloc] initWithShowType:style];
    pickerVc.status = PickerViewShowStatusCameraRoll;
    pickerVc.maxCount = 9;   // 最多能选9张图片
    pickerVc.delegate = self;
    self.showType = style;
    [pickerVc showPickerVc:self];
}
```
如果单独使用图片浏览器，也很简单：初始化+实现数据源方法
```
/**
 *  初始化图片浏览器
 */
- (void)pushPhotoBroswerWithStyle:(LGShowImageType)style{
    LGPhotoPickerBrowserViewController *BroswerVC = [[LGPhotoPickerBrowserViewController alloc] init];
    BroswerVC.delegate = self;
    BroswerVC.dataSource = self;
    BroswerVC.showType = style;
    self.showType = style;
    [self presentViewController:BroswerVC animated:YES completion:nil];
}
```
```
#pragma mark - LGPhotoPickerBrowserViewControllerDataSource

- (NSInteger)photoBrowser:(LGPhotoPickerBrowserViewController *)photoBrowser numberOfItemsInSection:(NSUInteger)section{if (self.showType == LGShowImageTypeImageBroswer) {
        return self.LGPhotoPickerBrowserPhotoArray.count;
    } else if (self.showType == LGShowImageTypeImageURL) {
        return self.LGPhotoPickerBrowserURLArray.count;
    } else {
        NSLog(@"非法数据源");
        return 0;
    }
}
//在这里，需要把图片包装成LGPhotoPickerBrowserPhoto对象，然后return即可。
- (id<LGPhotoPickerBrowserPhoto>)photoBrowser:(LGPhotoPickerBrowserViewController *)pickerBrowser photoAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showType == LGShowImageTypeImageBroswer) {
        return [self.LGPhotoPickerBrowserPhotoArray objectAtIndex:indexPath.item];
    } else if (self.showType == LGShowImageTypeImageURL) {
        return [self.LGPhotoPickerBrowserURLArray objectAtIndex:indexPath.item];
    } else {
        NSLog(@"非法数据源");
        return nil;
    }
}

```
详见ViewController.m，注释很清楚

# 环境支持
iOS7及更高

# LICENSE
LGPhotoBrowser is released under the MIT license. See LICENSE for details.

