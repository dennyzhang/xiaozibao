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
  NSString* ret = [NSString stringWithFormat:@"header_%d.png", arc4random() % 27 + 1];
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

+(UIImage *) resizeImage:(UIImage *)orginalImage resizeSize:(CGSize)size
{
    CGFloat actualHeight = orginalImage.size.height;
    CGFloat actualWidth = orginalImage.size.width;
    //  if(actualWidth <= size.width && actualHeight<=size.height)
    //  {
    //      return orginalImage;
    //  }
    float oldRatio = actualWidth/actualHeight;
    float newRatio = size.width/size.height;
    if(oldRatio < newRatio)
    {
        oldRatio = size.height/actualHeight;
        actualWidth = oldRatio * actualWidth;
        actualHeight = size.height;
    }
    else
    {
        oldRatio = size.width/actualWidth;
        actualHeight = oldRatio * actualHeight;
        actualWidth = size.width;
    }
    
    CGRect rect = CGRectMake(0.0,0.0,actualWidth,actualHeight);
    UIGraphicsBeginImageContext(rect.size);
    [orginalImage drawInRect:rect];
    orginalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return orginalImage;
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
      [userDefaults setObject:@"linux,concept,cloud,security,algorithm" forKey:@"CategoryList"];
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
@end
