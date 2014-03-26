//
//  componentUtil.h
//  MasterDetail
//
//  Created by mac on 14-3-26.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserProfile.h"
#import "constants.h"

@interface ComponentUtil : NSObject
+ (void) addTextToButton:(UIButton*) btn text:(NSString*)text
                 fontSize:(NSInteger)fontSize
               chWidth:(NSInteger)chWidth
               chHeight:(NSInteger)chHeight
                 tag:(NSInteger)tag;

+ (void)updateScoreText:(NSString*) category
                    btn:(UIButton*) btn
                    tag:(NSInteger) tag;
+(void)infoMessage:(NSString *) title 
               msg:(NSString *) msg;
+(void)timedAlert:(UIAlertView *) alertView;
+(void)dismissAlert:(UIAlertView *) alertView;
+(NSString*) getLogoIcon:(NSString* )url;

@end
