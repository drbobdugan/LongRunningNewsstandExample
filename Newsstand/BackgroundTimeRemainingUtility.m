//
//  BackgroundTimeRemainingString.m
//  NSURLSessionUploadTaskExample
//
//  Created by Bob Dugan on 10/8/15.
//  Copyright © 2015 Bob Dugan. All rights reserved.
//

@implementation BackgroundTimeRemainingUtility:NSObject

+(void) NSLog
{
    NSLog(@"State: %@, BackgroundTimeRemaining: %@", self.UIApplicationStateString, self.backgroundTimeRemainingString);
}

+ (double) backgroundTimeRemainingDouble
{
    return [[UIApplication sharedApplication] backgroundTimeRemaining];
}

+ (NSString *) backgroundTimeRemainingString
{
     NSString *result;
     if ([[UIApplication sharedApplication] backgroundTimeRemaining]==DBL_MAX)
     {
         result = @"Infinite";
     }
     else
     {
         result = [NSString stringWithFormat:@"%f(s)", [[UIApplication sharedApplication] backgroundTimeRemaining]];
     }
    
    return [NSString stringWithFormat:@"[%@]:%@",self.UIApplicationStateString,result];
}

+ (UIApplicationState)UIApplicationStateEnum
{
    return [[UIApplication sharedApplication] applicationState];
}

+ (NSString *)UIApplicationStateString
{
    NSString *result;
    
    if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateBackground)
    {
        result = (@"Background");
    }
    else if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateInactive)
    {
        result = (@"Inactive");
    }
    else if ([[UIApplication sharedApplication] applicationState]==UIApplicationStateActive)
    {
        result = (@"Active");
    }
    else
    {
       result = (@"Unknown");
    }
    
    return result;
}

@end
