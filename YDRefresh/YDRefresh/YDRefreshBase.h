//
//  DDRefreshBase.h
//  DDRefresh
//
//  Created by yutongmac on 2017/3/11.
//  Copyright © 2017年 yutongmac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+YDRefreshExtension.h"
#import "YDRefreshConmmon.h"
#import <objc/runtime.h>
@class YDRefreshBase;

@protocol YDRefreshBaseDelegate <NSObject>

- (void)normalStatus;
- (void)refreshStatus;
- (void)pulledStatus;

@optional
- (void)normal2pulled:(CGFloat)contentOffSide;
- (void)pulled2nomal:(CGFloat)contentOffSide;

@end
typedef void (^YDRefreshBlock)();

@interface YDRefreshBase : UIView
//保存刷新的控件，UIScrollView、UITableView、UICollectionView
@property (nonatomic, weak) UIScrollView *scrollView;
//代理
@property (nonatomic, weak) id <YDRefreshBaseDelegate> delegate;
//上拉、下拉
@property (nonatomic, assign) YDRefreshOptions option;
//加载中底部按钮显示文字
@property (nonatomic, copy) NSString *loadingFootTitle;
//加载完成底部按钮显示文字
@property (nonatomic, copy) NSString *finishedFootTitle;
//以Block方式创建下拉刷新任务
+ (instancetype)refreshWithHeader:(YDRefreshBlock)headerBlock;
//以Block方式创建上拉加载任务
+ (instancetype)refreshWithFooter:(YDRefreshBlock)footerBlock;
//以Action方式创建刷新任务
+ (instancetype)refreshWithTarget:(id)target headerAction:(SEL)headerAction;
//以Action方式创建刷新任务
+ (instancetype)refreshWithTarget:(id)target footerAction:(SEL)footerAction;
//结束下拉刷新
- (void)endHeaderRefresh;
//结束上拉加载
- (void)endFooterRefresh;
//开始下拉刷新
- (void)beginHeaderRefresh;
//开始上拉加载
- (void)beginFooterRefresh;
//判断下拉刷新状态
- (BOOL)isHeaderRefresh;
//判断上拉加载状态
- (BOOL)isFooterRefresh;
//监听ContenSize改变事件
- (void)scrollViewContentSizeChange:(NSDictionary *)change;
//监听滚动事件
- (void)scrollViewContentOffsetChange:(NSDictionary *)change;
//为下拉刷新控件添加子控件
- (void)setupHeaderWithSuperView:(UIView *)newSuperView;
//为上拉加载添加子控件
- (void)setupFooterWithSuperView:(UIView *)newSuperView;
//获取最后一次更新时间
- (NSString *)getLastRefreshTime:(NSString *)key;
//设置当前更新时间
- (void)setRefreshTime:(NSDate *)date;
//底部刷新
- (void)bottomRefresh;
@end

//添加UIScrollView分类
@interface UIScrollView (YDScrollViewRefresh)
//在分类中给UIScrollView添加一个属性，这个属性可以用runtime添加一个set和get方法
@property (nonatomic, weak) YDRefreshBase *ydHeaderRefresh;
@property (nonatomic, weak) YDRefreshBase *ydFooterRefresh;

@end
