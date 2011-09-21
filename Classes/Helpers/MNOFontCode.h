//
//  MNOFontCode.h
//  Notitas
//
//  Created by Adrian on 7/23/09.
//  Copyright 2009 akosma software. All rights reserved.
//

typedef enum 
{
    MNOFontCodeHelvetica = 0,
    MNOFontCodeTimes = 1,
    MNOFontCodeCourier = 2,
    MNOFontCodeComic = 3
} MNOFontCode;

static NSString *fontNameForCode(MNOFontCode code)
{
    NSString *result = @"Helvetica";
    switch (code) 
    {
        case MNOFontCodeHelvetica:
            result = @"Helvetica";
            break;
            
        case MNOFontCodeTimes:
            result = @"TimesNewRomanPSMT";
            break;
            
        case MNOFontCodeCourier:
            result = @"Courier";
            break;
            
        case MNOFontCodeComic:
            result = @"MarkerFelt-Thin";
            break;
            
        default:
            break;
    }
    return result;
}
