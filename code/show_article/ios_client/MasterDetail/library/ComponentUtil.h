//
//  componentUtil.h
//  MasterDetail
//
//  Created by mac on 14-3-26.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#include <stdlib.h>

#import "UserProfile.h"
#import "myGlobal.h"

@interface ComponentUtil : NSObject
+ (void) addTextToButton:(UIButton*) btn text:(NSString*)text fontSize:(int)fontSize
               chWidth:(float)chWidth chHeight:(float)chHeight tag:(int)tag;

+ (void)updateScoreText:(NSString*) category btn:(UIButton*) btn tag:(NSInteger) tag;

+(void)infoMessage:(NSString *) title msg:(NSString *) msg
      enforceMsgBox:(BOOL)enforceMsgBox;

+(void)timedAlert:(UIAlertView *) alertView;
+(void)dismissAlert:(UIAlertView *) alertView;
+(UIImage *) resizeImage:(UIImage *)orginalImage scale:(CGFloat)scale;

+(void)setDefaultConf;
+(NSString*) getLogoIcon:(NSString* )url;
+(NSString*) getPostHeaderImg;
+(NSMutableArray*) getCategoryList;

+(void) showViewInAnimation:(UIView *)view
                    duration:(NSTimeInterval)duration
                       delay:(NSTimeInterval)delay
                       scale:(CGFloat)scale;

+ (NSString*)shortUrl:(NSString*) url;
+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView;
+ (NSString*)getUserId;
+ (BOOL)shouldMixpanel;
+ (void)showHintOnce:(id)withObject msg:(NSString*)msg;
+ (NSString *) caculateKey:(id)withObject msg:(NSString*) msg;
+ (NSString *) md5:(NSString *)str;
+ (void)configureVerticalAlign:(UITextView*) tv;
+ (CGFloat) yoffsetVerticalAlign:(UITextView*) tv;
+ (NSString*) currentTutorialVersion;
+ (BOOL) shouldShowTutorial;
+ (int) getIndexByCategory:(NSString*) category;
@end
