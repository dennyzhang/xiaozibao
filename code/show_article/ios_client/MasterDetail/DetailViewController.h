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

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) Posts* detailItem;

@property (retain, nonatomic) IBOutlet UITextView *detailUITextView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UITextView *titleTextView;
@property (retain, nonatomic) IBOutlet UITextView *linkTextView;
@end
