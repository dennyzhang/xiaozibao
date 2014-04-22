//
//  MasterViewController.h
//  MasterDetail
//
//  Created by mac on 13-7-13.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@class DetailViewController;

@interface MasterViewController : UIViewController <
  UIPageViewControllerDataSource, UIPageViewControllerDelegate>

#define TAG_BUTTON_COIN 1000
#define TAG_MASTERVIEW_SCORE_TEXT 1001

- (void) updateNavigationTitle:(NSString*) navigationTitle;
@end
