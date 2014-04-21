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
#import "posts.h"

@interface MenuViewController ()

@end

@implementation MenuViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.scrollEnabled = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIImageView *boxBackView = [[UIImageView alloc] 
                                initWithImage:[UIImage imageNamed:@"menu-background.png"]];
    [self.tableView setBackgroundView:boxBackView];
      
    //self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;

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
    
    // when tap on empty area, hide menu
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                            initWithTarget:self action:@selector(handleSingleTapOnFooter:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  return (![NSStringFromClass([touch.view class]) isEqualToString:@"UITableViewCellContentView"]);
  //return YES;
}

- (IBAction) handleSingleTapOnFooter: (UIGestureRecognizer *) sender {
  NSLog(@"handleSingleTapOnFooter sender:%@", sender);
    // hide menu
    SWRevealViewController* rvc = self.revealViewController;
    [rvc rightRevealToggleAnimated:YES];
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
          // load view
            MasterViewController* dstViewController = segue.destinationViewController;
            [dstViewController updateNavigationTitle:c.textLabel.text];
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

    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    cell.textLabel.text = [self valueToText:value];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *customLabel = [[UILabel alloc] init];
    customLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    customLabel.textColor = [UIColor whiteColor];
    return customLabel;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
   return [self.sectionArray objectAtIndex:section];
}

- (NSString *)valueToText:(NSString*) value {
  return [value capitalizedString];
}

- (NSString *)textToValue:(NSString*) text {
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
