//
//  MasterViewController.m
//  MasterDetail
//
//  Created by mac on 13-7-13.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "AFJSONRequestOperation.h"

@interface MasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation MasterViewController
@synthesize locationManager;

- (void)fetchArticleList:(NSString*) userid
              topic:(NSString*)topic
{
    //NSURL *url = [NSURL URLWithString:@"http://httpbin.org/ip"];

    //NSString *urlPrefix=@"http://173.255.227.47:9080/";
    //NSString *urlPrefix=@"http://127.0.0.1:9080/";
    NSString *urlPrefix=@"http://192.168.100.101:9080/";
    NSString *urlStr= [urlPrefix stringByAppendingString:@"api_list_user_topic?uid=denny&topic=idea_startup&offset=10&count=20"];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        NSMutableArray *idMArray;
        NSArray *idList = [JSON valueForKeyPath:@"id"];
        idMArray = [idMArray initWithArray:idList];
        
        NSUInteger i, count = [idList count];
        for(i=0; i<count; i++) {
            NSLog(@"%@", [[urlPrefix stringByAppendingString:@"api_get_post?id="] stringByAppendingString:idList[i]]);
            [self fetchJson:_objects urlStr:[[urlPrefix stringByAppendingString:@"api_get_post?id="] stringByAppendingString:idList[i]]];
        }
    
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", error);
        NSLog(@"%@", urlStr);
        NSLog(@"error");
    }];
    
    [operation start];
}

- (void)fetchJson:(NSMutableArray*) listObject
              urlStr:(NSString*)urlStr
{
    //NSURL *url = [NSURL URLWithString:@"http://httpbin.org/ip"];

    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [listObject insertObject:[JSON valueForKeyPath:@"content"] atIndex:0];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"%@", error);
        NSLog(@"%@", urlStr);
        NSLog(@"error");
    }];
    
    [operation start];
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.title = @"Ideas";
    
    // UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(hideArticle:)];    
    // self.navigationItem.leftBarButtonItem = hideButton;

    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(settingArticle:)];
    self.navigationItem.rightBarButtonItem = settingButton;

    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    _objects = [[NSMutableArray alloc] init];

    [self fetchArticleList:@"denny" topic:@"topic"]; // TODO
    [self initLocationManager];
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
    
    NSLog(@"%@", dict);

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

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
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
        NSString *data = _objects[indexPath.row];

        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.textLabel.textColor = [UIColor grayColor];
        
        //NSLog(@"%@", data);
        [[segue destinationViewController] setDetailItem:data];
    }
}

@end
