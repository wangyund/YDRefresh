//
//  DDRefreshBase.m
//  DDRefresh
//
//  Created by yutongmac on 2017/3/11.
//  Copyright © 2017年 yutongmac. All rights reserved.
//

#import "YDRefreshBase.h"

@interface YDRefreshBase () {
    //内边距，用于恢复下拉刷新完成之后控件的显示样式
    UIEdgeInsets _scrollViewOrginInsets;
}
//下拉状态
@property (nonatomic, assign) YDRefreshStatus status;
//上拉状态
@property (nonatomic, assign) BOOL bottomRefreshStatus;
@property (nonatomic, copy) YDRefreshBlock header;
@property (nonatomic, copy) YDRefreshBlock footer;
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL topAction;
@property (nonatomic, assign) SEL bottomAction;

@end

@implementation YDRefreshBase
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.status = YDRefreshStateNormal;
    }
    return self;
}
- (void)innerRefresh:(YDRefreshOptions)type {
    switch (type) {
        case YDRefreshOptionHeader:{
            self.status == YDRefreshStateNormal ? [self manualRefresh]:[self automaticRefresh];
            break;
        }
        case YDRefreshOptionFooter:{
            [self bottomRefresh];
            break;
        }
        default:
            break;
    }
}
//正常手动进行的下拉刷新
- (void)manualRefresh {
    [UIView animateWithDuration:YDDisappearTime animations:^{
        self.scrollView.contentOffset = CGPointMake(0, - YDRefreshHeight -5);
    }];
    //这里只是让刷新有短暂的停留
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(YDRemainTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //Block方式执行
        if (self.header) {
            self.header();
        }
        //Target方式执行
        if ([self.target respondsToSelector:self.topAction]) {
            YDSuppressPerformSelectorLeakWarning([self.target performSelector:self.topAction]);
        }
        [UIView animateWithDuration:YDDisappearTime animations:^{
            self.scrollView.contentOffset = CGPointZero;
        }];
    });
}
//直接调用刷新代码进行的下拉刷新
- (void)automaticRefresh {
    [UIView animateWithDuration:YDDisappearTime animations:^{
        self.scrollView.contentInset = UIEdgeInsetsMake(YDRefreshHeight, 0, _scrollViewOrginInsets.bottom, 0);
    }];
    //这里只是让刷新有短暂的停留
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(YDRemainTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.header) {
            self.header();
        }
        if ([self.target respondsToSelector:self.topAction]) {
            YDSuppressPerformSelectorLeakWarning([self.target performSelector:self.topAction]);
        }
    });
}
//底部刷新
- (void)bottomRefresh {
    if ([self isFooterRefresh]) {
        return;
    }
    self.bottomRefreshStatus = true;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.48 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //Block方式执行
        if (self.footer) {
            self.footer();
        }
        if (self.bottomAction) {
            YDSuppressPerformSelectorLeakWarning([self.target performSelector:self.bottomAction]);
        }
    });
    [self beginFooterRefresh];
}

#pragma mark ==从父类上移动或添加==
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    //确保newSuperview是UIScrollView类型
    if (newSuperview && [newSuperview isKindOfClass:[UIScrollView class]]) {
        //先移除先前的观察者
        [self removeObserver];
        //scrollView属性保存谁在使用刷新
        self.scrollView = (UIScrollView *)newSuperview;
        self.scrollView.alwaysBounceVertical = true;
        //保存scrollView中的原始内边距
        _scrollViewOrginInsets = self.scrollView.contentInset;
        //为scrollView添加观察者
        [self addObserver];
        //如果是创建下拉刷新，header
        if ((self.option & YDRefreshOptionHeader) == YDRefreshOptionHeader)  {
            [self setupHeaderWithSuperView:newSuperview];
        }
        //如果是创建上拉加载，footer
        if ((self.option & YDRefreshOptionFooter) == YDRefreshOptionFooter) {
            [self setupFooterWithSuperView:newSuperview];
        }
    }
}
- (void)removeFromSuperview {
    [self removeObserver];
    [super removeFromSuperview];
}
#pragma mark ==创建上拉和下拉控件==
//为下拉刷新控件添加子控件
- (void)setupHeaderWithSuperView:(UIView *)newSuperView {
}
//为上拉加载控件添加子控件
- (void)setupFooterWithSuperView:(UIView *)newSuperView {
    //设置底部内边距
    self.scrollView.contentInset = UIEdgeInsetsMake(_scrollViewOrginInsets.top, 0, YDBottomHeight, 0);
}
#pragma mark ==处理观察者==
//移除观察者
- (void)removeObserver {
    [self.superview removeObserver:self forKeyPath:YDContentOffset];
    [self.superview removeObserver:self forKeyPath:YDContentSize];
}
//添加观察者
- (void)addObserver {
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.scrollView addObserver:self forKeyPath:YDContentOffset options:options context:nil];
    [self.scrollView addObserver:self forKeyPath:YDContentSize options:options context:nil];
}
#pragma mark ==添加刷新方法==
+ (instancetype)refreshWithHeader:(YDRefreshBlock)headerBlock {
    YDRefreshBase *ddRefresh = [[self alloc] init];
    //记录以Block方式建立下拉刷新
    ddRefresh.header = headerBlock;
    ddRefresh.option |= YDRefreshOptionHeader;
    return ddRefresh;
}
+ (instancetype)refreshWithFooter:(YDRefreshBlock)footerBlock {
    YDRefreshBase *ddRefresh = [[self alloc] init];
    //记录以Block方式建立上拉加载
    ddRefresh.footer = footerBlock;
    ddRefresh.option |= YDRefreshOptionFooter;
    return ddRefresh;
}
+ (instancetype)refreshWithTarget:(id)target headerAction:(SEL)headerAction {
    if (!target) {
        return nil;
    }
    YDRefreshBase *ddRefreshBase = [[self alloc] init];
    ddRefreshBase.target = target;
    //记录以Action的方式下拉刷新
    ddRefreshBase.option |= YDRefreshOptionHeader;
    ddRefreshBase.topAction = headerAction;
    return ddRefreshBase;
}
+ (instancetype)refreshWithTarget:(id)target footerAction:(SEL)footerAction {
    if (!target) {
        return nil;
    }
    YDRefreshBase *ddRefreshBase = [[self alloc] init];
    ddRefreshBase.target = target;
    //记录以Action的方式上拉加载
    ddRefreshBase.option |= YDRefreshOptionFooter;
    ddRefreshBase.bottomAction = footerAction;
    return ddRefreshBase;
}

