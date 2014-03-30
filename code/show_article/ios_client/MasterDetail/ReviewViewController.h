//
//  ReviewViewController.h
//  
//
//  Created by mac on 14-3-24.
//
//
#import "global.h"
#import "posts.h"
#import "UserProfile.h"
#import "ComponentUtil.h"
#import "PostsSqlite.h"
#import "DetailViewController.h"

#import <UIKit/UIKit.h>

@interface ReviewViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (retain, nonatomic) IBOutlet UITextView *summaryTextView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) IBOutlet UIButton *coinButton;
@property (nonatomic, retain) NSString* category;
@property (nonatomic, retain) NSMutableArray* questions;

#define TAG_BUTTON_SHARE 3001
#define TAG_SCORE_TEXT 3002

@end
