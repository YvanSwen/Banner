//
//  BannerView.h
//  BannerProject
//
//  Created by Yvan on 15/12/28.
//  Copyright © 2015年 Yvan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BannerView;

@protocol BannerViewDelegate <NSObject>

// 协议,代理者应该实现协议中的方法
- (void)bannerView:(BannerView *)banner clickIndex:(NSInteger)index;

@end

@interface BannerView : UIView

- (instancetype)initWithFrame:(CGRect)frame bannerSource:(NSMutableArray *)bannerSource;
// 指定一个代理,这个代理遵循 BannerViewDelegate 协议
@property (nonatomic, weak) id<BannerViewDelegate> delegate;

- (void)stopTimer;

@end