#pragma mark ==处理监听事件==
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:YDContentOffset]) {
        [self scrollViewContentOffsetChange:change];
    }else if ([keyPath isEqualToString:YDContentSize]){
        [self scrollViewContentSizeChange:change];
    }
}
//监听ContentSize改变事件
- (void)scrollViewContentSizeChange:(NSDictionary *)change {
}
//监听滚动事件
- (void)scrollViewContentOffsetChange:(NSDictionary *)change {
    CGFloat orginY = -[[change objectForKey:@"new"] CGPointValue].y;
    CGFloat calculateY = orginY - _scrollViewOrginInsets.top;
    //存在下拉刷新
    if (self.option & YDRefreshOptionHeader) {
        //下拉刷新已经存在
        if (self.status == YDRefreshStateRefresh) {
            return;
        }
        //正在Dragging：有两种情况，一种是小于刷新控件高度，另一种是大于刷新控件高度
        if (self.scrollView.isDragging) {
            //刷新控件完全显示出来
            if (calculateY >= YDRefreshHeight && self.status == YDRefreshStateNormal) {
                self.status = YDRefreshStateRefresh;
            }else if (calculateY < YDRefreshHeight && self.status == YDRefreshStatePulled) {
                self.status = YDRefreshStateNormal;
            }
            if (calculateY > 0 && [[change objectForKey:@"new"] CGPointValue].y < [[change objectForKey:@"old"] CGPointValue].y) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(normal2pulled:)]) {
                    [self.delegate normal2pulled:[[change objectForKey:@"new"] CGPointValue].y];
                }
            }
            if (calculateY > 0 && [[change objectForKey:@"new"] CGPointValue].y > [[change objectForKey:@"old"] CGPointValue].y) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(pulled2nomal:)]) {
                    [self.delegate pulled2nomal:[[change objectForKey:@"new"] CGPointValue].y];
                }
            }
        }
    }else if (self.status == YDRefreshStatePulled) {//释放已经炒股刷新控件高度
        self.status = YDRefreshStateRefresh;//更改状态未刷新状态
    }else if (self.status == YDRefreshStateNormal) {//正常状态
    }
    
    //存在上拉加载
    if (self.option & YDRefreshOptionFooter) {
        if (_bottomRefreshStatus) {
            return;
        }
        //上拉加载更多
        if (self.scrollView.height > self.scrollView.contentSize.height) {
            if (self.scrollView.contentOffset.y > YDBottomHeight) {
                if (!_bottomRefreshStatus) {
                    if (self.scrollView.contentSize.height) {
                        [self bottomRefresh];
                    }
                }
            }
        }else if (self.scrollView.contentOffset.y + self.scrollView.height -self.scrollView.contentSize.height > YDBottomHeight && self.scrollView.isDragging && [[change objectForKey:@"new"] CGPointValue].y > [[change objectForKey:@"old"] CGPointValue].y) {
            if (!_bottomRefreshStatus) {
                [self bottomRefresh];
            }
        }
    }
}
#pragma mark ==刷新操作==
- (void)setStatus:(YDRefreshStatus)status {
    _status = status;
    switch (status) {
        case YDRefreshStateNormal:{
            if (self.delegate && [self.delegate respondsToSelector:@selector(normalStatus)]) {
                [self.delegate performSelector:@selector(normalStatus)];
            }
            break;
        }
        case YDRefreshStatePulled:{
            if (self.delegate && [self.delegate respondsToSelector:@selector(pulledStatus)]) {
                [self.delegate performSelector:@selector(pulledStatus)];
            }
            break;
        }
        case YDRefreshStateRefresh:{
            if (self.delegate && [self.delegate respondsToSelector:@selector(refreshStatus)]) {
                [self.delegate performSelector:@selector(refreshStatus)];
            }
            break;
        }
            
        default:
            break;
    }
}
- (void)endHeaderRefresh {
    //顶部刷新Collection单独处理
    if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        //collectionView不延时 下拉后不流畅
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self restorePostion];
        });
    }else {
        [self restorePostion];
    }
}
- (void)endFooterRefresh {
    self.bottomRefreshStatus = false;
}
//恢复原来的位置
- (void)restorePostion {
    if (self.status == YDRefreshStateRefresh || self.status == YDRefreshStateNormal) {
        self.status = YDRefreshStateNormal;
        [UIView animateWithDuration:.3 animations:^{
            self.scrollView.contentInset = _scrollViewOrginInsets;
        }];
    }
}

