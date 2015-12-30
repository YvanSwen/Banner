//
//  BannerView.m
//  BannerProject
//
//  Created by Yvan on 15/12/28.
//  Copyright © 2015年 Yvan. All rights reserved.
//

#import "BannerView.h"

#define kBannerWidth self.scrollView.frame.size.width
#define kBannerHeight self.scrollView.frame.size.height
#define BASETAGIMAGEVIEW 1000

@interface BannerView ()<UIScrollViewDelegate>

// 属性修饰符 顺序 -> 原子性 -> 读写属性 -> 语义修饰词
@property (nonatomic, strong) UIScrollView *scrollView;
// 属性之间不要隔行,如果为了看起来清晰,可以隔一行
// 用于存放滑动视图上的 imageView
@property (nonatomic, strong) NSMutableArray *imgViewArray;
// 用来存放轮播图的数据来源
@property (nonatomic, strong) NSMutableArray *bannerSource;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation BannerView

- (instancetype)initWithFrame:(CGRect)frame bannerSource:(NSMutableArray *)bannerSource{
    // 断言,如果条件为0,则直接 crash, 同时提示自定义信息
    // 一般只是在测试的时候才会用
    NSAssert(bannerSource, @"轮播图数据远不能为空");
    self.bannerSource = bannerSource;
    self = [self initWithFrame:frame];
    return self;
}
// 在这个方法中构建视图
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // 这是个代码块,创建控件,看起来清晰紧凑,_scrollView相当于返回值
        [self addSubview:({
            self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
            _scrollView.delegate = self;
            _scrollView;
        })];
        
        // 构建轮播图
        [self buildBanner];
        // 暂时有问题,暂时搁置
//        [self scrollNextImageView];
        [self startTimer];
    }
    return self;
}
/**
 *  NSTimer
 */
- (void)startTimer{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    // timeInterval 的数值要大于 animation 的 duration 的数值
    _timer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(scrollNextImageView) userInfo:nil repeats:YES];
}
/**
 *  在视图销毁的时候,记得销毁计时器
 */
- (void)dealloc{
    NSLog(@"轮播图释放了");
}
// 只有在停掉timer 后, self才能够被释放
// 我们在不需要计时器的时候,就需要把 time 停掉,不然 self 就不会被释放
// timer 在后台还会运行
- (void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}
/**
 *  滑动下一个 imageView
 */
- (void)scrollNextImageView{
    CGPoint currentOffset = self.scrollView.contentOffset;
    currentOffset.x += self.scrollView.frame.size.width;
    __weak typeof(self)temp = self;
    [UIView animateWithDuration:3 animations:^{
        temp.scrollView.contentOffset = currentOffset;
    }completion:^(BOOL finished) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{          
            [temp scrollViewDidEndDecelerating:self.scrollView];
//          [temp scrollNextImageView];
//        });
    }];
}
/**
 *  构建轮播图
 */
- (void)buildBanner{
    // 取出第一个元素,注意要用 id 类型接收
    id firstObject = self.bannerSource.firstObject;
    // 将最后一个插入到第一个
    [self.bannerSource insertObject:self.bannerSource.lastObject atIndex:0];
    // 将第一个添加到最后一个
    [self.bannerSource addObject:firstObject];
    NSInteger imageCount = self.bannerSource.count;
    self.scrollView.contentSize = CGSizeMake(kBannerWidth * imageCount, kBannerHeight);
    self.scrollView.pagingEnabled = YES;
    // 遍历数组,判断类型
    for (int i = 0; i < imageCount; i++) {
        id item = self.bannerSource[i];
        UIImageView *imageView = [UIImageView new];
        if ([item isKindOfClass:[UIImage class]]) {
            imageView.image = item;
        }else if ([item isKindOfClass:[NSString class]]){
            UIImage *localImage = [UIImage imageNamed:item];
            if (localImage) {
                imageView.image = localImage;
            }
            // 切换到子线程
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // 下载图片数据
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:item]];
            // 下载完成后回到主线程更新 UI
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                imageView.image = image;
            });
        });
        }else if ([item isKindOfClass:[NSURL class]]){
            NSData *data = [NSData dataWithContentsOfURL:item];
            UIImage *image = [UIImage imageWithData:data];
            imageView.image = image;
        }else{
            // 断言
            NSAssert(0, @"请提供正确的数据类型");
        }
        CGRect frame = _scrollView.frame;
        // 设置 imageview 的位置
        imageView.frame = CGRectMake(frame.size.width * i, 0, frame.size.width, frame.size.height);
        [_scrollView addSubview:imageView];
        // 给图片添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickImageView:)];
        // 设置 tag 值,方便获取添加点击事件;让第一张图片的 tag 刚好是1000;
        [imageView setTag:(BASETAGIMAGEVIEW + i - 1)];
        // imageVIew 的用户交互默认是关闭的 ;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:tap];
    }
    // 数组偏移量,让滑动视图指向第一张,而不是第零张;
    self.scrollView.contentOffset = CGPointMake(_scrollView.frame.size.width, 0);
    // 关闭横向指示
//    self.scrollView.showsHorizontalScrollIndicator = NO;
}
/**
 *  tap 点击事件
 *
 *  @param sender
 */
- (void)clickImageView:(UITapGestureRecognizer *)sender{
    NSLog(@"%ld", sender.view.tag);
    // 如果有自己的代理,而且代理也实现了相应的方法,就让代理去调用方法
    if (_delegate && [_delegate respondsToSelector:@selector(bannerView:clickIndex:)]) {
        [_delegate bannerView:self clickIndex:(sender.view.tag - BASETAGIMAGEVIEW)];
    }
}
#pragma mark -- UISCrollViewDelegate
/**
 *  滑动事件结束
 *
 *  @param scrollView
 */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    // 当前滑动视图的偏移量
    CGPoint point = scrollView.contentOffset;
    NSInteger imageCount = _bannerSource.count;
    // 判断:如果是最后一张,就滑动到第二张的位置
    if (point.x == scrollView.frame.size.width * (imageCount - 1)) {
        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width, 0);
    }else if (point.x == 0){
        scrollView.contentOffset = CGPointMake(scrollView.frame.size.width * (imageCount - 2), 0);
    }
}
/**
 *  即将拖拽前
 *
 *  @param scrollView
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self stopTimer];
}
/**
 *  拖动结束
 *
 *  @param scrollView
 *  @param decelerate
 */
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self startTimer];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
