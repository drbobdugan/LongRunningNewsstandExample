//
//  FileLog.m
//  Newsstand
//
//  Created by Bob Dugan on 12/1/15.
//  Copyright © 2015 i3factory. All rights reserved.
//
#import "FileLog.h"

@implementation FileLog

+(void) write: (NSString *) string
{
    NSString *filePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:@"console.log"];
    NSFileHandle *fileHandler = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    [fileHandler seekToEndOfFile];
    [fileHandler writeData:[string dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler writeData:[@"\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [fileHandler closeFile];
}

@end