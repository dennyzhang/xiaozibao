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
#import "ReviewViewController.h"
#import "UserProfile.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIScrollViewDelegate>
#define TAG_BUTTON_VOTEUP 2001
#define TAG_BUTTON_VOTEDOWN 2002
#define TAG_BUTTON_FAVORITE 2003
#define TAG_BUTTON_MORE 2004
#define TAG_BUTTON_COMMENT 2005
#define TAG_BUTTON_COIN 2006

#define INVALID_STRING @"INVALID_STRING"
@property (strong, nonatomic) Posts* detailItem;

@property (retain, nonatomic) IBOutlet UITextView *detailUITextView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UITextView *titleTextView;
@property (retain, nonatomic) IBOutlet UITextView *linkTextView;

@end
