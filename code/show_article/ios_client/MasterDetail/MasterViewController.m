//
// MasterViewController.m
// MasterDetail
//
// Created by mac on 13-7-13.
// Copyright (c) 2013年 mac. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "AFJSONRequestOperation.h"
// #import "Mixpanel.h"

#import "global.h"

#import <CoreFoundation/CFUUID.h>

@interface MasterViewController () {
    sqlite3 *postsDB;
    NSString *dbPath;
    int bottom_num;
    UIView* footerView;
    UIView* headerView;
}

@end

@implementation MasterViewController

@synthesize locationManager, category, username;
@synthesize objects;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTableIndicatorView];
    
    NSLog(@"MasterViewController load");

    // load menu category list
    SWRevealViewController* rvc = self.revealViewController;
    MenuViewController* menuvc = (MenuViewController*)rvc.rearViewController;
    [menuvc load_category_list];
    
    // components
    [self addCompoents];

    // set UserDefaults
    [ComponentUtil setDefaultConf];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    //swipe guesture
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSwipe:)];
    [self.view addGestureRecognizer:swipe];
    swipe.delegate = self;
    //swipe guesture
    UISwipeGestureRecognizer *leftswipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
    leftswipe.direction=UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftswipe];
    leftswipe.delegate = self;
}

- (void)init_data:(NSString*)username_t
       category_t:(NSString*)category_t
  navigationTitle:(NSString*)navigationTitle
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.category=category_t;
    self.titleLabel.text = navigationTitle;
    
    if ([navigationTitle isEqualToString:MORE_CATEGORY] || [navigationTitle isEqualToString:APP_SETTING]) {
        return;
    }
    
    self->bottom_num = 1;
    self.username=username_t;
    
    if (!objects){
        objects = [[NSMutableArray alloc] init];
        
    }
    
    NSIndexPath *indexPath;
    for (int i=0; i<[objects count]; i++) {
        [objects removeObjectAtIndex:0];
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    self->postsDB = [PostsSqlite openSqlite:dbPath];
    self->dbPath = [PostsSqlite getDBPath];
    NSLog(@"init_data, dbPath:%@", self->dbPath);
    
    if (!userDefaults) {
        userDefaults = [NSUserDefaults standardUserDefaults];
    }
    
    [PostsSqlite loadPosts:postsDB dbPath:dbPath category:self.category
                   objects:objects hideReadPosts:[userDefaults integerForKey:@"HideReadPosts"] tableview:self.tableView];
    [self fetchArticleList:username category_t:self.category start_num_t:0 shouldAppendHead:YES];
}

- (void) refreshTableHead
{
    [(UIActivityIndicatorView *)[headerView viewWithTag:TAG_TABLE_HEADER_INDIACTOR] startAnimating];
    [self fetchArticleList:username category_t:self.category
               start_num_t:0
          shouldAppendHead:YES];
}

- (void) refreshTableTail
{
    [(UIActivityIndicatorView *)[footerView viewWithTag:TAG_TABLE_FOOTER_INDIACTOR] startAnimating];
    [self fetchArticleList:username category_t:self.category
               start_num_t:self->bottom_num * PAGE_COUNT
          shouldAppendHead:NO];
}

- (bool)addToTableView:(int)index
                  post:(Posts*)post
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"HideReadPosts"] == 1) {
        if (post.readcount.intValue !=0 )
            return YES;
    }
    
    bool ret = YES;
    [objects insertObject:post atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    return ret;
}

- (void)stopActivityIndicator:(bool)shouldAppendHead {
    if (shouldAppendHead == TRUE) {
        [(UIActivityIndicatorView *)[headerView viewWithTag:TAG_TABLE_HEADER_INDIACTOR] stopAnimating];
    }
    else {
        [(UIActivityIndicatorView *)[footerView viewWithTag:TAG_TABLE_FOOTER_INDIACTOR] stopAnimating];
    }
}

