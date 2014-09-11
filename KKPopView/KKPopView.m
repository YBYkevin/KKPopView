//
//  KKPopView.m
//  KKPopView
//
//  Copyright (c) 2014年 kevin. All rights reserved.
//

#import "KKPopView.h"

#define VIEW_MIN_SCALEFACTOR 4
#define VIEW_MAX_SCALEFACTOR 10

#define VIEW_ORIGIN_X    300
#define VIEW_ORIGIN_Y    140
#define VIEW_SIZE_WIDTH  31
#define VIEW_SIZE_HEIGHT 40

#define ANIMATION_DURATION 0.2

#define VELOCITY_THRESHOLD 150

#define BUTTON_ORIGIN_X 260
#define BUTTON_ORIGIN_Y 120

#define BUTTON_CENTER_POINT CGPointMake(280, 110)

@interface KKPopView()

@property (nonatomic, strong) UIButton *dragButton;

@property (nonatomic, strong) UIView *bubbleView;

@property (nonatomic, assign) CGPoint preButtonPoint;

@property (nonatomic, assign) CGPoint touchStartPoint;

@property (nonatomic, assign) CGFloat touchStartTime;

@property (nonatomic, assign) BOOL isShowBubbleView;

@end

@implementation KKPopView


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self addSubview:self.dragButton];
        [self addSubview:self.bubbleView];
        [self.bubbleView setHidden:YES];
        
        
    }
    return self;
}

#pragma mark - Property

- (UIButton *)dragButton
{
    if (!_dragButton) {
        
        UIImage *musicImage = [UIImage imageNamed:@"ChatHeadbox.png"];
        _dragButton = [[UIButton alloc] initWithFrame:CGRectMake(BUTTON_ORIGIN_X, BUTTON_ORIGIN_Y, musicImage.size.width, musicImage.size.height)];
        [_dragButton setImage:musicImage forState:UIControlStateNormal];
        [_dragButton setImage:musicImage forState:UIControlStateSelected];
        [_dragButton setImage:musicImage forState:UIControlStateHighlighted];
        [_dragButton addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(dragButtonTrack:)];
        [_dragButton addGestureRecognizer:panGesture];
        
    }
    return _dragButton;
}

- (UIView *)bubbleView
{
    if (!_bubbleView) {
        _bubbleView = [[UIView alloc] initWithFrame:CGRectMake(VIEW_ORIGIN_X, VIEW_ORIGIN_Y, VIEW_SIZE_WIDTH, VIEW_SIZE_HEIGHT)];
        _bubbleView.layer.anchorPoint = CGPointMake(1, 0);
        _bubbleView.backgroundColor = [UIColor orangeColor];
    }
    return _bubbleView;
}


#pragma mark - Action

- (void)dragButtonTrack:(UIPanGestureRecognizer *)panGesturer{
    
    CGPoint location = [panGesturer locationInView:self];
    
    if ([panGesturer state] == UIGestureRecognizerStateChanged) {
        
        panGesturer.view.center = CGPointMake(location.x,  location.y);
    }
    else if ([panGesturer state] == UIGestureRecognizerStateEnded) {
        
        if (location.x >= CGRectGetMidX(self.bounds)) {
            
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                
               panGesturer.view.center = CGPointMake(CGRectGetMaxX(self.bounds) - 20, location.y);
            }];
            
        }else{
            
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                
               panGesturer.view.center = CGPointMake(CGRectGetMinX(self.bounds) + 20, location.y);
            }];
            
        }
    }
    
    
}


- (void)tapButton:(UIButton *)button {
    
    if (!self.isShowBubbleView) {
        
        [self showBubbleView];
        
    }else{
        
        [self hideBubbleView];
    }
    
}

#pragma mark - Touch Handle

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    self.touchStartPoint = [touch locationInView:self];
    self.touchStartTime = touch.timestamp;

}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchMovePoint = [touch locationInView:self];
    CGFloat moveDistance = touchMovePoint.y - self.touchStartPoint.y;
    CGFloat scalefactor = VIEW_MAX_SCALEFACTOR - fabs(moveDistance / CGRectGetHeight(self.bounds))*100;
    
    if (moveDistance < 0) {
        NSLog(@"向上");
        NSLog(@"scalefactor == %f",scalefactor);
        if (scalefactor <= VIEW_MAX_SCALEFACTOR && scalefactor >= VIEW_MIN_SCALEFACTOR) {
            self.bubbleView.transform = CGAffineTransformMakeScale(scalefactor, scalefactor);
        }
        else if (scalefactor < VIEW_MIN_SCALEFACTOR){
            [self hideBubbleView];
        }
        
    } else {
        NSLog(@"向下");
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchEndPoint = [touch locationInView:self];
  
    if (touchEndPoint.y < VIEW_ORIGIN_Y) {
        
         if (self.isShowBubbleView) {
             
             [self hideBubbleView];
            
        }
        
    }else{
        
        CGFloat moveDistance = touchEndPoint.y - self.touchStartPoint.y;
        CGFloat timeDelta = self.touchStartTime - touch.timestamp;
        CGFloat vel = moveDistance/timeDelta;
        NSLog(@"vel === %f",vel);
        if (vel > VELOCITY_THRESHOLD) {
            
            [self hideBubbleView];

        }else{
            
            [UIView animateWithDuration:ANIMATION_DURATION animations:^{
                
                self.bubbleView.transform = CGAffineTransformMakeScale(VIEW_MAX_SCALEFACTOR, VIEW_MAX_SCALEFACTOR);
            }];
        }
        
    }
    
}

#pragma mark - About View

- (void)hideBubbleView
{
    self.isShowBubbleView = NO;
    self.backgroundColor = [UIColor clearColor];
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.dragButton.center = self.preButtonPoint;
        self.bubbleView.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {
        
        [self.bubbleView setHidden:YES];
        
    }];
    
}

- (void)showBubbleView
{
    self.isShowBubbleView = YES;
    self.preButtonPoint = self.dragButton.center;
    
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.dragButton.center = BUTTON_CENTER_POINT;
        self.backgroundColor = [UIColor colorWithRed:0.16 green:0.17 blue:0.21 alpha:0.5];
        
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        
            [self.bubbleView setHidden:NO];
            self.bubbleView.transform = CGAffineTransformMakeScale(VIEW_MAX_SCALEFACTOR + 0.3, VIEW_MAX_SCALEFACTOR + 0.3);
            self.bubbleView.transform = CGAffineTransformMakeScale(VIEW_MAX_SCALEFACTOR, VIEW_MAX_SCALEFACTOR);
        }];
    
    }];
}

#pragma mark - HitTest

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
  
    if (view == self) {
        if (self.isShowBubbleView) {
            return view;
        }
        return nil;
    }
    else{
        return view;
    }
}
@end
