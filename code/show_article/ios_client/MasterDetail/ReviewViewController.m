//
//  ReviewViewController.m
//  
//
//  Created by mac on 14-3-24.
//
//

#import "ReviewViewController.h"

@interface ReviewViewController ()

@end

@implementation ReviewViewController
@synthesize summaryTextView, tableView, coinButton;
@synthesize category, questions;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    // Do any additional setup after loading the view.
    [self addCompoents];
    [self addMenuCompoents];
    self.questions = [[NSMutableArray alloc] init];

    // TODO: refine later
    NSString *docsDir;
    NSArray *dirPaths;
        
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];

    sqlite3 *postsDB;
    NSString *dbPath = [[NSString alloc] initWithString:
                                           [docsDir stringByAppendingPathComponent:@"posts.db"]];
    if ([PostsSqlite initDB:postsDB dbPath:dbPath] == NO) {
      NSLog(@"Error: Failed to open/create database");
    }

    // load data
    [PostsSqlite loadRecommendPosts:postsDB dbPath:dbPath category:self.category
                   objects:self.questions tableview:self.tableView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - UITableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // return number of rows
  return questions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // return cell
    //static NSString *CellIdentifier = @"Cell";
    Posts *post = questions[indexPath.row];
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = post.title;
    cell.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectio {
  return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *customLabel = [[UILabel alloc] init];
    customLabel.text = @" Top 10 Questions By Your History";
    customLabel.textColor = [UIColor whiteColor];
    customLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_header.png"]];
    return customLabel;
}

#pragma mark - user defined event selectors
-(IBAction) barButtonEvent:(id)sender
{
  // TODO
  NSString* msg = @"Coming Soon. \nSend to twitter, weibo, etc";
  [ComponentUtil infoMessage:nil msg:msg];
}

#pragma mark - private function

- (void)addCompoents
{
    summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height - UITABLE_HEIGHT)];
    NSString* str_category = @"Skill Learning Review";
    NSString* str_stastics = [[NSString alloc] initWithFormat:@"For: %@\n - %d questions learned\n - xx min spent\n - %d feedback contributed",
                                               self.category,
                                   [UserProfile integerForKey:self.category key:POST_VISIT_KEY],
                                   [UserProfile integerForKey:self.category key:POST_VOTEUP_KEY] +
                                   [UserProfile integerForKey:self.category key:POST_VOTEDOWN_KEY] +
                                   [UserProfile integerForKey:self.category key:POST_FAVORITE_KEY]];

    //NSString* str_ranklist = @"Top active experts of this skill is XXX, XXX, ...";

    self.summaryTextView.text =  [[NSString alloc] initWithFormat:@"%@\n\n%@",
                                    str_category, str_stastics];
    [self.summaryTextView setUserInteractionEnabled:NO];
    self.summaryTextView.backgroundColor = [UIColor clearColor];
    [self.summaryTextView setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL]];
    [self.view addSubview:summaryTextView];

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(summaryTextView.frame.size.width - 50, 10.0f, 50.0f, 50.0f)];
    [btn setImage:[UIImage imageNamed:@"coin.png"] forState:UIControlStateNormal];
    self.coinButton = btn;

    NSInteger score = [UserProfile scoreByCategory:self.category];
    [ComponentUtil addTextToButton:btn text:[NSString stringWithFormat: @"%d", (int)score]
                          fontSize:FONT_TINY chWidth:10 chHeight:30 tag:TAG_SCORE_TEXT];

    [summaryTextView addSubview:btn];

    // Add tableview for questions from history
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - UITABLE_HEIGHT,
                                                                     self.view.frame.size.width,
                                                                     UITABLE_HEIGHT)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (void)addMenuCompoents
{
    //UINavigationBar* appearance = self.navigationController.navigationBar;
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH, ICON_HEIGHT)];
    [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = TAG_BUTTON_SHARE;
    [btn setImage:[UIImage imageNamed:@"share.png"] forState:UIControlStateNormal];

    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:shareButton, nil];
}

@end
