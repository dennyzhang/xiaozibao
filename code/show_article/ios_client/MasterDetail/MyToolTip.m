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

+(MyToolTip *)singleton {
 static MyToolTip *shared = nil;
 
 if(shared == nil) {
  shared = [[MyToolTip alloc] init];
  [shared init_data];
 }
 return shared;
}

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
@end
