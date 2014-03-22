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

#import "constants.h"

#import <CoreFoundation/CFUUID.h>

@interface MasterViewController () {
    NSMutableArray *_objects;
    sqlite3 *postsDB;
    NSString *databasePath;
    NSUserDefaults *userDefaults;
    NSNumber *bottom_num;
    NSNumber *page_count;
}

@end

@implementation MasterViewController

@synthesize locationManager, topic, username, bottom_num, page_count;

- (void)viewDidLoad
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_header.png"] forBarMetrics:UIBarMetricsDefault];
    
    [super viewDidLoad];
    UINavigationBar* appearance = self.navigationController.navigationBar;
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor blackColor],
                                               NSForegroundColorAttributeName,
                                               [UIFont fontWithName:FONT_NAME1 size:FONT_BIG],
                                               NSFontAttributeName,
                                               nil];
    [appearance setTitleTextAttributes:navbarTitleTextAttributes];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"concept,cloud,security,algorithm,product,linux" forKey:@"TopicList"];
    
    if ([[userDefaults stringForKey:@"SortMethod"] isEqualToString:@""]) {
        [userDefaults setObject:@"hotest" forKey:@"SortMethod"];
    }
    
    [Posts getCategoryList:userDefaults];
    
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                      target:self.revealViewController
                                      action:@selector(revealToggle:)];
    self.navigationItem.leftBarButtonItem = settingButton;
    
    if (self.topic == nil) {
        NSString* topicList = [userDefaults stringForKey:@"TopicList"];
        NSArray *stringArray = [topicList componentsSeparatedByString: @","];
        NSString* default_topic = stringArray[0];
        default_topic = [default_topic stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self init_data:@"denny" topic_t:default_topic];
    }
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

- (void)init_data:(NSString*)username_t
          topic_t:(NSString*)topic_t
{
    self.topic=topic_t;
    self.navigationItem.title = self.topic;
    
    if ([topic_t isEqualToString:MORE_TOPICS]) {
        return;
    }
    
    if ([topic_t isEqualToString:APP_SETTING]) {
        return;
    }
    
    self.bottom_num = [NSNumber numberWithInt:20];
    self.page_count = [NSNumber numberWithInt:10];
    
    self.username=username_t;
    
    _objects = [[NSMutableArray alloc] init];
    
    [self openSqlite];
    userDefaults = [NSUserDefaults standardUserDefaults];
    [PostsSqlite loadPosts:postsDB dbPath:databasePath topic:self.topic
                   objects:_objects hideReadPosts:[userDefaults integerForKey:@"HideReadPosts"] tableview:self.tableView];
    
    [self fetchArticleList:username topic_t:topic_t
                 start_num:[NSNumber numberWithInt: 10]
                     count:self.page_count
          shouldAppendHead:YES]; // TODO
    
}

- (void)openSqlite
{
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc]
                    initWithString: [docsDir stringByAppendingPathComponent:
                                     @"posts.db"]];
    
    //NSFileManager *filemgr = [NSFileManager defaultManager];
    
    //if ([filemgr fileExistsAtPath: databasePath ] == NO)
    if ([PostsSqlite initDB:postsDB dbPath:databasePath] == NO) {
        NSLog(@"Error: Failed to open/create database");
    }
}

- (void)fetchArticleList:(NSString*) userid
                 topic_t:(NSString*)topic_t
               start_num:(NSNumber*)start_num
                   count:(NSNumber*)count
        shouldAppendHead:(bool)shouldAppendHead
{
    if ([self.topic isEqualToString:SAVED_POSTS])
        return;
    
    NSString *urlPrefix=SERVERURL;
    // TODO: voteup defined by users
    NSString *urlStr= [NSString stringWithFormat: @"%@api_list_posts_in_topic?uid=%@&topic=%@&start_num=%d&count=%d&voteup=%d&votedown=0",
                       urlPrefix, userid, topic_t, [start_num intValue], [count intValue], 0];
    NSLog(@"fetchArticleList, url:%@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSMutableArray *idMArray;
        NSArray *idList = [JSON valueForKeyPath:@"id"];
        idMArray = [idMArray initWithArray:idList];
        Posts *post = nil;
        NSUInteger i, count = [idList count];
        // bypass sqlite lock problem
        for(i=0; i<count; i++) {
            if ([Posts containId:_objects postId:idList[i]] == NO) {
                post = [PostsSqlite getPost:postsDB dbPath:databasePath postId:idList[i]];
                if (post == nil) {
                    [self fetchJson:_objects
                             urlStr:[[urlPrefix stringByAppendingString:@"api_get_post?id="] stringByAppendingString:idList[i]]
                   shouldAppendHead:shouldAppendHead];
                }
                else {
                    int index = 0;
                    if (shouldAppendHead != YES){
                        index = [_objects count];
                    }
                    [self addToTableView:index marray:_objects object:post];
                }
            }
        }
        if (shouldAppendHead == NO) {
            self.bottom_num = [NSNumber numberWithInt: [self.page_count intValue] + [self.bottom_num intValue]];
            //NSLog(@"should change here");
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error to fetch url: %@. error: %@", urlStr, error);
    }];
    
    [operation start];
}

