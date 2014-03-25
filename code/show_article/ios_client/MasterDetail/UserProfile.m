//
//  UserProfile.m
//  MasterDetail
//
//  Created by mac on 14-3-24.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "UserProfile.h"

@implementation UserProfile

+(NSInteger) integerForKey:(NSString* )category key:(NSString*)key
{
    NSString *fullKey = [[NSString alloc] initWithFormat:@"%@--%@ ", category, key];
    return [[NSUserDefaults standardUserDefaults] integerForKey:fullKey];
}

+(void) incInteger:(NSString* )category key:(NSString*)key
{
    NSInteger value = [UserProfile integerForKey:category key:key];
    NSString *fullKey = [[NSString alloc] initWithFormat:@"%@--%@ ", category, key];
    [[NSUserDefaults standardUserDefaults] setInteger:(value+1) forKey:fullKey];
}

+(NSInteger) scoreByCategory:(NSString* )category
{
    NSInteger ret = 0;
    ret = [UserProfile integerForKey:category key:POST_VISIT_KEY]*2 +
          [UserProfile integerForKey:category key:POST_VOTEUP_KEY] +
          [UserProfile integerForKey:category key:POST_VOTEDOWN_KEY] +
          [UserProfile integerForKey:category key:POST_FAVORITE_KEY];

    return ret;
}

@end
