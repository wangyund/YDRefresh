//
//  DDRefresh.m
//  DDRefresh
//
//  Created by yutongmac on 2017/3/11.
//  Copyright © 2017年 yutongmac. All rights reserved.
//

#import "YDRefresh.h"

@interface YDRefresh()<YDRefreshBaseDelegate>{
    NSDate *_lastRefreshDate;//保存刷新时间
}
//顶部箭头
@property (nonatomic, strong) UIImageView *imageView;
//顶部提示
@property (nonatomic, strong) UILabel *remind;
//顶部刷新时间
@property (nonatomic, strong) UILabel *time;
//顶部菊花
@property (nonatomic, strong) UIActivityIndicatorView *topFlower;
//底部菊花
@property (nonatomic, strong) UIActivityIndicatorView *bottomFlower;
//底部按钮
@property (nonatomic, strong) UIButton *bottomButton;

@end

@implementation YDRefresh

- (instancetype)init {
    self = [super init];
    if (self) {
        //底部上拉后默认显示数据
        self.loadingFootTitle = YDRefreshingBottomTitle;
        self.delegate = self;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    [self chargeFrameAndState];
    
}
- (void)endHeaderRefresh {
    [super endHeaderRefresh];
    [self setHeaderRefresh:false];
    [self updateRefreshTime];
}
- (void)endFooterRefresh {
    self.bottomFlower.hidden = true;
    [self.bottomFlower stopAnimating];
    //如果加载到最后没有数据了且设置了finishedFootTitle
    if (self.finishedFootTitle) {
        [self.bottomButton setTitle: self.finishedFootTitle forState:UIControlStateNormal];
        self.bottomButton.enabled = false;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(YDFinshRemainTime * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            self.finishedFootTitle = nil;
            self.bottomButton.enabled = true;
            [super endFooterRefresh];
            [self.bottomButton setTitle: YDStaticBottomTitle forState:UIControlStateNormal];
        });
    } else {
        //非刷新状态且没有设置finishedFootTitle
        [self.bottomButton setTitle: YDStaticBottomTitle forState:UIControlStateNormal];
        [super endFooterRefresh];
    }
    [self updateRefreshTime];
}
- (void)beginHeaderRefresh {
    [super beginHeaderRefresh];
    [self setHeaderRefresh:true];
}
- (void)beginFooterRefresh {
    [super beginFooterRefresh];
    [self setFooterRefresh:true];
}
//监听ContentSize改变事件
- (void)scrollViewContentSizeChange:(NSDictionary *)change {
    [self chargeFrameAndState];
}
- (void)chargeFrameAndState {
    if (self.option & YDRefreshOptionHeader) {
        self.remind.centerX = self.scrollView.centerX - self.scrollView.x;
        self.time.centerX = self.remind.centerX;
        self.imageView.x = self.time.x - 40;
        self.topFlower.centerX = self.imageView.centerX;
    }
    if (self.option & YDRefreshOptionFooter) {
        self.bottomButton.centerX = self.scrollView.centerX - self.scrollView.x;
        self.bottomFlower.x = self.scrollView.centerX - 100 - self.scrollView.x;
        self.bottomFlower.y = self.scrollView.contentSize.height + 2;
        self.bottomButton.centerY = self.bottomFlower.centerY;
        self.bottomButton.hidden = self.scrollView.contentSize.height == 0 ? true: false;
    }
}
- (void)setHeaderRefresh:(BOOL)refresh {
    self.imageView.hidden = !refresh;
    self.remind.text = refresh? YDRefreshingTopTitle : YDStaticTopTitle;
    refresh ? [self.topFlower startAnimating] : [self.topFlower stopAnimating];
}
- (void)setFooterRefresh:(BOOL)refresh {
    self.bottomFlower.hidden = !refresh;
    refresh ? [self.bottomFlower startAnimating]:[self.bottomFlower stopAnimating];
    //刷新状态
    if (refresh) {
        [self.bottomButton setTitle: self.loadingFootTitle forState:UIControlStateNormal];
    }
}
//更新刷新时间
- (void)updateRefreshTime {
    NSDate *date = [NSDate date];
    _lastRefreshDate = date;
    [self setRefreshTime:date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    self.time.text = [NSString stringWithFormat:@"最后更新: 今天 %@",[formatter stringFromDate:date]];
}
#pragma mark- DDRefreshBaseDelegate
- (void)normalStatus {
    [UIView animateWithDuration:YDDisappearTime animations:^{
        self.imageView.transform = CGAffineTransformIdentity;
        self.remind.text = YDStaticTopTitle;
    }];
}

- (void)pulledStatus {
    [UIView animateWithDuration:YDDisappearTime animations:^{
        self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, 0.000001 - M_PI);
        self.remind.text = YDScrollTopTitle;
    }];
}

