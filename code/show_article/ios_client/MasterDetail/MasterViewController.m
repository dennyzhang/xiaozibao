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
#import "Mixpanel.h"
#import "Posts.h"

#import <CoreFoundation/CFUUID.h>

@interface MasterViewController () {
  NSMutableArray *_objects;
  sqlite3 *postsDB;
  NSString *databasePath;
  NSString *urlPrefix;
  NSUserDefaults *userDefaults;
  NSNumber *bottom_num;
  NSNumber *page_count;

}

@end

@implementation MasterViewController

@synthesize locationManager, topic, username, bottom_num, page_count;

- (void)viewDidLoad
{
  [super viewDidLoad];

  userDefaults = [NSUserDefaults standardUserDefaults];
 
  UIBarButtonItem *settingButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                          target:self.revealViewController
                                                          action:@selector(revealToggle:)];
  self.navigationItem.leftBarButtonItem = settingButton;

  self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

  if (self.topic == nil) {
      [self init_data:@"denny" topic_t:@"understand_us"];
  }
}

- (void) init_data:(NSString*)username_t
             topic_t:(NSString*)topic_t
{
  self.bottom_num = [NSNumber numberWithInt:20];
  self.page_count = [NSNumber numberWithInt:10];

  self.username=username_t;
  self.topic=topic_t;

  self.navigationItem.title = self.topic;

  _objects = [[NSMutableArray alloc] init];

  [self openSqlite];

  [PostsSqlite loadPosts:postsDB dbPath:databasePath topic:self.topic
                 objects:_objects tableview:self.tableView];

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
  //NSURL *url = [NSURL URLWithString:@"http://httpbin.org/ip"];

  urlPrefix=@"http://173.255.227.47:9080/";
  //urlPrefix=@"http://127.0.0.1:9080/";
  //urlPrefix=@"http://192.168.100.106:9080/";
  //urlPrefix=@"http://172.19.0.87:9080/";
  //urlPrefix=@"http://192.168.51.131:9080/";

  NSString *urlStr= [NSString stringWithFormat: @"%@api_list_user_topic?uid=%@&topic=%@&start_num=%d&count=%d",
                              urlPrefix, userid, topic_t, [start_num intValue], [count intValue]];
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
        if ([self containId:_objects postId:idList[i]] == NO) {
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
  bool ret = YES;
  [marray insertObject:object atIndex:index];
  NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
  [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

  return ret;
}

- (bool)containId:(NSMutableArray*) objects
           postId:(NSString*)postId
{
   bool ret = NO;
   NSUInteger i, count = [objects count];
   Posts* post;
   for(i=0; i<count; i++) {
       post = objects[i];
       if ([post.postid isEqualToString:postId] == 1) {
          ret = YES;
          break;
       }
   }
   return ret;
}

- (void)fetchJson:(NSMutableArray*) listObject
           urlStr:(NSString*)urlStr
           shouldAppendHead:(bool)shouldAppendHead
{
  //NSURL *url = [NSURL URLWithString:@"http://httpbin.org/ip"];

  NSURL *url = [NSURL URLWithString:urlStr];
  NSURLRequest *request = [NSURLRequest requestWithURL:url];
  //NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];

  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
      Posts* post = [[Posts alloc] init];
      [post setPostid:[JSON valueForKeyPath:@"id"]];
      [post setTitle:[JSON valueForKeyPath:@"title"]];
      [post setSummary:[JSON valueForKeyPath:@"summary"]];
      [post setCategory:[JSON valueForKeyPath:@"category"]];
      [post setContent:[JSON valueForKeyPath:@"content"]];

      if ([PostsSqlite savePost:postsDB dbPath:databasePath
                         postId:post.postid summary:post.summary category:post.category
                          title:post.title content:post.content] == NO) {
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
  //  [operation setSuccessCallbackQueue:backgroundQueue];
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

- (void) initLocationManager
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
  return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

  Posts *post = _objects[indexPath.row];

  cell.textLabel.text = post.title;
  if ([post.readcount intValue] !=0) {
      cell.textLabel.textColor = [UIColor grayColor];
  }
  else {
      cell.textLabel.textColor = [UIColor blackColor];
  }

  return cell;
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

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
// Return NO if you do not want the item to be re-orderable.
return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"segue identifier: %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Posts *post = _objects[indexPath.row];

    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    NSString* uuidString = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL,uuidRef));
        
    CFRelease(uuidRef);
        
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
    [mixpanel track:@"Article Open" properties:@{
                                                 @"DeviceId":uuidString,
                                                 @"Postid": post.postid
                                                 }];
        
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor grayColor];

    post.readcount = [NSNumber numberWithInt:(1+[post.readcount intValue])];
    [PostsSqlite addPostReadCount:postsDB dbPath:databasePath
                           postId:post.postid topic:post.category];

    [[segue destinationViewController] setDetailItem:post];
  }
}

@end
