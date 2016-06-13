# LGPhotoBrowser

1) 此框架包含三个模块：照片浏览器，相册选择器，自定义照相机（支持单拍、连拍）； 

2) 界面仿照微信的样式； 

3) 加载本地照片速度快； 

4) 图片浏览器采用后台预加载手段，完全消除大图浏览的卡顿现象； 

5) 具备相册已选组别记忆功能； 

说明：如果照相机不需要连拍功能，建议采用系统相机，经测试，自定义相机的体验和内存消耗均劣于系统相机。

#1.照片浏览器
<img src="https://github.com/gang544043963/LGSelectButtonView/blob/master/LGSelectButton.gif?raw=true" alt="CXLSlideList Screenshot" width="370" height="686"/>
<img src="https://github.com/gang544043963/MyDataSource/tree/master/gif/browser.gif?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>


#2.相册选择器
全局浏览和预览，采用后台预加载，完全消除卡顿现象

<img src="https://github.com/gang544043963/MyDataSource/tree/master/gif/picker.gif?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/> <img src="https://github.com/gang544043963/MyDataSource/tree/master/gif/browser1.gif?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>


#3.照相机
拍照页面,单拍结果,连拍结果

<img src="https://github.com/gang544043963/MyDataSource/tree/master/gif/IMG_2653.PNG?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>  <img src="https://github.com/gang544043963/LGPhotoBrowser/blob/master/LGPhotoBrowser/gif/IMG_2652.PNG?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/> <img src="https://github.com/gang544043963/MyDataSource/tree/master/gif/IMG_2651.PNG?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>

# 添加到工程
第一步：拷贝class文件夹到工程.

第二步：'#import "LGPhoto.h"'

备注：

a. 暂不支持cocoaPods

b. class文件夹中的Third文件夹包含了两个第三方框架：'DACircularProgressView'和'SDWebImage'，如果你的项目中已经存在这两个框架，请手动删除Third文件夹中对应的框架。

# 初始化
见ViewController.m，注释很清楚

# 环境支持
iOS7及更高

# Adding to your preject
copy the folder named 'Class' to your preject.

'#import "LGPhoto.h"'

# INITIALIZATION
reference ViewController

# SUPPORT
iOS7 or later

# LICENSE
LGPhotoBrowser is released under the MIT license. See LICENSE for details.
