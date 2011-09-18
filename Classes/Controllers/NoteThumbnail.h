//
//  NoteThumbnail.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AKOLibrary/AKOLibrary.h>
#import "MNOHelpers.h"


@class Note;


@interface NoteThumbnail : UIView 

@property (nonatomic) FontCode font;
@property (nonatomic) ColorCode color;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) Note *note;
@property (nonatomic) CGAffineTransform originalTransform;
@property (nonatomic) CGRect originalFrame;

@end
