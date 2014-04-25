//
//  componentUtil.m
//  MasterDetail
//
//  Created by mac on 14-3-26.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "ComponentUtil.h"

@implementation ComponentUtil
+ (void) addTextToButton:(UIButton*) btn text:(NSString*)text
                fontSize:(int)fontSize
                 chWidth:(float)chWidth
                chHeight:(float)chHeight
                     tag:(int)tag
{
    // TODO better way, instead of workaround for the layout
    if ([text length] == 1)
        text = [NSString stringWithFormat: @"%@ ", text];
    if ([text length] == 2)
        text = [NSString stringWithFormat: @" %@", text];
    if ([text length] == 3)
        text = [NSString stringWithFormat: @"%@", text];
    
    float width = btn.frame.size.width;
    float height = btn.frame.size.height;
    float textWidth = chWidth * [text length];
    float textHeight = chHeight;
    
    UITextView* textTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    [btn addSubview:textTextView];
    textTextView.backgroundColor = [UIColor clearColor];
    textTextView.font = [UIFont fontWithName:FONT_NAME1 size:fontSize];
    textTextView.text = text;
    textTextView.tag = tag;
    textTextView.textAlignment = NSTextAlignmentCenter;
    [textTextView setUserInteractionEnabled:NO];
    [textTextView setFrame:CGRectMake(width - textWidth,
                                      height - textHeight,
                                      textWidth, textHeight)];
}

+ (void)updateScoreText:(NSString*) category
                    btn:(UIButton*) btn
                    tag:(NSInteger) tag
{
    NSInteger score = [UserProfile scoreByCategory:category];
    NSString* scoreStr;
    // TODO better way, instead of workaround for the layout
    if (score < 10)
        scoreStr = [NSString stringWithFormat: @"%d  ", (int)score];
    else
        scoreStr = [NSString stringWithFormat: @"%d ", (int)score];
    UITextView *textView = (UITextView *)[btn viewWithTag:tag];
    textView.text = scoreStr;
}

+(void)infoMessage:(NSString *) title
               msg:(NSString *) msg
     enforceMsgBox:(BOOL)enforceMsgBox
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (enforceMsgBox || ([userDefaults integerForKey:@"IsDebugMode"] == 1)) {
        NSLog(@"title:%@, msg:%@", title, msg);
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:title message:msg delegate:self
                              cancelButtonTitle:nil
                              otherButtonTitles:nil, nil];
        [alert show];
        [ComponentUtil timedAlert:alert];
    }
    else {
        NSLog(@"title:%@, msg:%@", title, msg);
    }
}

+(void)timedAlert:(UIAlertView *) alertView
{
    [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:HIDE_MESSAGEBOX_DELAY];
}

+(void)dismissAlert:(UIAlertView *) alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
}

+(NSString*) getPostHeaderImg
{
    // TODO remove hard code
    NSString* ret = [NSString stringWithFormat:@"header_%d.png", arc4random() % 4 + 1];
    //NSLog(@"getPostHeaderImg:%@", ret);
    return ret;
    //return [NSString stringWithFormat:@"header_%d.png", 13];
}

+(NSString*) getLogoIcon:(NSString* )url
{
    if ([url rangeOfString:@"stackexchange.com"].location != NSNotFound) {
        return @"stackexchange.com.png";
    }
    
    NSString* ret;
    NSArray *stringArray = [url componentsSeparatedByString: @"/"];
    ret = [[NSString alloc] initWithFormat:@"%@.png", stringArray[2]];
    
    return ret;
}

+(UIImage *) resizeImage:(UIImage *)orginalImage scale:(CGFloat)scale
{
    // TODO doesn't seem to work
    NSData * data = UIImagePNGRepresentation(orginalImage);
    UIImage* newImage = [[UIImage alloc] initWithData:data scale:scale];
    return newImage;
}

+(void) setDefaultConf
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    // set default value
    if (![userDefaults objectForKey:@"HideReadPosts"]) {
        [userDefaults setInteger:1 forKey:@"HideReadPosts"];
    }
    
    if (![userDefaults objectForKey:@"IsDebugMode"]) {
        [userDefaults setInteger:0 forKey:@"IsEditorMode"];
    }
    
    if (![userDefaults objectForKey:@"IsEditorMode"]) {
        [userDefaults setInteger:0 forKey:@"IsEditorMode"];
    }
    
    if (![userDefaults objectForKey:@"CategoryList"]) {
        [userDefaults setObject:@"concept,linux,algorithm,cloud,security" forKey:@"CategoryList"];
    }
    
    if (![userDefaults objectForKey:@"tutorialVersion"]) {
        [userDefaults setObject:@"tutorialVersion" forKey:@""];
    }
    
    if (![userDefaults stringForKey:@"Userid"]) {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString* uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL,uuidRef));
        [userDefaults setObject:uuidString forKey:@"Userid"];
        CFRelease(uuidRef);
    }
}

