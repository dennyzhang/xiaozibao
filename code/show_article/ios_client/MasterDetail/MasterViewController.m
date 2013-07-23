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
#import "Posts.h"

@interface MasterViewController () {
  NSMutableArray *_objects;
  sqlite3 *postsDB;
  NSString *databasePath;
  NSString *urlPrefix;
  NSString *username;
  NSString *topic;
}
@end

@implementation MasterViewController
@synthesize locationManager;

- (void)viewDidLoad
{
  [super viewDidLoad];

   username = @"denny";
   topic = @"us_america";
   //topic = @"idea_startup";

  // Do any additional setup after loading the view, typically from a nib.
  self.navigationItem.title = @"Ideas";

  // UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideArticle:)];
  // self.navigationItem.leftBarButtonItem = hideButton;

  UIBarButtonItem *settingButton = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                          target:self
                                                          action:@selector(settingArticle:)];
  self.navigationItem.leftBarButtonItem = settingButton;

  self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  _objects = [[NSMutableArray alloc] init];
  [self openSqlite];

  [PostsSqlite loadPosts:postsDB dbPath:databasePath objects:_objects tableview:self.tableView];
  [self fetchArticleList:username topic:topic
               start_num:10 count:10
              shouldAppendHead:YES]; // TODO
  [self initLocationManager];
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
                   topic:(NSString*)topic
                   start_num:(NSInteger*)start_num
                   count:(NSInteger*)count
        shouldAppendHead:(bool)shouldAppendHead
{
  //NSURL *url = [NSURL URLWithString:@"http://httpbin.org/ip"];

  //urlPrefix=@"http://173.255.227.47:9080/";
  //urlPrefix=@"http://127.0.0.1:9080/";
  //urlPrefix=@"http://192.168.100.106:9080/";
  urlPrefix=@"http://192.168.51.131:9080/";

  NSString *urlStr= [NSString stringWithFormat: @"%@api_list_user_topic?uid=%@&topic=%@&start_num=%d&count=%d",
                              urlPrefix, userid, topic, start_num, count];
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
                 NSLog(@"%@", [[urlPrefix stringByAppendingString:@"api_get_post?id="] stringByAppendingString:idList[i]]);
                 [self fetchJson:_objects
                        urlStr:[[urlPrefix stringByAppendingString:@"api_get_post?id="] stringByAppendingString:idList[i]]
                shouldAppendHead:shouldAppendHead];
            }
            else {
                   NSLog(@"add to array, %@", post.postid);
                   int index = 0;
                   if (shouldAppendHead != YES){
                     index = [_objects count];
                   }
                   [_objects insertObject:post atIndex:index];
                   NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                   [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
      }

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
      NSLog(@"error to fetch url: %@. error: %@", urlStr, error);
    }];

  [operation start];
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
        NSLog([NSString stringWithFormat: @"Error: insert posts. id:%@, title:%@", post.postid, post.title]);
      }

      int index = 0;
      if (shouldAppendHead != YES){
        index = [listObject count];
      }
      [listObject insertObject:post atIndex:index];
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
      [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];

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
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
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
  NSBundle *bundle = [NSBundle mainBundle];
  NSString *plistPath = [bundle pathForResource:@"statedictionary" ofType:@"plist"];

  NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];

  CLLocationManager *locationManager = [[CLLocationManager alloc] init];
  locationManager.delegate = self;
  locationManager.desiredAccuracy = kCLLocationAccuracyBest;

  [locationManager startUpdatingLocation];
  NSLog(@"%1f", locationManager.location.coordinate.longitude);

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
       [self fetchArticleList:username topic:topic
                    start_num:0 count:10
             shouldAppendHead:YES]; // TODO
    }

    // when reaching the bottom
    if (scrollView.contentOffset.y == scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        NSLog(@"bottom is reached");
       [self fetchArticleList:username topic:topic
                    start_num:30 count:10
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
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    Posts *post = _objects[indexPath.row];

    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor grayColor];

    [[segue destinationViewController] setDetailItem:post];
  }
}

@end
