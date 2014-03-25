//
//  ReviewViewController.h
//  
//
//  Created by mac on 14-3-24.
//
//
#import "constants.h"
#import "posts.h"

#import <UIKit/UIKit.h>

@interface ReviewViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (retain, nonatomic) IBOutlet UITextView *summaryTextView;
@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSNumber* score;

#define TAG_BUTTON_SHARE 3001
#define UITABLE_HEIGHT 300
+ (void) addScoreToButton:(UIButton*) btn score:(NSInteger)score
                 fontSize:(NSInteger)fontSize
               chWidth:(NSInteger)chWidth
               chHeight:(NSInteger)chHeight;
@end
