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
     // add summaryTextView
    summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];

    [self.summaryTextView setUserInteractionEnabled:NO];
    self.summaryTextView.backgroundColor = [UIColor clearColor];
    [self.summaryTextView setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL]];
    [self.view addSubview:summaryTextView];

     // create summaryTextView's subview components
    float imageWidth = 75.0f;
    float imageHeight = 75.0f;
    float verticalDistance = 35.0f;
    float horizonDistance = 28.0f;
    float textHeight = 35.0f;
    UITextView* titleTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    UIImageView *figureImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"figure.png"]]; // TODO

    UIImageView *clockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hourglass.png"]];
    UITextView* clockTextView = [[UITextView alloc] initWithFrame:CGRectZero];

    UIImageView *questionsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"question.png"]];
    UITextView* questionsTextView = [[UITextView alloc] initWithFrame:CGRectZero];

    UIImageView *feedbackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feedback.png"]];
    UITextView* feedbackTextView = [[UITextView alloc] initWithFrame:CGRectZero];

    NSMutableAttributedString *attString1;
    NSMutableAttributedString *attString2;

    NSString *text1;
    NSString *text2;

    titleTextView.backgroundColor = [UIColor clearColor];
    [titleTextView setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL]];

    // configure attributedString
    text1 = @"Learning Review: ";
    text2 = self.category;
    attString1 = [[NSMutableAttributedString alloc] initWithString:text1];
    attString2 = [[NSMutableAttributedString alloc] initWithString:text2];
    
    [attString1 addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:FONT_NORMAL]
                       range:NSMakeRange (0, [text1 length])];
    
    [attString2 addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}
                range:NSMakeRange (0, [text2 length])];
    [attString2 addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:FONT_BIG]
                       range:NSMakeRange (0, [text2 length])];

    [attString1 insertAttributedString:attString2 atIndex:[text1 length]];
    titleTextView.attributedText = attString1;
    
    // clock
    clockTextView.backgroundColor = [UIColor clearColor];
    text1 = [NSString stringWithFormat: @"%d",
                      [UserProfile integerForKey:self.category key:POST_VISIT_KEY]];
    text2 = @"minutes spent";
    attString1 = [[NSMutableAttributedString alloc] initWithString:text1];
    attString2 = [[NSMutableAttributedString alloc] initWithString:text2];
    
    [attString1 addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}
                range:NSMakeRange (0, [text1 length])];
    [attString1 addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:FONT_NORMAL]
                       range:NSMakeRange (0, [text1 length])];
    
    [attString2 addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:FONT_TINY2]
                       range:NSMakeRange (0, [text2 length])];
    [attString1 insertAttributedString:attString2 atIndex:[text1 length]];
    clockTextView.attributedText = attString1;

    // questions
    questionsTextView.backgroundColor = [UIColor clearColor];
    text1 = [NSString stringWithFormat: @"%d",
                      [UserProfile integerForKey:self.category key:POST_VISIT_KEY]];
    text2 = @"questions learned";
    attString1 = [[NSMutableAttributedString alloc] initWithString:text1];
    attString2 = [[NSMutableAttributedString alloc] initWithString:text2];
    
    [attString1 addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}
                range:NSMakeRange (0, [text1 length])];
    [attString1 addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:FONT_NORMAL]
                       range:NSMakeRange (0, [text1 length])];
    
    [attString2 addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:FONT_TINY2]
                       range:NSMakeRange (0, [text2 length])];
    [attString1 insertAttributedString:attString2 atIndex:[text1 length]];
    questionsTextView.attributedText = attString1;

    // feedback
    feedbackTextView.backgroundColor = [UIColor clearColor];
    text1 = [NSString stringWithFormat: @"%d",
                      [UserProfile integerForKey:self.category key:POST_VOTEUP_KEY]
                     +[UserProfile integerForKey:self.category key:POST_VOTEDOWN_KEY]
                     +[UserProfile integerForKey:self.category key:POST_FAVORITE_KEY]
             ];
    text2 = @"feedback contributed";
    attString1 = [[NSMutableAttributedString alloc] initWithString:text1];
    attString2 = [[NSMutableAttributedString alloc] initWithString:text2];
    
    [attString1 addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}
                range:NSMakeRange (0, [text1 length])];
    [attString1 addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:FONT_NORMAL]
                       range:NSMakeRange (0, [text1 length])];
    
    [attString2 addAttribute:NSFontAttributeName
                       value:[UIFont systemFontOfSize:FONT_TINY2]
                       range:NSMakeRange (0, [text2 length])];
    [attString1 insertAttributedString:attString2 atIndex:[text1 length]];
    feedbackTextView.attributedText = attString1;

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"coin2.png"] forState:UIControlStateNormal];
    self.coinButton = btn;

    [summaryTextView addSubview:btn];
    [summaryTextView addSubview:figureImageView];
    [summaryTextView addSubview:titleTextView];
    [summaryTextView addSubview:clockImageView];
    [summaryTextView addSubview:clockTextView];
    [summaryTextView addSubview:questionsImageView];
    [summaryTextView addSubview:questionsTextView];
    [summaryTextView addSubview:feedbackImageView];
    [summaryTextView addSubview:feedbackTextView];

    // configure frames of summaryTextView's subview components
    [btn setFrame:CGRectMake(summaryTextView.frame.size.width - 60, 50.0f, ICON_WIDTH, ICON_HEIGHT)];
    [titleTextView setFrame:CGRectMake(45, 10, self.view.frame.size.width, textHeight)];

    [figureImageView setFrame:CGRectMake(15, 10, ICON_WIDTH, ICON_HEIGHT)];
    float x=10, y = 50 + ICON_HEIGHT + verticalDistance;

    [clockImageView setFrame:CGRectMake(x, y, imageWidth, imageHeight)];
    [clockTextView setFrame:CGRectMake(x, y + imageHeight, self.view.frame.size.width, textHeight)];

    x = x + imageWidth + horizonDistance - 10; // TODO workaround
    [questionsImageView setFrame:CGRectMake(x, y, imageWidth, imageHeight)];
    [questionsTextView setFrame:CGRectMake(x, y + imageHeight, self.view.frame.size.width, textHeight)];

    x = x + imageWidth + horizonDistance;
    [feedbackImageView setFrame:CGRectMake(x, y, imageWidth, imageHeight)];
    [feedbackTextView setFrame:CGRectMake(x, y + imageHeight, self.view.frame.size.width, textHeight)];

    float summaryTextViewHeight = y + imageHeight + textHeight;
    
    summaryTextViewHeight += imageHeight; // TODO, workaround here
    
    [summaryTextView setFrame:CGRectMake(0, 0,
                                         self.view.frame.size.width,
                                          summaryTextViewHeight)];

    // add score to Coin
    NSInteger score = [UserProfile scoreByCategory:self.category];
    [ComponentUtil addTextToButton:btn text:[NSString stringWithFormat: @"%d", (int)score]
                          fontSize:FONT_TINY2 chWidth:ICON_CHWIDTH chHeight:ICON_CHHEIGHT tag:TAG_SCORE_TEXT];

    // Add tableview for questions from history
    float uitable_height = self.view.frame.size.height - summaryTextView.frame.size.height;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - uitable_height,
                                                                     self.view.frame.size.width,
                                                                     uitable_height)];
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
