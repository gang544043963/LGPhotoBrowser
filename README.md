# LGPhotoBrowser

1) This framework consists of three modules:album picker,photo broswer,custom camera(support continuous shooting)； 

2) Imitation WeChat interface； 

3) Fast load local photos； 

4) Photo browser uses a background pre loading method, completely eliminate large viewing Caton phenomenon； 

5) Have the album selected group memory function； 

Explain：If the camera does not require continuous function, it is recommended the system camera. tested, and custom camera experience and memory consumption are inferior to the system camera。

Album optimization method：[http://blog.csdn.net/gang544043963/article/details/49329261](http://blog.csdn.net/gang544043963/article/details/49329261)

#1.photo broswer
<img src="https://github.com/gang544043963/MyDataSource/blob/master/browser.gif?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>


#2.album picker

<img src="https://github.com/gang544043963/MyDataSource/blob/master/picker.gif?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/> <img src="https://github.com/gang544043963/MyDataSource/blob/master/browser1.gif?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>


#3.custom camera

<img src="https://github.com/gang544043963/MyDataSource/blob/master/IMG_2653.PNG?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>  <img src="https://github.com/gang544043963/MyDataSource/blob/master/IMG_2652.PNG?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/> <img src="https://github.com/gang544043963/MyDataSource/blob/master/IMG_2651.PNG?raw=true" alt="CXLSlideList Screenshot" width="200" height="360"/>

# Adding to your preject
1)copy the folder named 'Class' to your preject.
2)'#import "LGPhoto.h"'

Explain：
1）Class folder in the third folder contains two third-party frameworks:'DACircularProgressView'&'SDWebImage'. If your project already exists in the two framework. Please manually delete the third folder corresponding to the frame.
2）Not supported cocoaPods

# INITIALIZATION
reference "ViewController" in the demo

# SUPPORT
iOS7 or later

# LICENSE
LGPhotoBrowser is released under the MIT license. See LICENSE for details.

#简介
1) 此框架包含三个模块：照片浏览器，相册选择器，自定义照相机（支持单拍、连拍）； 

2) 界面仿照微信的样式； 

3) 加载本地照片速度快； 

4) 图片浏览器采用后台预加载手段，完全消除大图浏览的卡顿现象； 

5) 具备相册已选组别记忆功能； 

说明：如果照相机不需要连拍功能，建议采用系统相机，经测试，自定义相机的体验和内存消耗均劣于系统相机。

相册优化方法：[iOS中自定义相册功能性能优化](http://blog.csdn.net/gang544043963/article/details/49329261)
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


