//
//  MenuViewController.m
//  MasterDetail
//
//  Created by mac on 13-7-23.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import "MenuViewController.h"
#import "MasterViewController.h"
#import "global.h"

@interface MenuViewController ()

@end

@implementation MenuViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.sectionArray = [NSArray arrayWithObjects:@" Questions", @" Preference",nil];
    self.category_list = [ComponentUtil getCategoryList];

    //swipe guesture
    UISwipeGestureRecognizer *leftswipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    leftswipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftswipe];
    leftswipe.delegate = self;

}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    //NSLog(@"MenuViewController segue identifier: %@", [segue identifier]);
    // configure the destination view controller:
    if ( [segue.destinationViewController isKindOfClass: [MasterViewController class]] &&
        [sender isKindOfClass:[UITableViewCell class]] )
    {
        UITableViewCell* c = sender;
        if (c.textLabel.isEnabled == true) {
            MasterViewController* dstViewController = segue.destinationViewController;

            NSIndexPath *path = [self.tableView indexPathForCell:c];
            NSString* value = [[self textToValue:c.textLabel.text] lowercaseString];

            NSString* category = NONE_QUESTION_CATEGORY;
            if (path.section == 0) {
              category = value;
            }
            if ([value isEqualToString:[SAVED_QUESTIONS lowercaseString]]) {
             category = SAVED_QUESTIONS;
            }

            NSString* userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"Userid"];
            [dstViewController init_data:userid category_t:category
                         navigationTitle:c.textLabel.text];
            [dstViewController view];
        }
        else { // disable actions
            return;
        }
    }
    
    // configure the segue.
    // in this case we dont swap out the front view controller, which is a UINavigationController.
    // but we could..
    if ([segue isKindOfClass: [SWRevealViewControllerSegue class]] )
    {
        SWRevealViewControllerSegue* rvcs = (SWRevealViewControllerSegue*) segue;
        
        SWRevealViewController* rvc = self.revealViewController;
        NSAssert( rvc != nil, @"oops! must have a revealViewController" );
        
        NSAssert([rvc.frontViewController isKindOfClass: [UINavigationController class]], @"oops!  for this segue we want a permanent navigation controller in the front!" );
        
        rvcs.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            
            UINavigationController* nc = (UINavigationController*)rvc.frontViewController;
            [nc setViewControllers: @[ dvc ] animated: YES ];
            
            [rvc setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
    }
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sectionArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return self.category_list.count;
    }
    if (section == 1) {
        return 2;
    }
    return -1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString* value = @"";
    cell.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    if (indexPath.section == 0) {
      value = self.category_list[indexPath.row];
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            value = SAVED_QUESTIONS;
        }
        if (indexPath.row == 1) {
            value = APP_SETTING;
        }
    }
    //cell.accessoryType = UITableViewCellAccessoryDetailButton;
    cell.textLabel.text = [self valueToText:value];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *customLabel = [[UILabel alloc] init];
    customLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    customLabel.textColor = [UIColor whiteColor];
    customLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_header.png"]];

    //customLabel.foregroundColor = [UIColor whiteColor];
    return customLabel;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
   return [self.sectionArray objectAtIndex:section];
}

- (NSString *)valueToText:(NSString*) value {
    // int width = 30;
    // int paddingWidth = width - [value length];

    // NSString* ret = [[NSString alloc] initWithFormat:@"%@%@>", [value capitalizedString],
    //            [@"" stringByPaddingToLength:paddingWidth withString: @" " startingAtIndex:0]];
    // NSLog(@"value:%@, ret:%@, paddingWidth:%d", value, ret, paddingWidth);
    // return ret;
  return [value capitalizedString];
}

- (NSString *)textToValue:(NSString*) text {
    // NSRange range = NSMakeRange (0, [text length] - 1);
    // NSString* str = [text substringWithRange:range];
    // return [str
    //            stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
   return [text capitalizedString];
}

-(void) leftSwipe:(UISwipeGestureRecognizer*)recognizer {
    SWRevealViewController* rvc = self.revealViewController;
    [rvc rightRevealToggleAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [Posts updateCategoryList:[NSUserDefaults standardUserDefaults]];
    self.category_list = [ComponentUtil getCategoryList];
    [self.tableView reloadData];
}

@end
