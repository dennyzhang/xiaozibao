//
//  ReviewViewController.h
//  
//
//  Created by mac on 14-3-24.
//
//

#import <UIKit/UIKit.h>

@interface ReviewViewController : UIViewController <UISplitViewControllerDelegate, UIScrollViewDelegate>
@property (retain, nonatomic) IBOutlet UITextView *summaryTextView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
#define UITABLE_HEIGHT 200
@end
