//
//  ViewController.m
//  BannerProject
//
//  Created by Yvan on 15/12/28.
//  Copyright © 2015年 Yvan. All rights reserved.
//

#import "ViewController.h"
#import "BannerView.h"
#import "AppDelegate.h"

@interface ViewController ()<BannerViewDelegate>
{
    BannerView *bView;
    NSTimer *timer;
}
@end

@implementation ViewController

- (void)dealloc{
    [bView removeFromSuperview];
    NSLog(@"释放掉了");
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *str1 = @"http://h.hiphotos.baidu.com/image/pic/item/4ec2d5628535e5dd2820232370c6a7efce1b623a.jpg";
    NSString *str2 = @"http://f.hiphotos.baidu.com/image/pic/item/3bf33a87e950352a230666de5743fbf2b3118b85.jpg";
    NSString *str3 = @"http://www.zyue.com/UpLoad/UploadNews/2009-03-11_134706.jpg";
    
    bView = [[BannerView alloc] initWithFrame:CGRectMake(0, 22, self.view.frame.size.width, 280) bannerSource:[@[str1, str2, str3] mutableCopy]];
    // 第二种
//    NSMutableArray *array = [NSMutableArray arrayWithObjects:str1, str2, nil];
//    BannerView *bView = [[BannerView alloc] initWithFrame:CGRectMake(0, 22, self.view.frame.size.width, 280) bannerSource:array];
    bView.delegate = self;
    [self.view addSubview:bView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.view addGestureRecognizer:tap];
}
- (void)tap{
    //停掉轮播图的计时器
    [bView stopTimer];
    // 销毁当前的控制器
    AppDelegate *myDelegate = [UIApplication sharedApplication].delegate;
    myDelegate.window.rootViewController = [UIViewController new];
}

#pragma mark -- BannerViewDelegate
// 实现代理方法
- (void)bannerView:(BannerView *)banner clickIndex:(NSInteger)index{
    NSLog(@"点击的时第%ld张图片", index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
