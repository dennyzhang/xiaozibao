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
{
    UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:title message:msg delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:nil, nil];
    [alert show];
    [ComponentUtil timedAlert:alert];

}

+(void)timedAlert:(UIAlertView *) alertView
{
    [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:HIDE_MESSAGEBOX_DELAY];
}

+(void)dismissAlert:(UIAlertView *) alertView
{
    [alertView dismissWithClickedButtonIndex:0 animated:YES];
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

@end
