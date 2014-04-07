//
//  MenuViewController.h
//  MasterDetail
//
//  Created by mac on 13-7-23.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UITableViewController <UIGestureRecognizerDelegate>
@property (atomic, retain) NSMutableArray* category_list;
@property (atomic, retain) NSArray* sectionArray;
- (void)load_category_list;
@end
