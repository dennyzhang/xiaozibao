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

+(void) setInteger:(NSString* )category key:(NSString*)key value:(NSInteger)value
{
    NSString *fullKey = [[NSString alloc] initWithFormat:@"%@--%@ ", category, key];
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:fullKey];
}

+(void) addInteger:(NSString* )category key:(NSString*)key offset:(NSInteger)offset
{
    NSInteger value = [UserProfile integerForKey:category key:key];
    NSString *fullKey = [[NSString alloc] initWithFormat:@"%@--%@ ", category, key];
    [[NSUserDefaults standardUserDefaults] setInteger:(value+offset) forKey:fullKey];
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

+(void) cleanCategoryKey:(NSString* )category
{
  [UserProfile setInteger:category key:POST_VISIT_KEY value:0];
  [UserProfile setInteger:category key:POST_VOTEUP_KEY value:0];
  [UserProfile setInteger:category key:POST_VOTEDOWN_KEY value:0];
  [UserProfile setInteger:category key:POST_FAVORITE_KEY value:0];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