- (bool)addToTableView:(int)index
                marray:(NSMutableArray *)marray
                object:(Posts*)object
{
    NSInteger myInteger = [userDefaults integerForKey:@"HideReadPosts"];
    if (myInteger == 1) {
        if (object.readcount.intValue !=0 )
            return YES;
    }
    
    bool ret = YES;
    [marray insertObject:object atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    return ret;
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
        [post setReadcount:[NSNumber numberWithInt:0]];
        
        if ([PostsSqlite savePost:postsDB dbPath:databasePath
                           postId:post.postid summary:post.summary category:post.category
                            title:post.title source:post.source content:post.content] == NO) {
            NSLog(@"Error: insert posts. id:%@, title:%@", post.postid, post.title);
        }
        
        int index = 0;
        if (shouldAppendHead != YES){
            index = [listObject count];
        }
        [self addToTableView:index marray:listObject object:post];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error to fetch url: %@. error: %@", urlStr, error);
    }];
    
    [operation start];
    // [operation setSuccessCallbackQueue:backgroundQueue];
    //[[myAFAPIClient sharedClient].operationQueue addOperation:operation];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingArticle:(id)sender
{
    /*
     NSBundle *bundle = [NSBundle mainBundle];
     NSString *plistPath = [bundle pathForResource:@"statedictionary" ofType:@"plist"];
     
     NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
     
     CLLocationManager *locationManager = [[CLLocationManager alloc] init];
     locationManager.delegate = self;
     locationManager.desiredAccuracy = kCLLocationAccuracyBest;
     
     [locationManager startUpdatingLocation];
     NSLog(@"%1f", locationManager.location.coordinate.longitude);
     */
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.topic isEqualToString:APP_SETTING]) {
        return 7;
    }
    else
        return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL]];
    if ([self.topic isEqualToString:APP_SETTING]) {
        if (indexPath.row == 0) {
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            aSwitch.on = YES;
            aSwitch.tag = TAG_SWITCH_HIDE_READ_POST;
            [aSwitch addTarget:self action:@selector(hideSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"Auto hide read posts";
            cell.accessoryView = aSwitch;
            if ([userDefaults integerForKey:@"HideReadPosts"] == 0) {
                aSwitch.on = false;
            }
            else {
                aSwitch.on = true;
            }
        }
        if (indexPath.row == 1) {
            CGRect aframe = CGRectMake(0,0,40,40);
            UIButton* button = [[UIButton alloc] initWithFrame:aframe];
            UIImage *selectedImage = [UIImage imageNamed:@"hearts-512.png"];
            UIImage *unselectedImage = [UIImage imageNamed:@"heart-512.png"];
            
            [button setImage:unselectedImage forState:UIControlStateNormal];
            [button setImage:selectedImage forState:UIControlStateSelected];
            [button addTarget:self
                       action:@selector(hideSwitchChanged:)
             forControlEvents:UIControlEventTouchUpInside];
            cell.textLabel.text = @"How posts are sorted";
            button.selected = YES;
            button.tag = TAG_SWITCH_SORT_METHOD;
            
            cell.accessoryView = button;
            // if ([[userDefaults stringForKey:@"SortMethod"] isEqualToString:@"hotest"]) {
            //     button.enabled = true;
            // }
            // else {
            //     button.enabled = false;
            // }
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = CLEAN_CACHE;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (indexPath.row == 3) {
            self.serverUITextField.text = @"hello";
            [cell.contentView addSubview:self.serverUITextField];
            cell.textLabel.text = @"Server IP:";
            cell.accessoryView = self.serverUITextField;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (indexPath.row == 4) {
            cell.textLabel.text = FOLLOW_TWITTER;
        }
        
        if (indexPath.row == 5) {
            cell.textLabel.text = FOLLOW_WEIBO;
        }

        if (indexPath.row == 6) {
            cell.textLabel.text = FOLLOW_MAILTO;
        }
        
        return cell;
    }
    else {
        Posts *post = _objects[indexPath.row];
        [[cell.contentView viewWithTag:TAG_TEXTVIEW_IN_CELL]removeFromSuperview];
        
        UITextView *textView = nil;
        cell.textLabel.text = @"";
        
        textView = [[UITextView alloc] initWithFrame:CGRectZero];
        [textView setTextColor:[UIColor blackColor]];
        [textView setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL]];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setTag:TAG_TEXTVIEW_IN_CELL];
        [textView setEditable:NO];
        textView.selectable = NO;
        textView.scrollEnabled = NO;
        textView.userInteractionEnabled = NO;
        [[cell contentView] addSubview:textView];
        
        NSString *text = post.title;
        CGSize constraint = CGSizeMake(320 - (10 * 2), 99999.0f);
        CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_NORMAL] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        if (!textView)
            textView = (UITextView *)[cell viewWithTag:TAG_TEXTVIEW_IN_CELL];
        [textView setText:text];
        [textView setFrame:CGRectMake(10, 10, 320 - (10 * 2), MAX(size.height, 44.0f))];
        
        [self markCellAsRead:cell post:post];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.topic isEqualToString:APP_SETTING]) {
        return 50.0f;
    }
    NSString *text = @"some testxt";
    CGSize constraint = CGSizeMake(320 - (10 * 2), 20000.0f);
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:FONT_NORMAL] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat height = MAX(size.height, 44.0f);
    //return height + (10 * 2);
    return height + (10 * 2) + 30;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if ([self.topic isEqualToString:APP_SETTING]){
        if([cell.textLabel.text isEqualToString:CLEAN_CACHE]) {
            [self openSqlite];
            [PostsSqlite cleanCache:postsDB dbPath:databasePath];
            
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"All local cache are clean."
                                  message:@""
                                  delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil, nil];
            [alert show];
        }
        if([cell.textLabel.text isEqualToString:FOLLOW_WEIBO]) {
            NSString* snsUserName=@"dennyzhang001";
            UIApplication *app = [UIApplication sharedApplication];
            NSURL *snsURL = [NSURL URLWithString:[NSString stringWithFormat:@"weibo://weibo.com/%@", snsUserName]];
            if ([app canOpenURL:snsURL])
            {
            	[app openURL:snsURL];
            }
            else {
                NSString* msg=[[NSString alloc] initWithFormat:@"Follow us by \nhttp://weibo.com/%@", snsUserName];
                UIAlertView *alert = [[UIAlertView alloc]
                                       initWithTitle:msg message:@"" delegate:self
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil, nil];
                [alert show];
            
            }
        }
        
        if([cell.textLabel.text isEqualToString:FOLLOW_MAILTO]) {
            NSString* to=@"denny.zhang001@gmail.com";
            NSString* subject=@"Feedback for CoderPuzzle";
            NSString* body=@"hi CoderPuzzle\n";
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
                                      initWithTitle:msg message:@"" delegate:self
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil, nil];
                [alert show];
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
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // when reach the top
    if (scrollView.contentOffset.y == 0)
    {
        NSLog(@"top is reached");
        [self fetchArticleList:username topic_t:self.topic
                     start_num:[NSNumber numberWithInt:0]
                         count:self.page_count
              shouldAppendHead:YES]; // TODO
    }
    
    // when reaching the bottom
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        NSLog(@"bottom is reached");
        [self fetchArticleList:username topic_t:self.topic
                     start_num:self.bottom_num count:self.page_count
              shouldAppendHead:NO]; // TODO
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue identifier: %@", [segue identifier]);
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        Posts *post = _objects[indexPath.row];
        
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        NSString* uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL,uuidRef));
        
        CFRelease(uuidRef);
        
        // Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        // [mixpanel track:@"Article Open" properties:@{
        //     @"DeviceId":uuidString,
        //       @"Postid": post.postid
        //       }];
        
        post.readcount = [NSNumber numberWithInt:(1+[post.readcount intValue])];
        [self markCellAsRead:cell post:post];
        [PostsSqlite addPostReadCount:postsDB dbPath:databasePath
                               postId:post.postid topic:post.category];
        
        [[segue destinationViewController] setDetailItem:post];
    }
}

- (void) hideSwitchChanged:(id)sender {
    if ([sender isKindOfClass:[UISwitch class]]) {
        UISwitch* switchControl = sender;
        if (switchControl.tag == TAG_SWITCH_HIDE_READ_POST) {
            if (switchControl.on == true) {
                [userDefaults setInteger:1 forKey:@"HideReadPosts"];
            }
            else {
                [userDefaults setInteger:0 forKey:@"HideReadPosts"];
            }
            [userDefaults synchronize];
            NSLog(@"HideReadPosts:%d", [userDefaults integerForKey:@"HideReadPosts"]);
        }
    }
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton* button = sender;
        button.selected = !button.selected;
        if (button.tag == TAG_SWITCH_SORT_METHOD) {
            if (button.selected == true) {
                [userDefaults setObject:@"hotest" forKey:@"SortMethod"];
            }
            else {
                [userDefaults setObject:@"latest" forKey:@"SortMethod"];
            }
            [userDefaults synchronize];
            NSLog(@"sortMethod:%@", [userDefaults stringForKey:@"SortMethod"]);
        }
    }
}

@end
