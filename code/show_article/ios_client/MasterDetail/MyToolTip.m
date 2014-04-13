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
    [[MyToolTip singleton] removeObject:popTipView];
    self.currentPopTipViewTarget = nil;
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
-(void) init_data
{
  self.contents = [NSDictionary dictionaryWithObjectsAndKeys:
                                  // Rounded rect buttons
                                  @"A CMPopTipView will automatically position itself within the container view.", [NSNumber numberWithInt:11],
                                @"A CMPopTipView will automatically orient itself above or below the target view based on the available space.", [NSNumber numberWithInt:12],
                                @"A CMPopTipView always tries to point at the center of the target view.", [NSNumber numberWithInt:13],
                                @"A CMPopTipView can point to any UIView subclass.", [NSNumber numberWithInt:14],
                                @"A CMPopTipView will automatically size itself to fit the text message.", [NSNumber numberWithInt:15],
                                // Nav bar buttons
                                @"This CMPopTipView is pointing at a leftBarButtonItem of a navigationItem.", [NSNumber numberWithInt:21],
                         @"Two popup animations are provided: slide and pop. Tap other buttons to see them both.", [NSNumber numberWithInt:22],
                                // Toolbar buttons
                                @"CMPopTipView will automatically point at buttons either above or below the containing view.", [NSNumber numberWithInt:31],
                                @"The arrow is automatically positioned to point to the center of the target button.", [NSNumber numberWithInt:32],
                                @"CMPopTipView knows how to point automatically to UIBarButtonItems in both nav bars and tool bars.", [NSNumber numberWithInt:33],
                                nil];
  self.titles = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"Title", [NSNumber numberWithInt:14],
                              @"Auto Orientation", [NSNumber numberWithInt:12],
                              nil];
  
  // Array of (backgroundColor, textColor) pairs.
  // NSNull for either means leave as default.
  // A color scheme will be picked randomly per CMPopTipView.
  self.colorSchemes = [NSArray arrayWithObjects:
                                 [NSArray arrayWithObjects:[NSNull null], [NSNull null], nil],
                               [NSArray arrayWithObjects:[UIColor colorWithRed:134.0/255.0 green:74.0/255.0
                                                                          blue:110.0/255.0 alpha:1.0], [NSNull null], nil],
                               [NSArray arrayWithObjects:[UIColor darkGrayColor], [NSNull null], nil],
                               [NSArray arrayWithObjects:[UIColor lightGrayColor], [UIColor darkTextColor], nil],
                               [NSArray arrayWithObjects:[UIColor orangeColor], [UIColor blueColor], nil],
                               [NSArray arrayWithObjects:[UIColor colorWithRed:220.0/255.0 green:0.0/255.0
                                                                          blue:0.0/255.0 alpha:1.0], [NSNull null], nil],
                               nil];
  self.visiblePopTipViews = [NSMutableArray array];
}

- (NSArray*) getColorSchmeme
{
  return [self.colorSchemes objectAtIndex:foo4random()*[self.colorSchemes count]];
}

-(NSString*) getContentByKey:(NSNumber*) key
{
  return [self.contents objectForKey:key];
}

-(NSString*) getTitleByKey:(NSNumber*) key
{
  return [self.titles objectForKey:key];
}

- (void)reset
{
	while ([self.visiblePopTipViews count] > 0) {
		CMPopTipView *popTipView = [self.visiblePopTipViews objectAtIndex:0];
		[popTipView dismissAnimated:YES];
		[self.visiblePopTipViews removeObjectAtIndex:0];
	}

}

-(void)removeObject:(CMPopTipView *)popTipView
{
  [self.visiblePopTipViews removeObject:popTipView];
}

-(void)addObject:(CMPopTipView *)popTipView
{
  [self.visiblePopTipViews addObject:popTipView];
}

- (IBAction)toolTipAction:(id)sender view:(UIView*) view
{

	if (sender == self.currentPopTipViewTarget) {
		// Dismiss the popTipView and that is all
		self.currentPopTipViewTarget = nil;
	}
	else {
		NSString *contentMessage = nil;
		UIView *contentView = nil;
		NSNumber *key = [NSNumber numberWithInteger:[(UIView *)sender tag]];
                id content = [[MyToolTip singleton] getContentByKey:key];
		if ([content isKindOfClass:[UIView class]]) {
			contentView = content;
		}
		else if ([content isKindOfClass:[NSString class]]) {
			contentMessage = content;
		}
		else {
			contentMessage = @"A CMPopTipView can automatically point to any view or bar button item.";
		}
                NSArray *colorScheme = [[MyToolTip singleton] getColorSchmeme];
		UIColor *backgroundColor = [colorScheme objectAtIndex:0];
		UIColor *textColor = [colorScheme objectAtIndex:1];
		
		NSString *title = [[MyToolTip singleton] getTitleByKey:key];
		
		CMPopTipView *popTipView;
		if (contentView) {
			popTipView = [[CMPopTipView alloc] initWithCustomView:contentView];
		}
		else if (title) {
			popTipView = [[CMPopTipView alloc] initWithTitle:title message:contentMessage];
		}
		else {
			popTipView = [[CMPopTipView alloc] initWithMessage:contentMessage];
		}
		popTipView.delegate = [MyToolTip singleton];
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
                [popTipView autoDismissAnimated:YES atTimeInterval:3.0];

		if ([sender isKindOfClass:[UIButton class]]) {
			UIButton *button = (UIButton *)sender;
			[popTipView presentPointingAtView:button inView:view animated:YES];
		}
		else {
			UIBarButtonItem *barButtonItem = (UIBarButtonItem *)sender;
			[popTipView presentPointingAtBarButtonItem:barButtonItem animated:YES];
		}
		
                [[MyToolTip singleton] addObject:popTipView];
                self.currentPopTipViewTarget = sender;
	}
}

@end
