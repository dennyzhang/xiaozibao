//
//  DetailViewController.h
//  MasterDetail
//
//  Created by mac on 13-7-13.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

#import "Posts.h"
#import "PostsSqlite.h"
#import "ReviewViewController.h"
#import "UserProfile.h"
#import "ComponentUtil.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIScrollViewDelegate,
                                                    UITextViewDelegate, UIGestureRecognizerDelegate,
                                                    UIWebViewDelegate, ADBannerViewDelegate>
#define TAG_BUTTON_VOTEUP 2001
#define TAG_BUTTON_VOTEDOWN 2002
#define TAG_BUTTON_UNDO 2003
#define TAG_BUTTON_FAVORITE 2004
#define TAG_BUTTON_MORE 2005
#define TAG_BUTTON_COMMENT 2006
#define TAG_BUTTON_COIN_DETAILVIEW 2007
#define TAG_SCORE_TEXT_DETAILVIEW 2008
#define TAG_BUTTON_INFO 2009

#define MAX_POST_CONTENT 700

#define MIN_HEADER_HEIGHT 120
#define MAX_HEADER_HEIGHT 400
#define INIT_HEADER_HEIGHT 300

#define CONTENT_MARGIN_OFFSET 15

#define FIELD_SEPARATOR @"&$!"

#define INVALID_STRING @"INVALID_STRING"
#define FEEDBACK_ENVOTEUP @"tag envoteup"
#define FEEDBACK_ENVOTEDOWN @"tag envotedown"
#define FEEDBACK_ENFAVORITE @"tag enfavorite"
#define FEEDBACK_DEVOTEUP @"tag devoteup"
#define FEEDBACK_DEVOTEDOWN @"tag devotedown"
#define FEEDBACK_DEFAVORITE @"tag defavorite"

@property (strong, nonatomic) Posts* detailItem;

@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UITextView *questionTextView;
@property (retain, nonatomic) IBOutlet UITextView *detailUITextView;
@property (retain, nonatomic) IBOutlet UIView *adContainerView;

@property (retain, nonatomic) IBOutlet UIButton *coinButton;
@property (atomic, retain) NSNumber* shouldShowCoin;

@end