- (void)fetchArticleList:(NSString*)userid
              category_t:(NSString*)category_t
             start_num_t:(int)start_num_t
        shouldAppendHead:(bool)shouldAppendHead
{
    if ([self.navigationItem.title isEqualToString:SAVED_QUESTIONS])
        return;
    
    NSLog(@"fetchArticleList category_t:%@, start_num_t:%d, shouldAppendHead:%d",
          category_t, start_num_t, shouldAppendHead);
    NSString *urlPrefix=SERVERURL;
    // TODO: voteup defined by users
    NSString *sortMethod;
    NSString *urlStr;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"IsEditorMode"] == 0) {
        // If anyone votedown, it's not shown
        sortMethod = @"hotest";
        urlStr= [NSString stringWithFormat: @"%@api_list_posts_in_topic?uid=%@&topic=%@&start_num=%d&count=%d&sort_method=%@&votedown=0",
                 urlPrefix, userid, category_t, start_num_t, PAGE_COUNT, sortMethod];
    }
    else {
        sortMethod = @"latest";
        urlStr= [NSString stringWithFormat: @"%@api_list_posts_in_topic?uid=%@&topic=%@&start_num=%d&count=%d&sort_method=%@",
                 urlPrefix, userid, category_t, start_num_t, PAGE_COUNT, sortMethod];
    }
    
    NSLog(@"fetchArticleList, url:%@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self stopActivityIndicator:shouldAppendHead];
        NSArray *idList = [JSON valueForKeyPath:@"postid"];
        NSArray *metadataList = [JSON valueForKeyPath:@"metadata"];
        Posts *post = nil;
        int i, count = [idList count];
        
        NSLog(@"merge result dbPath: %@", dbPath);
        
        //NSLog(@"merge result");
        // bypass sqlite lock problem
        if (shouldAppendHead) {
            // TODO remove code duplication
            for(i=count-1; i>=0; i--) {
                //NSLog(@"fetchArticleList i:%d, id:%@, metadata:%@", i, idList[i], metadataList[i]);
                if ([Posts containId:self.objects postId:idList[i]] == NO) {
                    post = [PostsSqlite getPost:postsDB dbPath:dbPath postId:idList[i]];
                    if (post == nil) {
                        [self fetchJson:self.objects
                                 urlStr:[[urlPrefix stringByAppendingString:@"api_get_post?postid="] stringByAppendingString:idList[i]]
                       shouldAppendHead:shouldAppendHead];
                    }
                    else {
                        int index = 0;
                        if (shouldAppendHead != YES){
                            index = [self.objects count];
                        }
                        [self addToTableView:index post:post];
                    }
                }
            }
        }
        else{
            for(i=0; i<count; i++) {
                if ([Posts containId:self.objects postId:idList[i]] == NO) {
                    post = [PostsSqlite getPost:postsDB dbPath:dbPath postId:idList[i]];
                    if (post == nil) {
                        [self fetchJson:self.objects
                                 urlStr:[[urlPrefix stringByAppendingString:@"api_get_post?postid="] stringByAppendingString:idList[i]]
                       shouldAppendHead:shouldAppendHead];
                    }
                    else {
                        int index = 0;
                        if (shouldAppendHead != YES){
                            index = [self.objects count];
                        }
                        [self addToTableView:index post:post];
                    }
                }
            }
        }
        for(i=0; i<count; i++) {
            [PostsSqlite updatePostMetadata:postsDB dbPath:dbPath
                                     postId:idList[i] metadata:metadataList[i]
                                   category:self.category];
            
        }
        if (shouldAppendHead == NO) {
            self->bottom_num = 1 + self->bottom_num;
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self stopActivityIndicator:shouldAppendHead];
        [ComponentUtil infoMessage:@"Error to get specific post list"
                               msg:[NSString stringWithFormat:@"url:%@, error:%@", urlStr, error]
                     enforceMsgBox:FALSE];
    }];
    
    [operation start];
}

