//
//  BackupSwitch.m
//  NewCore
//
//  Created by Yang Jason on 14-9-13.
//  Copyright (c) 2014年 nero. All rights reserved.
//

#import "BackupSwitch.h"

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
        
        [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(animateWave) userInfo:nil repeats:YES];
        
    }
    return self;
}

#define PI 3.1415926535898
-(void)animateWave
{
    _angle += PI / 180 / 2;
    if (_angle > PI * 2) {
        _angle = 0;
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
    {
        CGFloat alpha = PI / 2.0 * 0.9;
        CGFloat pa = alpha + _angle;
        CGFloat pb = 2 * PI - alpha + _angle;
        
        CGFloat r1 = maxRadius * 0.8;
        CGPoint a1 = CGPointMake(center.x + r1 * cosf(pa), center.y - r1 * sinf(pa));
        CGPoint b1 = CGPointMake(center.x + r1 * cosf(pb), center.y + r1 * sinf(pb));
        CGFloat r2 = maxRadius * 0.6;
        CGPoint a2 = CGPointMake(center.x + r2 * cosf(pa), center.y - r2 * sinf(pa));
        CGPoint b2 = CGPointMake(center.x + r2 * cosf(pb), center.y + r2 * sinf(pb));
        
        CGContextMoveToPoint(context, a1.x, a1.y);
        CGContextAddLineToPoint(context, a2.x, a2.y);
        CGContextAddArc(context, center.x, center.y, r2, pa, pb, 1);
        CGContextAddLineToPoint(context, b2.x, b2.y);
        CGContextAddLineToPoint(context, b1.x, b1.y);
        CGContextAddArc(context, center.x, center.y, r1, pb, pa, 0);
        CGContextFillPath(context);
    }
    /*
    CGFloat angle = PI/2.0*0.9 + _angle;
    CGFloat ra = maxRadius * 0.8;
    CGPoint a1 = CGPointMake(ra * cosf(angle) + center.x, center.y - ra * sin(angle));
    CGPoint a2 = CGPointMake(a1.x, maxRadius * 2 - a1.y);
    CGFloat rb = maxRadius * 0.6;
    CGPoint b1 = CGPointMake(rb * cosf(angle) + center.x, center.y - rb * sin(angle));
    CGPoint b2 = CGPointMake(b1.x, maxRadius * 2 - b1.y);
    CGContextMoveToPoint(context, a1.x, a1.y);
    CGContextAddLineToPoint(context, b1.x, b1.y);
    CGContextAddArc(context, center.x, center.y, rb, _angle + PI * 2 - angle, _angle + PI/3, 0);
    CGContextMoveToPoint(context, b2.x, b2.y);
    CGContextAddLineToPoint(context, a2.x, a2.y);
    CGContextAddArc(context, center.x, center.y, ra, _angle + PI/3, _angle + PI*5/3, 1);
    CGContextFillPath(context);
    */
    /*
    float y=_currentLinePointY;
    CGPathMoveToPoint(path, NULL, 0, y);
    for(float x=0;x<=320;x++){
        y= a * sin( x/180*M_PI + 4*b/M_PI ) * 5 + _currentLinePointY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, 320, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, rect.size.height);
    CGPathAddLineToPoint(path, nil, 0, _currentLinePointY);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    CGContextDrawPath(context, kCGPathStroke);
    CGPathRelease(path);
     */
}

@end
