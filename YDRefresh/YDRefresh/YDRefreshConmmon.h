//
//  DDConmmon.h
//  DDRefresh
//
//  Created by yutongmac on 2017/3/11.
//  Copyright © 2017年 yutongmac. All rights reserved.
//

#ifndef YDRefreshConmmon_h
#define YDRefreshConmmon_h

#define YDContentOffset @"contentOffset"
#define YDContentSize @"contentSize"

#define YDLastRefreshTime (@"LastRefreshTime")
#define YDRefreshResourceName(file) [@"SCRefresh.bundle" stringByAppendingPathComponent:file]

//下拉刷新
#define YDStaticTopTitle (@"下拉可以刷新")
#define YDScrollTopTitle (@"松开立即刷新")
#define YDRefreshingTopTitle (@"正在刷新数据中...")

//下拉加载
#define YDStaticBottomTitle (@"点击或上拉加载更多")
#define YDRefreshingBottomTitle (@"正在加载更多的数据...")

#define YDDisappearTime (0.3) ///从刷新停留到上面到刷新消失在导航栏之后的时间
#define YDRemainTime (0.8)    ///刷新控件紧挨着导航栏停留的时间
#define YDFinshRemainTime (2.0)    ///有finishedFootTitle的显示时间

///颜色
#define YDRefreshColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

//控件高度
#define YDRefreshHeight (54)
#define YDBottomHeight (64)

///根据位操作判断下拉和上拉是否添加
typedef NS_OPTIONS(NSUInteger, YDRefreshOptions) {
    YDRefreshOptionHeader = 0x01,
    YDRefreshOptionFooter = 0x02
};

///下拉三种状态
///normal 是未超过设定下拉高度
typedef NS_ENUM(NSInteger, YDRefreshStatus) {
    YDRefreshStateNormal = 0,
    YDRefreshStatePulled,
    YDRefreshStateRefresh
};


#define YDSuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

static NSString *YDHeaderRefresh = @"YDHeaderRefresh";
static NSString *YDFooterRefresh = @"YDFooterRefresh";

static const char YDHeaderRefreshKey = 'h';
static const char YDFooterRefreshKey = 'f';



#endif /* DDConmmon_h */
