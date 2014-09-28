//
//  BackupButtonView.m
//  NewCore
//
//  Created by Yang Jason on 14-9-13.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupButtonView.h"
#import "UIColor+Skin.h"

CGPoint CGPointMakeWithAngleRadius(CGFloat angle, CGFloat radius)
{
    return CGPointMake(radius * cosf(angle), radius * sinf(angle));
}

CGPoint CGPointMakeWithScale(CGFloat scale, CGPoint point)
{
    return CGPointMake(point.x * scale, point.y * scale);
}

CGPoint CGPointMakeWithOrigin(CGPoint origin, CGPoint point)
{
    return CGPointMake(point.x + origin.x, point.y + origin.y);
}

@implementation BackupButtonView
{
    float _rotatedAngle;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.borderColor = [UIColor skinWhiteColor];
        self.buttonColor = [UIColor skinGreenColor];
        self.arrowColor = [UIColor skinLightGreenColor];
        
        [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)animateWave
{
    _rotatedAngle -= M_PI / 180 * 2;
    if (_rotatedAngle <= 0) {
        _rotatedAngle = M_PI * 2;
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
    CGFloat maxRadius = MIN(rect.size.width, rect.size.height) / 2.0;
    
    // apply margin
    CGFloat margin = (self.margin > -1 && self.margin < 1) ? maxRadius * self.margin : self.margin;
    if (margin >= maxRadius) {
        CGContextClearRect(context, rect);
        return;
    }
    else {
        maxRadius -= margin;
    }
    
    // edge
    if (self.borderColor) {
        CGContextSetFillColorWithColor(context, self.borderColor.CGColor);
        CGContextAddArc(context, center.x, center.y, maxRadius, 0, M_PI * 2, 0);
        CGContextFillPath(context);
    }
    
    // button
    if (self.buttonColor) {
        CGContextSetFillColorWithColor(context, self.buttonColor.CGColor);
        CGContextAddArc(context, center.x, center.y, maxRadius * 0.92, 0, M_PI * 2, 0);
        CGContextFillPath(context);
    }
    
    // arrows
    if (self.arrowColor) {
        CGContextSetFillColorWithColor(context, self.arrowColor.CGColor);
        [self addArrowPath:context center:center angle:(M_PI*0.9) outerRadius:(maxRadius*0.84) innerRadius:(maxRadius*0.72) tipRadius:(maxRadius*0.78) tipOffsetAngle:(M_PI*0.02) rotatedAngle:_rotatedAngle];
        CGContextFillPath(context);
        [self addArrowPath:context center:center angle:(M_PI*0.9) outerRadius:(maxRadius*0.84) innerRadius:(maxRadius*0.72) tipRadius:(maxRadius*0.78) tipOffsetAngle:(M_PI*0.02) rotatedAngle:_rotatedAngle + M_PI];
        CGContextFillPath(context);
    }
}

- (void)addArrowPath:(CGContextRef)context center:(CGPoint)center angle:(CGFloat)angle outerRadius:(CGFloat)outerRadius innerRadius:(CGFloat)innerRadius tipRadius:(CGFloat)tipRadius tipOffsetAngle:(CGFloat)tipOffsetAngle rotatedAngle:(CGFloat)rotatedAngle
{
    CGFloat outerAnchorRadius = outerRadius / cosf(angle / 4);
    
    CGPoint outerStartPoint   = CGPointMakeWithAngleRadius(angle / 2 + rotatedAngle, outerRadius);
    CGPoint outerAnchorPoint1 = CGPointMakeWithAngleRadius(angle / 4 + rotatedAngle, outerAnchorRadius);
    CGPoint outerMiddlePoint  = CGPointMakeWithAngleRadius(rotatedAngle, outerRadius);
    CGPoint outerAnchorPoint2 = CGPointMakeWithAngleRadius(M_PI * 2 - angle / 4 + rotatedAngle, outerAnchorRadius);
    CGPoint outerEndPoint     = CGPointMakeWithAngleRadius(M_PI * 2 - angle / 2 + rotatedAngle, outerRadius);
    
    CGPoint tipStartPoint     = CGPointMakeWithAngleRadius(angle / 2 - tipOffsetAngle + rotatedAngle, tipRadius);
    CGPoint tipEndPoint       = CGPointMakeWithAngleRadius(M_PI * 2 - angle / 2 - tipOffsetAngle + rotatedAngle , tipRadius);
    
    CGFloat scale = innerRadius / outerRadius;
    CGPoint innerStartPoint   = CGPointMakeWithScale(scale, outerStartPoint);
    CGPoint innerAnchorPoint1 = CGPointMakeWithScale(scale, outerAnchorPoint1);
    CGPoint innerMiddlePoint  = CGPointMakeWithScale(scale, outerMiddlePoint);
    CGPoint innerAnchorPoint2 = CGPointMakeWithScale(scale, outerAnchorPoint2);
    CGPoint innerEndPoint     = CGPointMakeWithScale(scale, outerEndPoint);
    
    // flip by x-axis
    outerStartPoint.y *= -1;
    outerAnchorPoint1.y *= -1;
    outerMiddlePoint.y *= -1;
    outerAnchorPoint2.y *= -1;
    outerEndPoint.y *= -1;
    tipStartPoint.y *= -1;
    tipEndPoint.y *= -1;
    innerStartPoint.y *= -1;
    innerAnchorPoint1.y *= -1;
    innerMiddlePoint.y *= -1;
    innerAnchorPoint2.y *= -1;
    innerEndPoint.y *= -1;
    
    // translate points
    outerStartPoint   = CGPointMakeWithOrigin(center, outerStartPoint);
    outerAnchorPoint1 = CGPointMakeWithOrigin(center, outerAnchorPoint1);
    outerMiddlePoint  = CGPointMakeWithOrigin(center, outerMiddlePoint);
    outerAnchorPoint2 = CGPointMakeWithOrigin(center, outerAnchorPoint2);
    outerEndPoint     = CGPointMakeWithOrigin(center, outerEndPoint);
    tipStartPoint     = CGPointMakeWithOrigin(center, tipStartPoint);
    tipEndPoint       = CGPointMakeWithOrigin(center, tipEndPoint);
    innerStartPoint   = CGPointMakeWithOrigin(center, innerStartPoint);
    innerAnchorPoint1 = CGPointMakeWithOrigin(center, innerAnchorPoint1);
    innerMiddlePoint  = CGPointMakeWithOrigin(center, innerMiddlePoint);
    innerAnchorPoint2 = CGPointMakeWithOrigin(center, innerAnchorPoint2);
    innerEndPoint     = CGPointMakeWithOrigin(center, innerEndPoint);
    
    CGContextMoveToPoint(context, outerStartPoint.x, outerStartPoint.y);
    CGContextAddLineToPoint(context, tipStartPoint.x, tipStartPoint.y);
    CGContextAddLineToPoint(context, innerStartPoint.x, innerStartPoint.y);
    CGContextAddArcToPoint(context, innerAnchorPoint1.x, innerAnchorPoint1.y, innerMiddlePoint.x, innerMiddlePoint.y, innerRadius);
    CGContextAddArcToPoint(context, innerAnchorPoint2.x, innerAnchorPoint2.y, innerEndPoint.x, innerEndPoint.y, innerRadius);
    CGContextAddLineToPoint(context, tipEndPoint.x, tipEndPoint.y);
    CGContextAddLineToPoint(context, outerEndPoint.x, outerEndPoint.y);
    CGContextAddArcToPoint(context, outerAnchorPoint2.x, outerAnchorPoint2.y, outerMiddlePoint.x, outerMiddlePoint.y, outerRadius);
    CGContextAddArcToPoint(context, outerAnchorPoint1.x, outerAnchorPoint1.y, outerStartPoint.x, outerStartPoint.y, outerRadius);
}

@end
