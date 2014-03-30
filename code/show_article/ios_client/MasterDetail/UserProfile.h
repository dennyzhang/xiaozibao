//
//  UserProfile.h
//  MasterDetail
//
//  Created by mac on 14-3-24.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfile:NSObject

#define POST_VISIT_KEY @"POST_VISIT_COUNT"
#define POST_VOTEUP_KEY @"POST_VOTEUP_COUNT"
#define POST_VOTEDOWN_KEY @"POST_VOTEDOW_COUNT"
#define POST_FAVORITE_KEY @"POST_FAVORITE_COUNT"
#define POST_STAY_SECONDS_KEY @"STAY_SECONDS"

+(NSInteger) integerForKey:(NSString* )category key:(NSString*)key;
+(void) addInteger:(NSString* )category key:(NSString*)key offset:(NSInteger)offset;
+(void) setInteger:(NSString* )category key:(NSString*)key value:(NSInteger)value;
+(NSInteger) scoreByCategory:(NSString* )category;
+(void) cleanCategoryKey:(NSString* )category;
@end
