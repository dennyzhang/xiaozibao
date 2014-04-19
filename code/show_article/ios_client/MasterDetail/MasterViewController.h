//
//  MasterViewController.h
//  MasterDetail
//
//  Created by mac on 13-7-13.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

//#import "/usr/include/sqlite3.h"
#import "/usr/local/opt/sqlite/include/sqlite3.h"

#import "global.h"
#import "Posts.h"
#import "PostsSqlite.h"
#import "ComponentUtil.h"
#import "UserProfile.h"
#import "MenuViewController.h"

@class DetailViewController;

@interface MasterViewController : UIViewController <
                UIGestureRecognizerDelegate, UIScrollViewDelegate,
                UITableViewDelegate, UITableViewDataSource,
                                UITextFieldDelegate>

#define TAG_BUTTON_COIN 4001
#define TAG_TEXTVIEW_IN_CELL 1001
#define TAG_METADATA_IN_CELL 1002
#define TAG_ICON_IN_CELL 1003
#define TAG_VOTEUP_IN_CELL 1004
#define TAG_SWITCH_HIDE_READ_POST 1005
#define TAG_SWITCH_EDITOR_MODE 1006
#define TAG_SWITCH_DEBUG_MODE 1007
#define TAG_VOTEUP_TEXT 1008
#define TAG_MASTERVIEW_SCORE_TEXT 1009

#define TAG_TABLE_HEADER_INDIACTOR 1010
#define TAG_TABLE_FOOTER_INDIACTOR 1011

#define CLEAN_CACHE @"Clean cache"
#define USER_ID @"User id"
#define FOLLOW_TWITTER @"Follow us on Twitter"
#define FOLLOW_WEIBO @"Follow us on Weibo"
#define FOLLOW_MAILTO @"Mail to us"

#define PAGE_COUNT 10
#define ROW_HEIGHT 160.0f

@property (nonatomic, retain) NSString* navigationTitle;
@property (nonatomic, strong) UIScrollView *questionScrollView;

@end
