//
//  DetailViewController.h
//  MasterDetail
//
//  Created by mac on 13-7-13.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Posts.h"

#import "PostsSqlite.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) Posts* detailItem;
@property (nonatomic) sqlite3* postDB;
@property (strong, nonatomic) NSString* dbPath;

@property (retain, nonatomic) IBOutlet UITextView *detailUITextView;


- (void)setDetailItem:(Posts*)newDetailItem
               postDB:(sqlite3*)db
               dbPath:(NSString*)databasePath;

@end
