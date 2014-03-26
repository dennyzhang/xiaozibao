//
//  componentUtil.m
//  MasterDetail
//
//  Created by mac on 14-3-26.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "ComponentUtil.h"

@implementation ComponentUtil
+ (void) addScoreToButton:(UIButton*) btn score:(NSInteger)score
                 fontSize:(NSInteger)fontSize
               chWidth:(NSInteger)chWidth
               chHeight:(NSInteger)chHeight
                 tag:(NSInteger)tag
{
  NSString* scoreStr;
  // TODO better way, instead of workaround for the layout
  if (score < 10)
    scoreStr = [NSString stringWithFormat: @"%d  ", (int)score];
  else
    scoreStr = [NSString stringWithFormat: @"%d ", (int)score];

    int width = btn.frame.size.width;
    int height = btn.frame.size.height;
    int scoreWidth = chWidth * [scoreStr length];
    int scoreHeight = chHeight;

    UITextView* scoreTextView = [[UITextView alloc] initWithFrame:CGRectMake(width - scoreWidth + 0.75*chWidth,
                                                                              height - scoreHeight,
                                                                              scoreWidth, scoreHeight)];
    scoreTextView.backgroundColor = [UIColor clearColor];
    scoreTextView.font = [UIFont fontWithName:FONT_NAME1 size:fontSize];
    scoreTextView.text = scoreStr;
    scoreTextView.tag = tag;
    [scoreTextView setUserInteractionEnabled:NO];

    [btn addSubview:scoreTextView];
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

@end
