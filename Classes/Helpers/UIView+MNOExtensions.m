//
//  UIView+MNOExtensions.m
//  Notitas
//
//  Created by Adrian on 9/18/11.
//  Copyright 2011 akosma software. All rights reserved.
//

#import "UIView+MNOExtensions.h"
#import "MNOHelpers.h"

@implementation UIView (MNOExtensions)

- (void)mno_addShadow
{
    self.layer.shadowOffset = CGSizeMake(1.0, 1.0);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    self.layer.shadowPath = path.CGPath;
    self.layer.shadowOpacity = 1.0;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)mno_removeShadow
{
    self.layer.shadowPath = NULL;
    self.layer.shadowOffset = CGSizeZero;
    self.layer.shadowOpacity = 0.0;
}

@end
