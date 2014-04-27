//
//  MyToolTip.m
//  MasterDetail
//
//  Created by mac on 14-4-13.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "MyToolTip.h"

#define foo4random() (1.0 * (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX)

@implementation MyToolTip

#pragma mark - CMPopTipViewDelegate methods

- (void)popTipViewWasDismissedByUser:(CMPopTipView *)popTipView
{
    [self.visiblePopTipViews removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
    [self showToolTip];
}

#pragma mark - methods
+(MyToolTip *)singleton {
    static MyToolTip *shared = nil;
    
    if(shared == nil) {
        shared = [[MyToolTip alloc] init];
        [shared init_data];
    }
    return shared;
}

#pragma mark - private methods
-(void)reset:(UIView*)view
{
    self.popView = view;
    while ([self.visiblePopTipViews count] > 0) {
        CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
        [popTipView dismissAnimated:YES];
        [self.visiblePopTipViews removeObjectAtIndex:0];
    }
    // clean up
    [self.messages removeAllObjects];
    [self.components removeAllObjects];
}

-(void)toolTipAction:(id)sender msg:(NSString*)msg
{
  //NSLog(@"sender:%@", sender);
    if (sender == self.currentPopTipViewTarget) {
        // Dismiss the popTipView and that is all
        self.currentPopTipViewTarget = nil;
    }
    else {
        UIView *contentView = nil;
        
        NSArray *colorScheme = [self getColorSchmeme];
        UIColor *backgroundColor = [colorScheme objectAtIndex:0];
        UIColor *textColor = [colorScheme objectAtIndex:1];
        
        CMPopTipView *popTipView;
        if (contentView) {
            popTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
        }
        else {
            popTipView = [[CMPopTipView alloc] initWithMessage:msg];
        }
        popTipView.borderWidth = 0.0f;
        popTipView.delegate = self;
        if (backgroundColor && ![backgroundColor isEqual:[NSNull null]]) {
            popTipView.backgroundColor = backgroundColor;
        }
        if (textColor && ![textColor isEqual:[NSNull null]]) {
            popTipView.textColor = textColor;
        }
        
        popTipView.animation = arc4random() % 2;
        popTipView.has3DStyle = (BOOL)(arc4random() % 2);
        
        popTipView.dismissTapAnywhere = YES;
        // auto dismiss after several seconds
        [popTipView autoDismissAnimated:YES atTimeInterval:20.0];
        
        if ([sender isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)sender;
            [popTipView presentPointingAtView:button inView:self.popView animated:YES];
        }
        else {
            UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
            [popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
        }
        [self.visiblePopTipViews addObject:popTipView];
        self.currentPopTipViewTarget = sender;
        
        // update visit count
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString* key = [ComponentUtil caculateKey:sender msg:msg];
        NSInteger value = [userDefaults integerForKey:key];
        [userDefaults setInteger:(value+1) forKey:key];
        [userDefaults synchronize];
    }
}

-(void) init_data
{
    self.messages = [[NSMutableArray alloc] init];
    self.components = [[NSMutableArray alloc] init];
    
    // Array of (backgroundColor, textColor) pairs.
    // NSNull for either means leave as default.
    // A color scheme will be picked randomly per CMPopTipView.
    self.visiblePopTipViews = [NSMutableArray array];
}

- (NSArray*) getColorSchmeme
{
    NSArray* colorSchemes = [NSArray arrayWithObjects:
                                       //[NSArray arrayWithObjects:[NSNull null], [NSNull null], nil],
//                              [NSArray arrayWithObjects:[UIColor colorWithRed:134.0/255.0 green:74.0/255.0
//                                                                         blue:110.0/255.0 alpha:1.0], [NSNull null], nil],
                             [NSArray arrayWithObjects:[UIColor colorWithRed:39.0/255.0 green:39.0/255.0
                                                                        blue:39.0/255.0 alpha:0.8], [NSNull null], nil],
                             // [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor darkTextColor], nil],
                             // [NSArray arrayWithObjects:[UIColor orangeColor], [UIColor blueColor], nil],
                             // [NSArray arrayWithObjects:[UIColor colorWithRed:220.0/255.0 green:0.0/255.0
                             //                                            blue:0.0/255.0 alpha:1.0], [NSNull null], nil],
                             nil];
    
    return [colorSchemes objectAtIndex:foo4random()*[colorSchemes count]];
}

-(void)addToolTip:(id)withObject msg:(NSString*) msg
{
    if(!withObject) {
      NSLog(@"Warning: addToolTip fail, due to withObject is nil");
      return;
    }
    NSString* key = [ComponentUtil caculateKey:withObject msg:msg];
    if ([[NSUserDefaults standardUserDefaults] integerForKey:key] >= 1)
        return;
    [self.components addObject:withObject];
    [self.messages addObject:msg];
}

-(void)showToolTip
{
    if ([self.components count] == 0)
        return;
    
    NSString* msg = [self.messages objectAtIndex:0];
    id withObject = [self.components objectAtIndex:0];
    [self.messages removeObjectAtIndex:0];
    [self.components removeObjectAtIndex:0];
    
    [self toolTipAction:withObject msg:msg];
}

@end
