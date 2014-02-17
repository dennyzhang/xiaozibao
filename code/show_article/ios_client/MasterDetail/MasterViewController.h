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

#import "PostsSqlite.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (retain, nonatomic) DetailViewController *detailViewController;
@property (nonatomic, retain) CLLocationManager *locationManager;  

@property (nonatomic, retain) NSString* topic;
@property (nonatomic, retain) NSString* username;
@property (atomic, retain) NSNumber* bottom_num;
@property (atomic, retain) NSNumber* page_count;

@property (retain, nonatomic) IBOutlet UITextField *serverUITextField;

- (void) init_data:(NSString*)username_t
             topic_t:(NSString*)topic_t;
@end
