    Title: system reinstall
    Date: 2016-07-17T16:53:10
    Tags: 重装,双系统,ubuntu,windows10,ssd,混合硬盘

##   基本情况和要求介绍
- 双硬盘,一块128G的ssd,一块500G的机械硬盘
- 8G内存
- N卡加intel集显
- 最后要求双系统,Ubuntu14.04LTS + Windows10

<!-- more -->

##   安装准备
- 两个u盘,刻好windows和ubuntu的镜像文件
- 备份好你的重要资料
- 将bios设置为u盘启动
- bios中SATA Configuration设置为AHCI

##   安装windows
    由于之前安装过windows10并且是正版激活的所以并不需要密匙.
    安装的时候把所有的盘全部格掉(为了ssd的4k对齐),
    我在ssd上分了40G给windows,作为c盘.
    机械盘划了100G作为软件安装盘(windows10从软件商店上安装的软件可以从系统设置为安装到其他的盘)
    机械盘再划100G作为仓库盘(这个盘是windows和ubuntu共用的用来储存资料,在两个系统之间共享文件)
    以上所有的盘都采用NTFS格式

##   安装Ubuntu
    将SSD剩下所有的容量都分给ubuntu.安装的时候注意选择自定义
    分区如下

    -   1G /boot
    -   40G /
    -   剩下的划给/home
    -   还在机械上划了8G用作swap(似乎没什么必要)
    以上除了swap.所有的盘符采用EXT4格式,将home单独挂在可以方便将来重装

## 配置windows
-   安装驱动,基本win10自己就可以帮你做好了
-   从电源管理中,将快速启动关闭,已经将系统装在SSD上面所以开机速度基本没有太大差别(这么做是为了让ubuntu能够挂载windows的分区)
-   将windows的安装设置设置到机械硬盘
-   将默认的下载,文档,音乐,..都设置为另一个机械盘分区里面的相应文件夹



## 配置ubuntu

- ## N卡驱动的安装

--    1,添加Graphic Drivers PPA

```shell
sudo add-apt-repository ppa:graphics-drivers/ppa
```

--   2,更新或安装最新Nvidia驱动程序

```shell
sudo apt-get update && sudo apt-get install nvidia-355
```
这已经是我知道的最简单的方法了,linux的驱动问题一直都挺让我头痛的.这样安装完成之后在我的机器上
会导致开机默认亮度最大,fn+热键无法调节亮度

-   ### 优化SSD
可以参考以下[文章](sites.google.com/site/easylinuxtipsproject/ssd#TOC-Avoid-quick-wear:-reduce-write-actions)


- ### 自动挂载
使用ubuntu自带的磁盘管理工具将仓库盘设置为开机自动挂在,挂载点记得选择挂在到/media/你的用户名/盘名
我的挂载点是/media/richard/EECC1B6ACC1B2C79/

- ### 修改默认路径
修改~/.config/user-dirs.dirs 文件以下是我的配置文件

``` txt
# This file is written by xdg-user-dirs-update
# If you want to change or add directories, just edit the line you're
# interested in. All local changes will be retained on the next run
# Format is XDG_xxx_DIR="$HOME/yyy", where yyy is a shell-escaped
# homedir-relative path, or XDG_xxx_DIR="/yyy", where /yyy is an
# absolute path. No other format is supported.
#
XDG_DESKTOP_DIR="$HOME/桌面"
XDG_DOWNLOAD_DIR="/media/richard/EECC1B6ACC1B2C79/下载"
XDG_TEMPLATES_DIR="$HOME/模板"
XDG_PUBLICSHARE_DIR="$HOME/公共的"
XDG_DOCUMENTS_DIR="/media/richard/EECC1B6ACC1B2C79/文档"
XDG_MUSIC_DIR="/media/richard/EECC1B6ACC1B2C79/音乐"
XDG_PICTURES_DIR="/media/richard/EECC1B6ACC1B2C79/图片"
XDG_VIDEOS_DIR="/media/richard/EECC1B6ACC1B2C79/视频"
```

你可以参考并修改为自己相应的机械硬盘的位置(即我们之前分出来用作仓库盘的地方)
这样ubuntu的默认的下载,文档,音乐等等的位置就和windows在同一个物理位置了

## 结束语

接下来就是各种软件的安装了(挺费时间的),把备份的资料拷到电脑里.
原本我是把ubuntu安装在机械盘上面,ubuntu随着我的升级折腾已经是千疮百孔.开机每次都要等两分半左右
而几乎千年不开机的windows占用着ssd,所以才有了这次的重装,目的就是稳定高效.可以让两个系统共享一个盘符
作为仓库盘,免去了重启切换系统的麻烦.有些软件在windows和ubuntu平台下的配置文件是通用的,可以把他们的工作路径也设置为同一个位置
这样就有了不同系统下一致同步的体验了.安装完成后ubuntu开机几乎10s之内,各种软件
丝滑流畅
