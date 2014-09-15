//
//  BackupSwitch.m
//  NewCore
//
//  Created by Yang Jason on 14-9-13.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupSwitch.h"

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

@implementation BackupSwitch
{
    float _angle;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setBackgroundColor:[UIColor lightGrayColor]];
        
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
        
    }
    return self;
}

#define PI 3.1415926535898
-(void)animateWave
{
    _angle -= PI / 180 * 1;
    if (_angle <= 0) {
        _angle = PI * 2;
    }
    
    [self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat maxRadius = MIN(rect.size.width, rect.size.height) / 2.0, radius = 0;
    CGPoint center = CGPointMake(rect.origin.x + rect.size.width / 2.0, rect.origin.y + rect.size.height / 2.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1);
    
    // edge (white)
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    radius = maxRadius;
    CGContextAddArc(context, center.x, center.y, radius, 0, PI * 2, 0);
    CGContextFillPath(context);
    
    // background (dark green)
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    radius = maxRadius * 0.9;
    CGContextAddArc(context, center.x, center.y, radius, 0, PI * 2, 0);
    CGContextFillPath(context);
    
    // arrows (light green)
    CGContextSetFillColorWithColor(context, [UIColor greenColor].CGColor);
    [self addArrowPath:context center:center angle:(PI*0.9) outerRadius:(maxRadius*0.8) innerRadius:(maxRadius*0.6) tipRadius:(maxRadius*0.7) tipOffsetAngle:(PI*0.05) rotatedAngle:_angle];
    CGContextFillPath(context);
    [self addArrowPath:context center:center angle:(PI*0.9) outerRadius:(maxRadius*0.8) innerRadius:(maxRadius*0.6) tipRadius:(maxRadius*0.7) tipOffsetAngle:(PI*0.05) rotatedAngle:_angle + PI];
    CGContextFillPath(context);
}

- (void)addArrowPath:(CGContextRef)context center:(CGPoint)center angle:(CGFloat)angle outerRadius:(CGFloat)outerRadius innerRadius:(CGFloat)innerRadius tipRadius:(CGFloat)tipRadius tipOffsetAngle:(CGFloat)tipOffsetAngle rotatedAngle:(CGFloat)rotatedAngle
{
    CGFloat outerAnchorRadius = outerRadius / cosf(angle / 4);
    
    CGPoint outerStartPoint   = CGPointMakeWithAngleRadius(angle / 2 + rotatedAngle, outerRadius);
    CGPoint outerAnchorPoint1 = CGPointMakeWithAngleRadius(angle / 4 + rotatedAngle, outerAnchorRadius);
    CGPoint outerMiddlePoint  = CGPointMakeWithAngleRadius(rotatedAngle, outerRadius);
    CGPoint outerAnchorPoint2 = CGPointMakeWithAngleRadius(PI * 2 - angle / 4 + rotatedAngle, outerAnchorRadius);
    CGPoint outerEndPoint     = CGPointMakeWithAngleRadius(PI * 2 - angle / 2 + rotatedAngle, outerRadius);
    
    CGPoint tipStartPoint     = CGPointMakeWithAngleRadius(angle / 2 - tipOffsetAngle + rotatedAngle, tipRadius);
    CGPoint tipEndPoint       = CGPointMakeWithAngleRadius(PI * 2 - angle / 2 - tipOffsetAngle + rotatedAngle , tipRadius);
    
    CGFloat scale = innerRadius / outerRadius;
    CGPoint innerStartPoint   = CGPointMakeWithScale(scale, outerStartPoint);
    CGPoint innerAnchorPoint1 = CGPointMakeWithScale(scale, outerAnchorPoint1);
    CGPoint innerMiddlePoint  = CGPointMakeWithScale(scale, outerMiddlePoint);
    CGPoint innerAnchorPoint2 = CGPointMakeWithScale(scale, outerAnchorPoint2);
    CGPoint innerEndPoint     = CGPointMakeWithScale(scale, outerEndPoint);
    
    //
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
    //  CGContextAddLineToPoint(context, innerAnchorPoint1.x, innerAnchorPoint1.y);
    //  CGContextAddLineToPoint(context, innerMiddlePoint.x, innerMiddlePoint.y);
    CGContextAddArcToPoint(context, innerAnchorPoint1.x, innerAnchorPoint1.y, innerMiddlePoint.x, innerMiddlePoint.y, innerRadius);
    //  CGContextAddLineToPoint(context, innerAnchorPoint2.x, innerAnchorPoint2.y);
    //  CGContextAddLineToPoint(context, innerEndPoint.x, innerEndPoint.y);
    CGContextAddArcToPoint(context, innerAnchorPoint2.x, innerAnchorPoint2.y, innerEndPoint.x, innerEndPoint.y, innerRadius);
    CGContextAddLineToPoint(context, tipEndPoint.x, tipEndPoint.y);
    CGContextAddLineToPoint(context, outerEndPoint.x, outerEndPoint.y);
    //  CGContextAddLineToPoint(context, outerAnchorPoint2.x, outerAnchorPoint2.y);
    //  CGContextAddLineToPoint(context, outerMiddlePoint.x, outerMiddlePoint.y);
    CGContextAddArcToPoint(context, outerAnchorPoint2.x, outerAnchorPoint2.y, outerMiddlePoint.x, outerMiddlePoint.y, outerRadius);
    //  CGContextAddLineToPoint(context, outerAnchorPoint1.x, outerAnchorPoint1.y);
    //  CGContextAddLineToPoint(context, outerStartPoint.x, outerStartPoint.y);
    CGContextAddArcToPoint(context, outerAnchorPoint1.x, outerAnchorPoint1.y, outerStartPoint.x, outerStartPoint.y, outerRadius);
}

@end