- (void)refreshStatus {
    [self beginHeaderRefresh];
}

- (void)normal2pulled {
    NSLog(@"normal");
}

- (void)pulled2nomal {
    NSLog(@"normal222");
}

#pragma mark- 创建控件
/** 为下拉刷新控件添加子控件 */
- (void)setupHeaderWithSuperView:(UIView *)newSuperView {
    [super setupHeaderWithSuperView:newSuperView];
    //提示
    self.remind = [self createLabelWithCenter:CGPointMake(self.scrollView.centerX - self.scrollView.x, -50) Width:120 Height:24 Title: YDStaticTopTitle];
    //时间
    self.time = [self createLabelWithCenter:CGPointMake(self.scrollView.centerX - self.scrollView.x, CGRectGetMaxY(self.remind.frame)) Width:160 Height:24 Title:@"最后更新: 暂无更新"];
    self.time.text = [self getLastRefreshTime:YDLastRefreshTime];
    //箭头
    [self createImageViewWithFrame:CGRectMake(self.time.x - 50, - YDRefreshHeight + (YDRefreshHeight - 40)/2, 15, 40)];
    //菊花
    self.topFlower = [self createActivityIndicatorViewWithWidthAndHeight:50/375 * self.scrollView.width Center:self.imageView.center];
}

//为上拉加载更多控件添加子控件
- (void)setupFooterWithSuperView:(UIView *)newSuperView {
    [super setupFooterWithSuperView:newSuperView];
    //上拉菊花
    self.bottomFlower = [self createActivityIndicatorViewWithWidthAndHeight:YDBottomHeight Center:CGPointMake(self.scrollView.centerX - 100 / 375.0 * self.scrollView.width, self.bottomButton.centerY)];//菊花
    ///下面本来可以不用写，无奈UIScrollView在设置refresh之前没有监听contenSize的方法,继承它的方法倒是监听了
    self.bottomFlower.y = self.scrollView.contentSize.height  + 2;
    //上拉点击按钮
    self.bottomButton = [self createButton];
}
//创建按钮
- (UIButton *)createButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:YDStaticBottomTitle forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button addTarget:self action:@selector(bottomRefresh) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    button.width = 160;
    button.height = 40;
    button.centerX = self.scrollView.centerX - self.scrollView.x;
    //下面本来可以不用写，无奈在设置refresh之前没有监听contenSize的方法
    button.centerY = self.bottomFlower.centerY;
    //无内容时不让上拉显示，tableView正常，但collectionView必须要这里隐藏
    if ([self.scrollView isKindOfClass:[UICollectionView class]]) {
        button.hidden = true;
    }
    [self.scrollView addSubview:button];
    return button;
}
//创建菊花
- (UIActivityIndicatorView *)createActivityIndicatorViewWithWidthAndHeight:(CGFloat)wh Center:(CGPoint)center {
    
    UIActivityIndicatorView *flower = [[UIActivityIndicatorView alloc] init];
    flower.width = wh;
    flower.height = wh;
    flower.hidden = true;
    flower.center = center;
    [flower setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self addSubview:flower];
    return flower;
}

//创建标签
- (UILabel *)createLabelWithCenter:(CGPoint)center Width:(CGFloat)width Height:(CGFloat)height Title:(NSString *)title{
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.center = center;
    textLabel.size = CGSizeMake(width, height);
    textLabel.text = title;
    textLabel.textColor = YDRefreshColor(90, 90, 90);
    textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
    [self addSubview:textLabel];
    return textLabel;
}

//创建箭头
- (void)createImageViewWithFrame:(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:YDRefreshResourceName(@"arrow")]];
    imageView.frame = frame;
    [self addSubview:imageView];
    self.imageView = imageView;
}


@end
