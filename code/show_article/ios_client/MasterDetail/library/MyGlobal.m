//
//  MyGlobal.m
//  MasterDetail
//
//  Created by mac on 14-4-21.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "MyGlobal.h"

@implementation MyGlobal
+(MyGlobal *)singleton {
    static MyGlobal *shared = nil;
    
    if(shared == nil) {
        shared = [[MyGlobal alloc] init];
        [shared init_data];
    }
    return shared;
}

-(void)init_data
{
  self.dbPath = [self getDBPath];
}

- (NSString *)getDBPath
{
    NSArray* dirPaths;
    NSString* docsDir;
    NSString* dbPath;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    dbPath = [[NSString alloc]
                    initWithString: [docsDir stringByAppendingPathComponent: @"posts.db"]];  
    return dbPath;
}

@end