+(NSMutableArray*) getCategoryList
{
    NSMutableArray* category_list = [[NSMutableArray alloc] init];
    NSString* categoryList = [[NSUserDefaults standardUserDefaults] stringForKey:@"CategoryList"];
    NSString* category;
    NSArray *stringArray = [categoryList componentsSeparatedByString: @","];
    for (int i=0; i < [stringArray count]; i++)
    {
        category = stringArray[i];
        category = [category stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [category_list addObject:category];
    }
    return category_list;
}

+ (int) getIndexByCategory:(NSString*) category
{
    NSMutableArray* categoryList = [ComponentUtil getCategoryList];
    int index = -1;
    int i, count = (int)[categoryList count];
    for (i =0; i<count; i++) {
        if([category isEqualToString:[categoryList objectAtIndex:i]]){
            index = i;
            break;
        }
    }
    return index;
}

+(void) showViewInAnimation:(UIView *)view
                   duration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                      scale:(CGFloat)scale
{
    NSTimeInterval step_duration = duration/2;
    [UIView animateWithDuration:step_duration delay:delay
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
                            view.transform = CGAffineTransformMakeScale(scale, scale);
                        } completion:^(BOOL finished){
                            [UIView animateWithDuration:step_duration delay:0
                                                options:UIViewAnimationOptionCurveEaseOut animations:^{
                                                    // animate it to the identity transform (100% scale)
                                                    view.transform = CGAffineTransformIdentity;
                                                } completion:^(BOOL finished){
                                                    // if you want to do something once the animation finishes, put it here
                                                }];
                        }];
}

+ (NSString*)shortUrl:(NSString*) url
{
    if ([url isEqualToString:@""]) {
        return @"";
    }
    int max_len = 25;
    NSString* ret = [url substringToIndex:max_len];
    ret = [ret stringByAppendingString:@"..." ];
    return ret;
}

+ (CGFloat)measureHeightOfUITextView:(UITextView *)textView
{
#if defined(__IPHONE_6_0) || defined(__MAC_10_8)
  // TODO
  return textView.frame.size.height;
#else
    if (![textView.text isEqualToString:@""] && [textView respondsToSelector:@selector(snapshotViewAfterScreenUpdates:)])
    {
        // This is the code for iOS 7. contentSize no longer returns the correct value, so
        // we have to calculate it.
        //
        // This is partly borrowed from HPGrowingTextView, but I've replaced the
        // magic fudge factors with the calculated values (having worked out where
        // they came from)
        
        CGRect frame = textView.bounds;
        // Take account of the padding added around the text.
        
        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;
        
        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;
        
        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;
        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }
        
        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName: paragraphStyle };
        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        
        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }
    else
    {
        return textView.contentSize.height;
    }
#endif
}

+ (NSString*)getUserId
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"Userid"];
}

+ (BOOL)shouldMixpanel
{
    NSRange range = [[[ComponentUtil getUserId] lowercaseString] rangeOfString:@"test"];
    if (range.location != NSNotFound) {
        return NO;
    }
    
    return ([[NSUserDefaults standardUserDefaults] integerForKey:@"IsEditorMode"] != 1);
}

+ (NSString *) md5:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}


+ (NSString *) caculateKey:(id)withObject msg:(NSString*) msg
{
    return [ComponentUtil md5:[NSString stringWithFormat:@"%@%@", [withObject class], msg]];
}

+ (void)showHintOnce:(id)withObject msg:(NSString*)msg
{
    NSString* key = [self caculateKey:withObject msg:msg];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults integerForKey:key] >= 1)
        return;
    // show only for the first time
    [ComponentUtil infoMessage:nil msg:msg enforceMsgBox:TRUE];
    NSInteger value = [userDefaults integerForKey:key];
    [userDefaults setInteger:(value+1) forKey:key];
    [userDefaults synchronize];
}

+ (void)configureVerticalAlign:(UITextView*) tv
{
    // NOTICE: set contentOffset doesn't work before viewDidAppear
    //center vertical alignment
    CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    // NSLog(@"configureVerticalAlign bounds height:%f, contentSize height:%f, topCorrect:%f",
    //       [tv bounds].size.height, [tv contentSize].height, topCorrect);
    
    tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
    
    // //Bottom vertical alignment
    // CGFloat topCorrect = ([tv bounds].size.height - [tv contentSize].height);
    //  topCorrect = (topCorrect <0.0 ? 0.0 : topCorrect);
    //  tv.contentOffset = (CGPoint){.x = 0, .y = -topCorrect};
}

+ (CGFloat) yoffsetVerticalAlign:(UITextView*) tv
{
    //center vertical alignment
    CGFloat topCorrect = ([tv bounds].size.height - [ComponentUtil measureHeightOfUITextView:tv] * [tv zoomScale])/2.0;
    topCorrect = ( topCorrect < 0.0 ? 0.0 : topCorrect );
    return topCorrect;
}

+ (NSString*) currentTutorialVersion
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+ (BOOL) shouldShowTutorial
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* tutorialVersion = [userDefaults objectForKey:@"tutorialVersion"];
    //NSLog(@"shouldShowTutorial. current tutorialVersion:%@", tutorialVersion);
    return ![tutorialVersion isEqualToString:[ComponentUtil currentTutorialVersion]];
}

+ (int) modAdd:(int)startVal offset:(int)offset modCount:(int)modCount
{
  int ret = startVal + offset;
  while(ret <modCount) {
    ret = ret + modCount;
  }
  int num = (int)floorf(ret*1.0f/modCount);
  ret = ret - modCount * num;
  //NSLog(@"modAdd startVal:%d, offset:%d, modCount:%d, ret:%d", startVal, offset, modCount, ret);
  return ret;
}
@end
