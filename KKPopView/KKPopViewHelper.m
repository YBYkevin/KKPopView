//
//  KKPopViewHelper.m
//  KKPopView
//
//  Copyright (c) 2014年 kevin. All rights reserved.
//

#import "KKPopViewHelper.h"
#import "KKPopView.h"

@interface KKPopViewHelper ()

@property (nonatomic, strong) KKPopView *popView;

@end


@implementation KKPopViewHelper

+ (void)PopUpView
{
    KKPopViewHelper *popViewHelper = [[KKPopViewHelper alloc] init];
    [popViewHelper rootViewAddPopView];
}


- (KKPopView *)popView
{
    if (!_popView) {
        _popView = [[KKPopView alloc] init];
        [_popView setFrame:[UIScreen mainScreen].bounds];
        _popView.backgroundColor = [UIColor clearColor];
        
    }
    return _popView;
}

- (void)rootViewAddPopView
{
    [[self getWindowRootView] addSubview:self.popView];
}

- (UIView *)getWindowRootView
{
    UIViewController *rootViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    UIView* rootView = rootViewController.view;
    return rootView;
    
}



@end
