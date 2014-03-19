//
//  MenuViewController.m
//  MasterDetail
//
//  Created by mac on 13-7-23.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import "MenuViewController.h"
#import "MasterViewController.h"
#import "constants.h"

@interface MenuViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MenuViewController

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    NSLog(@"prepareForSegue");
    // configure the destination view controller:
    if ( [segue.destinationViewController isKindOfClass: [MasterViewController class]] &&
        [sender isKindOfClass:[UITableViewCell class]] )
    {
        UITableViewCell* c = sender;
        if (c.textLabel.isEnabled == true) {
            MasterViewController* dstViewController = segue.destinationViewController;
            [dstViewController init_data:@"denny" topic_t:c.textLabel.text]; // TODO
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
        
        NSAssert( [rvc.frontViewController isKindOfClass: [UINavigationController class]], @"oops!  for this segue we want a permanent navigation controller in the front!" );
        
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _objects = [[NSMutableArray alloc] init];
    [self load_topic_list];
}

- (void)load_topic_list
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString* topicList = [userDefaults stringForKey:@"TopicList"];
  NSString* topic;
  NSArray *stringArray = [topicList componentsSeparatedByString: @","];
  for (int i=0; i < [stringArray count]; i++)
  {
      topic = stringArray[i];
      topic = [topic stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
      [_objects insertObject:topic atIndex:0];
  }
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section == 0) {
        return _objects.count;
    }
    if (section == 1) {
        return 3;
    }
    return -1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return @"Topics";
    }
    if (section == 1) {
        return @"Preference";
    }
    return @"ERROR tableview:titleForHeaderInSection";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (indexPath.section == 0) {
        cell.textLabel.text = _objects[indexPath.row];
        return cell;
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Saved posts";
        }
        if (indexPath.row == 1) {
            cell.textLabel.text = MORE_TOPICS;
            cell.textLabel.enabled = false;
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = APP_SETTING;
        }
        return cell;
    }
    return cell;
}

@end
