//
//  NoteThumbnail.h
//  Notitas
//
//  Created by Adrian on 7/21/09.
//  Copyright 2009 akosma software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MNOHelpers.h"

@interface NoteThumbnail : UIView 
{
@private
    UILabel *_summaryLabel;
    UIImageView *_backgroundView;
    ColorCode _color;
    FontCode _font;
}

@property (nonatomic) FontCode font;
@property (nonatomic) ColorCode color;
@property (nonatomic, copy) NSString *text;

@end
