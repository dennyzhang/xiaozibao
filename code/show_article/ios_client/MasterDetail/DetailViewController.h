//
//  DetailViewController.h
//  MasterDetail
//
//  Created by mac on 13-7-13.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Posts.h"

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) Posts* detailItem;

@property (retain, nonatomic) IBOutlet UITextView *detailUITextView;

@property (retain, nonatomic) IBOutlet UIButton *voteupButton;
@property (retain, nonatomic) IBOutlet UIButton *votedownButton;
@property (retain, nonatomic) IBOutlet UIButton *voteimproveButton;
@property (retain, nonatomic) IBOutlet UIButton *votesubmitButton;
@property (retain, nonatomic) IBOutlet UITextField *feedbackUITextField;

@end
