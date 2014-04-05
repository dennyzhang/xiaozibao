//
//  componentUtil.h
//  MasterDetail
//
//  Created by mac on 14-3-26.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "UserProfile.h"
#import "global.h"

@interface ComponentUtil : NSObject
+ (void) addTextToButton:(UIButton*) btn text:(NSString*)text
                 fontSize:(int)fontSize
               chWidth:(float)chWidth
               chHeight:(float)chHeight
                 tag:(int)tag;
+ (void)updateScoreText:(NSString*) category
                    btn:(UIButton*) btn
                    tag:(NSInteger) tag;
+(void)infoMessage:(NSString *) title 
               msg:(NSString *) msg;
+(void)timedAlert:(UIAlertView *) alertView;
+(void)dismissAlert:(UIAlertView *) alertView;
+(NSString*) getLogoIcon:(NSString* )url;
+(UIImage *) resizeImage:(UIImage *)orginalImage resizeSize:(CGSize)size;
+(void) setDefaultConf;
@end
