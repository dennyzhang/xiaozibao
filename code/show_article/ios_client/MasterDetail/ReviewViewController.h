//
//  ReviewViewController.h
//  
//
//  Created by mac on 14-3-24.
//
//
#import "constants.h"

#import <UIKit/UIKit.h>

@interface ReviewViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (retain, nonatomic) IBOutlet UITextView *summaryTextView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;

#define UITABLE_HEIGHT 300
@end
