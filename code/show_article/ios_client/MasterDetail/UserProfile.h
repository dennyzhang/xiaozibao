//
//  UserProfile.h
//  MasterDetail
//
//  Created by mac on 14-3-24.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfile:NSObject

#define POST_VISIT_KEY @"post_visit_count"
#define POST_VOTEUP_KEY @"post_voteup_count"
#define POST_VOTEDOWN_KEY @"post_VOTEDOW_count"
#define POST_FAVORITE_KEY @"post_FAVORITE_count"

+(NSInteger) integerForKey:(NSString* )category key:(NSString*)key;
+(void) incInteger:(NSString* )category key:(NSString*)key;
+(void) setInteger:(NSString* )category key:(NSString*)key value:(NSInteger)value;
+(NSInteger) scoreByCategory:(NSString* )category;
+(void) cleanCategoryKey:(NSString* )category;
@end