- (void)fetchJson:(NSMutableArray*) listObject
           urlStr:(NSString*)urlStr
 shouldAppendHead:(bool)shouldAppendHead
{
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        Posts* post = [[Posts alloc] init];
        [post setPostid:[JSON valueForKeyPath:@"id"]];
        [post setTitle:[JSON valueForKeyPath:@"title"]];
        [post setSummary:[JSON valueForKeyPath:@"summary"]];
        [post setCategory:[JSON valueForKeyPath:@"category"]];
        [post setContent:[JSON valueForKeyPath:@"content"]];
        [post setSource:[JSON valueForKeyPath:@"source"]];
        [post set_metadata:[JSON valueForKeyPath:@"metadata"]];
        [post setReadcount:[NSNumber numberWithInt:0]];
        
        if ([PostsSqlite savePost:postsDB dbPath:dbPath
                           postId:post.postid summary:post.summary category:post.category
                            title:post.title source:post.source content:post.content
                         metadata:post.metadata] == NO) {
            [ComponentUtil infoMessage:@"Error to insert post"
                                   msg:[NSString stringWithFormat:@"postid:%@, title:%@", post.postid, post.title]
                         enforceMsgBox:FALSE];
        }
        
        int index = 0;
        if (shouldAppendHead != YES){
            index = [listObject count];
        }
        [self addToTableView:index post:post];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [ComponentUtil infoMessage:@"Error to get specific post"
                               msg:[NSString stringWithFormat:@"url:%@, error:%@", urlStr, error]
                     enforceMsgBox:FALSE];
        
    }];
    
    [operation start];
}


- (void) showMenuViewController:(id)sender
{
    [self showMenuView:TRUE];
}

- (void) showMenuView:(BOOL)shouldShow
{
    SWRevealViewController* rvc = self.revealViewController;
    if (shouldShow) {
        [rvc revealToggleAnimated:YES];
    }
    else {
        [rvc rightRevealToggleAnimated:YES];
    }
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize= CGSizeMake(320.0, 600.0);
        //self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)initLocationManager
{
    /*
     locationManager = [[CLLocationManager alloc] init];
     locationManager.delegate = self;
     locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
     locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
     [locationManager startUpdatingLocation];
     */
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    int degrees = newLocation.coordinate.latitude;
    double decimal = fabs(newLocation.coordinate.latitude - degrees);
    int minutes = decimal * 60;
    double seconds = decimal * 3600 - minutes * 60;
    NSString *lat = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                     degrees, minutes, seconds];
    NSLog(@" Current Latitude : %@",lat);
    //latLabel.text = lat;
    degrees = newLocation.coordinate.longitude;
    decimal = fabs(newLocation.coordinate.longitude - degrees);
    minutes = decimal * 60;
    seconds = decimal * 3600 - minutes * 60;
    NSString *longt = [NSString stringWithFormat:@"%d° %d' %1.4f\"",
                       degrees, minutes, seconds];
    NSLog(@" Current Longitude : %@",longt);
    //longLabel.text = longt;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    [ComponentUtil updateScoreText:self.category btn:self.coinButton tag:TAG_MASTERVIEW_SCORE_TEXT];
}

-(void) rightSwipe:(UISwipeGestureRecognizer*)recognizer {
    NSString* userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"Userid"];
    
    SWRevealViewController* rvc = self.revealViewController;
    MenuViewController* menuvc = (MenuViewController*)rvc.rearViewController;
    NSLog(@"rightSwipe. rvc.frontViewPosition:%d",
          rvc.frontViewPosition);

    if (rvc.frontViewPosition == FrontViewPositionRight) // menu is shown
    {
        return;
    }
    
    NSString* new_category;
    NSMutableArray* category_list = menuvc.category_list;
    int index, count;
    count = [category_list count];
    index = [category_list indexOfObject:self.category];
    NSLog(@"index:%d", index);
    if (index == -1 || index == 0) {
        // show menu
        [self showMenuView:TRUE];
    }
    else {
        // show previous category
        new_category = [category_list objectAtIndex:(index-1)];
        [self init_data:userid category_t:new_category
              navigationTitle:[menuvc textToValue:new_category]];
    }
}

