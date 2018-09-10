//
//  XYFHeader.m
//  TestDemo
//
//  Created by Chivalrous on 2018/9/10.
//  Copyright © 2018年 Chivalrous. All rights reserved.
//

#import "XYFHeader.h"

@implementation RadialProgressLayer
- (id)init {
    self = [super init];
    if(self) {
        self.outlineWidth=2.0f;
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}

- (id)initWithBorderWidth:(CGFloat)width {
    self = [super init];
    if(self) {
        self.outlineWidth=width;
        self.contentsScale = [UIScreen mainScreen].scale;
        [self setNeedsDisplay];
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx {
    //Draw circle outline
    CGContextSetStrokeColorWithColor(ctx, self.cyColor ? self.cyColor.CGColor : [UIColor colorWithWhite:0.8 alpha:0.6].CGColor);
    CGContextSetLineWidth(ctx, self.outlineWidth);
    CGContextStrokeEllipseInRect(ctx, CGRectInset(self.bounds, self.outlineWidth , self.outlineWidth ));
}

- (void)setOutlineWidth:(CGFloat)outlineWidth {
    _outlineWidth = outlineWidth;
    [self setNeedsDisplay];
}
@end

@interface XYFHeader ()

@property (weak, nonatomic) UIActivityIndicatorView *loadingView;
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIView *layerView;
@property (nonatomic, assign) double progress;

@end

@implementation XYFHeader

- (UIActivityIndicatorView *)loadingView
{
    if (!_loadingView) {
        UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.activityIndicatorViewStyle];
        loadingView.hidesWhenStopped = YES;
        [self addSubview:_loadingView = loadingView];
    }
    return _loadingView;
}

- (UIView *)layerView {
    if (!_layerView) {
        _layerView = [[UIView alloc] init];
        _layerView.backgroundColor = [UIColor clearColor];
        [self addSubview:_layerView];
    }
    return _layerView;
}

#pragma mark - 公共方法
- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)activityIndicatorViewStyle
{
    _activityIndicatorViewStyle = activityIndicatorViewStyle;
    
    self.loadingView = nil;
    [self setNeedsLayout];
}

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
    self.backgroundColor = bgColor;
}

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    self.lastUpdatedTimeLabel.hidden = true;
    self.stateLabel.hidden = true;
    self.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    
    self.borderColor = [UIColor colorWithRed:203/255.0 green:32/255.0 blue:39/255.0 alpha:1];
    self.borderWidth = 2.0f;
    self.contentMode = UIViewContentModeRedraw;
    self.backgroundColor = [UIColor clearColor];
    self.progressThreshold = 66;
    
    //init background layer
    RadialProgressLayer *backgroundLayer = [[RadialProgressLayer alloc] initWithBorderWidth:self.borderWidth];
    self.backgroundLayer.frame = CGRectMake(0, 0, 30, 30);
    [self.layerView.layer addSublayer:backgroundLayer];
    self.backgroundLayer = backgroundLayer;
    
    //init arc draw layer
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.frame = CGRectMake(0, 0, 30, 30);
    shapeLayer.fillColor = nil;
    shapeLayer.strokeColor = self.borderColor.CGColor ? self.borderColor.CGColor : [UIColor whiteColor].CGColor;
    shapeLayer.strokeEnd = 0;
    shapeLayer.shadowColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
    shapeLayer.shadowOpacity = 0.7;
    shapeLayer.shadowRadius = 20;
    shapeLayer.contentsScale = [UIScreen mainScreen].scale;
    shapeLayer.lineWidth = self.borderWidth;
    shapeLayer.lineCap = kCALineCapRound;
    
    [self.layerView.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    // 箭头的中心点
    CGFloat xyfCenterX = self.mj_w * 0.5;
    CGFloat xyfCenterY = self.mj_h * 0.5;
    self.layerView.frame = CGRectMake(xyfCenterX, xyfCenterY, 30, 30);
    CGPoint loadingCenter = CGPointMake(xyfCenterX, xyfCenterY);
    // 圈圈
    if (self.loadingView.constraints.count == 0) {
        self.loadingView.center = loadingCenter;
    }
    [self updatePath];
}

- (void)updatePath {
    CGPoint center = CGPointMake(0, 0);
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithArcCenter:center radius:(30/2 - self.borderWidth) startAngle:-M_PI_2 endAngle:M_PI + M_PI_2 clockwise:true];
    self.shapeLayer.path = bezierPath.CGPath;
}

- (void)setProgress:(double)progress
{
    static double prevProgress;
    
    if(progress > 1.0)
    {
        progress = 1.0;
    }
    
    self.alpha = 1.0 * progress;
    
    if (progress >= 0 && progress <=1.0) {
        //strokeAnimation
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        animation.fromValue = [NSNumber numberWithFloat:((CAShapeLayer *)self.shapeLayer.presentationLayer).strokeEnd];
        animation.toValue = [NSNumber numberWithFloat:progress];
        animation.duration = 0.35 + 0.25*(fabs([animation.fromValue doubleValue] - [animation.toValue doubleValue]));
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [self.shapeLayer addAnimation:animation forKey:@"animation"];
        
    }
    _progress = progress;
    prevProgress = progress;
    
}

- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change {
    [super scrollViewContentOffsetDidChange:change];
    static double prevProgress;
    CGFloat yOffset = self.scrollView.contentOffset.y;
    NSLog(@"yOffset===%f",yOffset);
    self.progress = ((yOffset + 5)/-self.progressThreshold);
    prevProgress = self.progress;
}


- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    // 根据状态做事情
    if (state == MJRefreshStateIdle) {
        if (oldState == MJRefreshStateRefreshing) {
            [UIView animateWithDuration:MJRefreshSlowAnimationDuration animations:^{
                self.loadingView.alpha = 0.0;
            } completion:^(BOOL finished) {
                // 如果执行完动画发现不是idle状态，就直接返回，进入其他状态
                if (self.state != MJRefreshStateIdle) return;
                self.loadingView.alpha = 1.0;
                [self.loadingView stopAnimating];
            }];
        } else {
            self.backgroundLayer.hidden = false;
            self.shapeLayer.hidden = false;
            [self.loadingView stopAnimating];
        }
    } else if (state == MJRefreshStatePulling) {
        self.shapeLayer.hidden = true;
        self.backgroundLayer.hidden = true;
        [self.loadingView stopAnimating];
    } else if (state == MJRefreshStateRefreshing) {
        self.loadingView.alpha = 1.0; // 防止refreshing -> idle的动画完毕动作没有被执行
        [self.loadingView startAnimating];
        self.shapeLayer.hidden = true;
        self.backgroundLayer.hidden = true;
    }
}

@end
