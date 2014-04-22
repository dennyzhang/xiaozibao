//
//  QCViewController.h
//  MasterDetail
//
//  Created by mac on 14-4-20.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionCategory.h"

@interface QCViewController : UIViewController <
  UITableViewDelegate, UITableViewDataSource,
  UITextFieldDelegate>

#define TAG_TEXTVIEW_IN_CELL 1001
#define TAG_METADATA_IN_CELL 1002
#define TAG_ICON_IN_CELL 1003
#define TAG_VOTEUP_IN_CELL 1004
#define TAG_SWITCH_HIDE_READ_POST 1005
#define TAG_SWITCH_EDITOR_MODE 1006
#define TAG_SWITCH_DEBUG_MODE 1007
#define TAG_VOTEUP_TEXT 1008
#define TAG_CELL_VIEW 1009

#define TAG_TABLE_FOOTER_INDIACTOR 1011

#define CLEAN_CACHE @"Clean cache"
#define USER_ID @"User id"
#define FOLLOW_TWITTER @"Follow us on Twitter"
#define FOLLOW_WEIBO @"Follow us on Weibo"
#define FOLLOW_MAILTO @"Mail to us"

#define PAGE_COUNT 10
#define HEIGHT_IN_CELL_OFFSET 10
#define HEIGHT_CELL_BANNER 50

@property (assign, nonatomic) int viewId;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

- (void) init_data:(QuestionCategory *)qc
   navigationTitle:(NSString*)navigationTitle;

@end