-(void) leftSwipe:(UISwipeGestureRecognizer*)recognizer {
    NSString* userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"Userid"];
    
    SWRevealViewController* rvc = self.revealViewController;
    MenuViewController* menuvc = (MenuViewController*)rvc.rearViewController;

    NSLog(@"leftSiwpe. rvc.frontViewPosition:%d", rvc.frontViewPosition);
    
    if (rvc.frontViewPosition == FrontViewPositionRight) // menu is already shown
    {
        [self showMenuView:FALSE];
    }
    else {
        NSString* new_category;
        NSMutableArray* category_list = menuvc.category_list;
        int index, count;
        count = [category_list count];
        index = [category_list indexOfObject:self.category];
        if (index < count-1) {
            // show next category
            new_category = [category_list objectAtIndex:(index+1)];
            [self init_data:userid category_t:new_category
                  navigationTitle:[menuvc textToValue:new_category]];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) barButtonEvent:(id)sender
{
    UIButton* btn = sender;
    if (btn.tag == TAG_BUTTON_COIN) {
        ReviewViewController *reviewViewController = [[ReviewViewController alloc]init];
        
        self.navigationController.navigationBarHidden = NO;
        reviewViewController.category = self.category;
        [self.navigationController pushViewController:reviewViewController animated:YES];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.navigationItem.title isEqualToString:APP_SETTING]) {
        return 2;
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ([self.navigationItem.title isEqualToString:APP_SETTING]) {
        return @" ";
    }
    else
        return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.navigationItem.title isEqualToString:APP_SETTING]) {
        if (section == 0) {
            return 4;
        }
        if (section == 1) {
            return 2;
        }
        return 0;
    }
    else
        return objects.count;
}

