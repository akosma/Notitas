//
//  FontCodes.h
//  Notitas
//
//  Created by Adrian on 7/23/09.
//  Copyright 2009 akosma software. All rights reserved.
//

typedef enum 
{
    FontCodeHelvetica = 0,
    FontCodeTimes = 1,
    FontCodeCourier = 2,
    FontCodeComic = 3
} FontCode;

static NSString *fontNameForCode(FontCode code)
{
    NSString *result = @"Helvetica";
    switch (code) 
    {
        case FontCodeHelvetica:
            result = @"Helvetica";
            break;
            
        case FontCodeTimes:
            result = @"TimesNewRomanPSMT";
            break;
            
        case FontCodeCourier:
            result = @"Courier";
            break;
            
        case FontCodeComic:
            result = @"MarkerFelt-Thin";
            break;
            
        default:
            break;
    }
    return result;
}