- (void)beginHeaderRefresh {
    [self innerRefresh:YDRefreshOptionHeader];
}
- (void)beginFooterRefresh {
    [self innerRefresh:YDRefreshOptionFooter];
}
- (BOOL)isHeaderRefresh {
    if (self.status == YDRefreshStateRefresh) {
        return true;
    }
    return false;
}
- (BOOL)isFooterRefresh {
    return self.bottomRefreshStatus;
}

#pragma mark ==时间处理==
//获取最后一次更新时间
- (NSString *)getLastRefreshTime:(NSString *)key {
    NSDate *lastUpdatedTime = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (lastUpdatedTime) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
        NSDateComponents *cmp1 = [calendar components:unitFlags fromDate:lastUpdatedTime];
        NSDateComponents *cmp2 = [calendar components:unitFlags fromDate:[NSDate date]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if ([cmp1 day] == [cmp2 day] && [cmp1 month] == [cmp2 month] && [cmp1 year] == [cmp2 year]) {
            formatter.dateFormat = @"今天 HH:mm";
        }else if ([cmp1 year] == [cmp2 year]) {
            formatter.dateFormat = @"MM-dd HH:mm";
        }else {
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
        }
        NSString *time = [formatter stringFromDate:lastUpdatedTime];
        return [NSString stringWithFormat:@"最后更新: %@",time];
    }else {
        return @"最后更新：无记录";
    }
}
//设置当前更新时间
- (void)setRefreshTime:(NSDate *)date {
    [[NSUserDefaults standardUserDefaults] setObject:date forKey:YDLastRefreshTime];
}


@end



@implementation UIScrollView (DDScrollViewRefresh)
//利用分类和runtime添加ddRefresh属性的set方法
//- (void)setDdRefresh:(DDRefreshBase *)ddRefresh {
//    if (ddRefresh != self.ddRefresh) {
//        [self.ddRefresh removeFromSuperview];
//        //这里会触发willMoveToSuperView方法，所有对refresh做的操作都在这个方法里
//        [self addSubview:ddRefresh];
//        [self willChangeValueForKey:Refresh];
//        objc_setAssociatedObject(self, &DDRefreshKey, ddRefresh, OBJC_ASSOCIATION_ASSIGN);
//        [self didChangeValueForKey:Refresh];
//    }
//}
- (void)setYdHeaderRefresh:(YDRefreshBase *)ydHeaderRefresh {
    if (ydHeaderRefresh != self.ydHeaderRefresh) {
        [self.ydHeaderRefresh removeFromSuperview];
        //这里会触发willMoveToSuperView方法，所有对refresh做的操作都在这个方法里
        [self addSubview:ydHeaderRefresh];
        [self willChangeValueForKey:YDHeaderRefresh];
        objc_setAssociatedObject(self, &YDHeaderRefreshKey, ydHeaderRefresh, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:YDHeaderRefresh];
    }
}
- (void)setYdFooterRefresh:(YDRefreshBase *)ydFooterRefresh {
    if (ydFooterRefresh != self.ydFooterRefresh) {
        [self.ydFooterRefresh removeFromSuperview];
        //这里会触发willMoveToSuperView方法，所有对refresh做的操作都在这个方法里
        [self addSubview:ydFooterRefresh];
        [self willChangeValueForKey:YDFooterRefresh];
        objc_setAssociatedObject(self, &YDFooterRefreshKey, ydFooterRefresh, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:YDFooterRefresh];
    }
}
//利用分类和runtime添加ddRrfresh属性的get方法
//- (DDRefreshBase *)ddRefresh {
//    return objc_getAssociatedObject(self, &DDRefreshKey);
//}
- (YDRefreshBase *)ydHeaderRefresh {
     return objc_getAssociatedObject(self, &YDHeaderRefreshKey);
}
- (YDRefreshBase *)ydFooterRefresh {
     return objc_getAssociatedObject(self, &YDFooterRefreshKey);
}

@end