- (void) appSettingRows:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            aSwitch.on = YES;
            aSwitch.tag = TAG_SWITCH_HIDE_READ_POST;
            [aSwitch addTarget:self action:@selector(hideSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"Auto hide read questions";
            cell.accessoryView = aSwitch;
            if ([userDefaults integerForKey:@"HideReadPosts"] == 0) {
                aSwitch.on = false;
            }
            else {
                aSwitch.on = true;
            }
        }
        if (indexPath.row == 1) {
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            aSwitch.on = YES;
            aSwitch.tag = TAG_SWITCH_EDITOR_MODE;
            [aSwitch addTarget:self action:@selector(hideSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"Enable editor mode";
            cell.accessoryView = aSwitch;
            if ([userDefaults integerForKey:@"IsEditorMode"] == 0) {
                aSwitch.on = false;
            }
            else {
                aSwitch.on = true;
            }
        }
        if (indexPath.row == 2) {
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            aSwitch.on = YES;
            aSwitch.tag = TAG_SWITCH_DEBUG_MODE;
            [aSwitch addTarget:self action:@selector(hideSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"Show verbose errmsg";
            cell.accessoryView = aSwitch;
            if ([userDefaults integerForKey:@"IsDebugMode"] == 0) {
                aSwitch.on = false;
            }
            else {
                aSwitch.on = true;
            }
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = CLEAN_CACHE;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = FOLLOW_TWITTER;
        }
        
        if (indexPath.row == 1) {
            cell.textLabel.text = FOLLOW_MAILTO;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    cell.textLabel.font = [UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL];
    if ([self.navigationItem.title isEqualToString:APP_SETTING]) {
        [self appSettingRows:cell indexPath:indexPath];
        return cell;
    }
    else {
        Posts *post = objects[indexPath.row];
        [[cell.contentView viewWithTag:TAG_TEXTVIEW_IN_CELL]removeFromSuperview];
        [[cell.contentView viewWithTag:TAG_METADATA_IN_CELL]removeFromSuperview];
        [[cell.contentView viewWithTag:TAG_ICON_IN_CELL]removeFromSuperview];
        
        cell.textLabel.text = @"";
        
        NSString* iconPath = [ComponentUtil getLogoIcon:post.source];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconPath]];
        
        [imageView setFrame:CGRectMake(cell.frame.size.width - 75,
                                       cell.frame.size.height - 45,
                                       63.0f, 33.0f)];
        
        [imageView setTag:TAG_ICON_IN_CELL];
        imageView.userInteractionEnabled = NO;
        [[cell contentView] addSubview:imageView];
        
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
        [textView setTextColor:[UIColor blackColor]];
        [textView setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL]];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setTag:TAG_TEXTVIEW_IN_CELL];
        textView.userInteractionEnabled = NO;
        [[cell contentView] addSubview:textView];
        [textView setText:post.title];
        [textView setFrame:CGRectMake(10, 10, cell.frame.size.width - 20, cell.frame.size.height - 10)];
        
        UITextView *metadataTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        [metadataTextView setTextColor:[UIColor blackColor]];
        [metadataTextView setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_TINY]];
        [metadataTextView setBackgroundColor:[UIColor clearColor]];
        [metadataTextView setTag:TAG_METADATA_IN_CELL];
        metadataTextView.userInteractionEnabled = NO;
        [[cell contentView] addSubview:metadataTextView];
        //[metadataTextView setText:post.metadata];
        [metadataTextView setFrame:CGRectMake(10, cell.frame.size.height - 50, 100, 50)];
        
        NSString* voteupStr = [post.metadataDictionary objectForKey:@"voteup"];
        NSInteger voteup = [voteupStr intValue];
        if (voteup > 0) {
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH, ICON_HEIGHT)];
            btn.tag = TAG_VOTEUP_IN_CELL;
            [btn setImage:[UIImage imageNamed:@"thumbs_up2.png"] forState:UIControlStateNormal];
            NSString* text = voteupStr;
            [ComponentUtil addTextToButton:btn text:text
                                  fontSize:FONT_TINY2 chWidth:9 chHeight:17 tag:TAG_VOTEUP_TEXT];
            
            [metadataTextView addSubview:btn];
        }
        
        [self markCellAsRead:cell post:post];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.navigationItem.title isEqualToString:APP_SETTING]) {
        return 50.0f;
    }
    // NSString *text = @"some testxt";
    // CGSize constraint = CGSizeMake(320 - (10 * 2), 20000.0f);
    // CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_NORMAL] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    // CGFloat height = MAX(size.height, 44.0f);
    //return height + (10 * 2) + 30;
    return ROW_HEIGHT;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"He press Cancel");
    }
    else {
        NSLog(@"clean cache, dbPath:%@", dbPath);
        self->dbPath = [PostsSqlite getDBPath]; // TODO why we need this?
        [PostsSqlite openSqlite:dbPath];
        
        [PostsSqlite cleanCache:postsDB dbPath:dbPath];
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"IsEditorMode"] == 1) {
            [UserProfile cleanAllCategoryKey];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([self.navigationItem.title isEqualToString:APP_SETTING]) {
        if([cell.textLabel.text isEqualToString:CLEAN_CACHE]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Clean cache Confirmation" message: @"Are you sure to clean all cache, except favorite questions?" delegate:self  cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
            
            [alert show];
        }
        
        if([cell.textLabel.text isEqualToString:FOLLOW_MAILTO]) {
            NSString* to=@"denny.zhang001@gmail.com";
            NSString* subject=@"Feedback for CoderQuiz";
            NSString* body=@"hi CoderQuiz\n";
            NSString* mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
                                    [to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                    
                                    [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                    [body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            NSLog(@"mailstring:%@", mailString);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
        }
        
        if([cell.textLabel.text isEqualToString:FOLLOW_TWITTER]) {
            NSString* snsUserName=@"dennyzhang001";
            UIApplication *app = [UIApplication sharedApplication];
            NSURL *snsURL = [NSURL URLWithString:[NSString stringWithFormat:@"tweetie://user?screen_name=%@", snsUserName]];
            if ([app canOpenURL:snsURL])
            {
                [app openURL:snsURL];
            }
            else {
                NSString* msg=[[NSString alloc] initWithFormat:@"Follow us by \nhttp://twitter.com/%@", snsUserName];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:nil message:msg delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil, nil];
                [alert show];
                [ComponentUtil timedAlert:alert];
            }
        }
        
        return nil;
    }
    
    return indexPath;
}

- (void)markCellAsRead:(UITableViewCell *)cell post:(Posts *)post
{
    UITextView *textView = (UITextView *)[cell viewWithTag:TAG_TEXTVIEW_IN_CELL];
    if ([post.readcount intValue] !=0) {
        textView.textColor = [UIColor grayColor];
    }
    else {
        textView.textColor = [UIColor blackColor];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self.navigationItem.title isEqualToString:APP_SETTING])
        return 30;
    return 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"MasterViewController segue identifier: %@", [segue identifier]);
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSLog(@"increate visit count, for category:%@. previous key:%d", self.category,
              [UserProfile integerForKey:self.category key:POST_VISIT_KEY]);
        Posts *post = objects[indexPath.row];
        
        post.readcount = [NSNumber numberWithInt:(1+[post.readcount intValue])];
        [self markCellAsRead:cell post:post];
        if ([self.category isEqualToString:SAVED_QUESTIONS]) {
            [[segue destinationViewController] setShouldShowCoin:[NSNumber numberWithInt:0]];
        }
        else {
            [[segue destinationViewController] setShouldShowCoin:[NSNumber numberWithInt:1]];
        }
        [[segue destinationViewController] setDetailItem:post];
    }
}

