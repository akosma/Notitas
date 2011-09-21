//
//  MNONoteThumbnail.h
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


@interface MNONoteThumbnail : UIView 

@property (nonatomic, retain) UILabel *summaryLabel;
@property (nonatomic) MNOFontCode font;
@property (nonatomic) MNOColorCode color;
@property (nonatomic, retain) Note *note;
@property (nonatomic) CGAffineTransform originalTransform;

- (void)refreshDisplay;

@end
