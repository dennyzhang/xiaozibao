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
@synthesize summaryTextView, tableView;

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
   NSLog(@"numberOfRowsInSection");
   return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // return cell
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = @"question title";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)sectio {
  return 40.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *customLabel = [[UILabel alloc] init];
    customLabel.text = @" Top 10 questions from your history:";
    customLabel.textColor = [UIColor whiteColor];
    customLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"navigation_header.png"]];
    return customLabel;
}
#pragma mark - private function

- (void)addCompoents
{
    summaryTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0,
                                                                   self.view.frame.size.width,
                                                                   self.view.frame.size.height - UITABLE_HEIGHT)];
    NSString* str_topic = @"Skill Learning Review For linux";
    NSString* str_stastics = @"Questions learned: 123\nTime spent: 10 min\nFeedback count: 10 times";
    NSString* str_ranklist = @"Top active experts of this skill is XXX, XXX, ...";

    self.summaryTextView.text =  [[NSString alloc] initWithFormat:@"%@\n\n%@\n\n%@",
                                    str_topic, str_stastics, str_ranklist];
    self.summaryTextView.editable = false;
    self.summaryTextView.selectable = false;

    [self.view addSubview:summaryTextView];

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(summaryTextView.frame.size.width - 50, 10.0f, 50.0f, 50.0f)];
    [btn setImage:[UIImage imageNamed:@"coin.png"] forState:UIControlStateNormal];
    [summaryTextView addSubview:btn];

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - UITABLE_HEIGHT,
                                                                     self.view.frame.size.width,
                                                                     UITABLE_HEIGHT)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}
@end