- (void) hideSwitchChanged:(id)sender {
    if ([sender isKindOfClass:[UISwitch class]]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        UISwitch* switchControl = sender;
        if (switchControl.tag == TAG_SWITCH_HIDE_READ_POST) {
            if (switchControl.on == true) {
                [userDefaults setInteger:1 forKey:@"HideReadPosts"];
            }
            else {
                [userDefaults setInteger:0 forKey:@"HideReadPosts"];
            }
            [userDefaults synchronize];
        }
        if (switchControl.tag == TAG_SWITCH_EDITOR_MODE) {
            if (switchControl.on == true) {
                [userDefaults setInteger:1 forKey:@"IsEditorMode"];
            }
            else {
                [userDefaults setInteger:0 forKey:@"IsEditorMode"];
            }
            [userDefaults synchronize];
        }
        if (switchControl.tag == TAG_SWITCH_DEBUG_MODE) {
            if (switchControl.on == true) {
                [userDefaults setInteger:1 forKey:@"IsDebugMode"];
            }
            else {
                [userDefaults setInteger:0 forKey:@"IsDebugMode"];
            }
            [userDefaults synchronize];
        }
    }
}

-(void)initTableIndicatorView
{
    // headerView
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 10.0)];
    UIActivityIndicatorView * actIndHeader = [[UIActivityIndicatorView alloc]
                                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actIndHeader.tag = TAG_TABLE_HEADER_INDIACTOR;
    actIndHeader.frame = CGRectMake(150.0, 5.0, 20.0, 10.0);
    
    actIndHeader.hidesWhenStopped = YES;
    
    [headerView addSubview:actIndHeader];
    
    self.tableView.tableHeaderView = headerView;
    
    // footerView
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
    
    UIActivityIndicatorView * actIndFooter = [[UIActivityIndicatorView alloc]
                                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actIndFooter.tag = TAG_TABLE_FOOTER_INDIACTOR;
    actIndFooter.frame = CGRectMake(150.0, 5.0, 20.0, 20.0);
    
    actIndFooter.hidesWhenStopped = YES;
    
    [footerView addSubview:actIndFooter];
    self.tableView.tableFooterView = footerView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self.navigationItem.title isEqualToString:APP_SETTING] ||
        [self.navigationItem.title isEqualToString:SAVED_QUESTIONS])
        return;
    // when reach the top
    if (scrollView.contentOffset.y <= 0)
    {
        [(UIActivityIndicatorView *)[headerView viewWithTag:TAG_TABLE_HEADER_INDIACTOR] startAnimating];
    }
    
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        [(UIActivityIndicatorView *)[footerView viewWithTag:TAG_TABLE_FOOTER_INDIACTOR] startAnimating];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.navigationItem.title isEqualToString:APP_SETTING] ||
        [self.navigationItem.title isEqualToString:SAVED_QUESTIONS])
        return;
    
    // when reach the top
    if (scrollView.contentOffset.y <= 0)
    {
        [self refreshTableHead];
    }
    
    // when reaching the bottom
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        [self refreshTableTail];
    }
}

