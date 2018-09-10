//
//  XYFHeader.h
//  TestDemo
//
//  Created by Chivalrous on 2018/9/10.
//  Copyright © 2018年 Chivalrous. All rights reserved.
//

#import "MJRefreshNormalHeader.h"

@interface RadialProgressLayer : CALayer

@property (nonatomic,assign) CGFloat outlineWidth;
@property (nonatomic, strong) UIColor *cyColor;
- (id)initWithBorderWidth:(CGFloat)width;

@end

@interface XYFHeader : MJRefreshStateHeader

@property (nonatomic, strong) RadialProgressLayer *backgroundLayer;
/** 菊花的样式 */
@property (assign, nonatomic) UIActivityIndicatorViewStyle activityIndicatorViewStyle;

@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic,assign) CGFloat borderWidth;
@property (nonatomic,assign) CGFloat progressThreshold;
@property (nonatomic, strong) UIColor *bgColor;

@end
