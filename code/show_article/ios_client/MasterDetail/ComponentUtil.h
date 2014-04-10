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
#include <stdlib.h>

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
               msg:(NSString *) msg
      enforceMsgBox:(BOOL)enforceMsgBox;

+(void)timedAlert:(UIAlertView *) alertView;
+(void)dismissAlert:(UIAlertView *) alertView;
+(UIImage *) resizeImage:(UIImage *)orginalImage scale:(CGFloat)scale;
+(void) setDefaultConf;
+(NSString*) getLogoIcon:(NSString* )url;
+(NSString*) getPostHeaderImg;
+(NSMutableArray*) getCategoryList;

+(void) showViewInAnimation:(UIView *)view
                    duration:(NSTimeInterval)duration
                       delay:(NSTimeInterval)delay
                       scale:(CGFloat)scale;
@end