- (void)addCompoents
{
    // show image
    UIImage *image = [UIImage imageNamed: @"dot1.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];

    // label
    UILabel *tmpTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    
    tmpTitleLabel.text = @"Mannschaft";
    tmpTitleLabel.backgroundColor = [UIColor clearColor];
    tmpTitleLabel.textColor = [UIColor whiteColor];
    
    UIView* newView = [[UIView alloc] initWithFrame:CGRectZero];

    [newView addSubview:imageView];
    [newView addSubview:tmpTitleLabel];
    self.navigationItem.titleView = newView;
    newView.frame = CGRectMake(0, 0, 100,
                               self.navigationController.navigationBar.frame.size.height);
    tmpTitleLabel.frame = CGRectMake(0, 0, 100, 35);
    imageView.frame = CGRectMake(30, 15, 35, 35);
    
    self.titleLabel = tmpTitleLabel;

    // set header of navigation bar
    UIButton* btn;
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    
    [self.tableView setRowHeight:ROW_HEIGHT];
    UINavigationBar* appearance = self.navigationController.navigationBar;
    
    appearance.tintColor = [UIColor whiteColor];
    [appearance setBackgroundImage:[UIImage imageNamed:@"navigation_header.png"] forBarMetrics:UIBarMetricsDefault];
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor whiteColor],
                                               NSForegroundColorAttributeName,
                                               [UIFont fontWithName:FONT_NAME1 size:FONT_BIG],
                                               NSFontAttributeName,
                                               nil];
    [appearance setTitleTextAttributes:navbarTitleTextAttributes];


    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (self.category == nil) {
        NSString* categoryList = [userDefaults stringForKey:@"CategoryList"];
        NSArray *stringArray = [categoryList componentsSeparatedByString: @","];
        NSString* default_category = stringArray[0];
        default_category = [default_category stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString* userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"Userid"];
        [self init_data:userid category_t:default_category navigationTitle:default_category];
    }
    if (!([self.category isEqualToString:NONE_QUESTION_CATEGORY] || [self.category isEqualToString:SAVED_QUESTIONS])) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH, ICON_HEIGHT)];
        [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = TAG_BUTTON_COIN;
        [btn setImage:[UIImage imageNamed:@"coin.png"] forState:UIControlStateNormal];
        self.coinButton = btn;
        NSInteger score = [UserProfile scoreByCategory:self.category];
        [ComponentUtil addTextToButton:btn text:[NSString stringWithFormat: @"%d", (int)score]
                              fontSize:FONT_TINY2 chWidth:ICON_CHWIDTH chHeight:ICON_CHHEIGHT tag:TAG_MASTERVIEW_SCORE_TEXT];
        UIBarButtonItem *coinButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:coinButton, nil];
    }

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH_SMALL, ICON_HEIGHT_SMALL)];
    [btn addTarget:self action:@selector(showMenuViewController:)
  forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.leftBarButtonItem = settingButton;

}

@end
