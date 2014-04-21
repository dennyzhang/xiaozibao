//
// MasterViewController.m
// MasterDetail
//
// Created by mac on 13-7-13.
// Copyright (c) 2013年 mac. All rights reserved.
//

#import "MasterViewController.h"
//#import "/usr/include/sqlite3.h"
#import "/usr/local/opt/sqlite/include/sqlite3.h"

#import "AFJSONRequestOperation.h"
#import "DetailViewController.h"
#import "MenuViewController.h"
#import "Posts.h"
#import "PostsSqlite.h"
#import "QCViewController.h"
#import "QuestionCategory.h"
#import "SWRevealViewController.h"
#import "MyGlobal.h"

@interface MasterViewController ()

@property int mCurrentPage;
@property int mPageSize;
@property (strong, nonatomic) UIPageViewController *mPageViewController;
@property (retain, nonatomic) IBOutlet UIButton *coinButton;
@property (nonatomic, retain) NSMutableArray *questionCategories;
@property (nonatomic, retain) NSString* currentNavigationTitle;

@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *navbarView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation MasterViewController

#pragma mark - override default_events
- (void)viewDidLoad
{
    NSLog(@"MasterViewController load");
    [super viewDidLoad];
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    [[MyToolTip singleton] reset:self.view]; // reset popTipView
    
    if([self.currentNavigationTitle isEqualToString:APP_SETTING] ||
       [self.currentNavigationTitle isEqualToString:SAVED_QUESTIONS]) {
        self.mPageSize = 1;
    }
    else {
        self.questionCategories = [[QuestionCategory singleton] getAllCategories];
        
        self.mPageSize = [self.questionCategories count];
    }
    if(!self.mCurrentPage)
        self.mCurrentPage = 0;
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self configureNavigationBar];
    [self updateNavigationIndex:self.mCurrentPage];
    
    // init pageViewController
    self.mPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"categoryPageViewController"];
    self.mPageViewController.dataSource = self;

    UIViewController *startingVC = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingVC];
    [self.mPageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // pageViewController setting
    self.mPageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self addChildViewController:_mPageViewController];
    [self.view addSubview:_mPageViewController.view];
    [self.mPageViewController didMoveToParentViewController:self];
    
    // UIPageControl *pageControl = [UIPageControl appearanceWhenContainedIn:[self.mPageViewController class], nil];
    // //pageControl.frame = CGRectMake(100, 0, 200, 40);

    // pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    // pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:53.0/255 green:171.0/255 blue:1.0 alpha:1.0];
    // pageControl.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    // //pageControl.hidesForSinglePage = YES;
    
    // ToolTip
    if (self.navigationItem.rightBarButtonItem) {
        [[MyToolTip singleton] addToolTip:self.navigationItem.rightBarButtonItem msg:@"Click coin to see learning stastics."];
    }
    [[MyToolTip singleton] addToolTip:self.navigationItem.leftBarButtonItem
                                  msg:@"Click to see more."];
    [[MyToolTip singleton] showToolTip];
    
}

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        //self.clearsSelectionOnViewWillAppear = NO; // TODO
        self.preferredContentSize= CGSizeMake(320.0, 600.0);
        //self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"MasterViewController will appear");
    [self refreshScore];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //[self.navbarView setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - private functions
- (void) showMenuViewController:(id)sender
{
    NSLog(@"showMenuViewController");
    [self showMenuView:![self isMenuShown]];
}

- (void) showMenuView:(BOOL)shouldShow
{
    SWRevealViewController* rvc = self.revealViewController;
    if (shouldShow) {
        [rvc revealToggleAnimated:YES];
        //self.questionScrollView.scrollEnabled  = NO;
    }
    else {
        [rvc rightRevealToggleAnimated:YES];
        //self.questionScrollView.scrollEnabled  = YES;
    }
}

-(IBAction) barButtonEvent:(id)sender
{
    UIButton* btn = sender;
    if (btn.tag == TAG_BUTTON_COIN) {
        ReviewViewController *reviewViewController = [[ReviewViewController alloc]init];
        QuestionCategory* qc = [self.questionCategories objectAtIndex:self.mCurrentPage];
        reviewViewController.category = qc.category;
        [self.navigationController pushViewController:reviewViewController animated:YES];
    }
}

- (void)configureNavigationBar
{
    UIButton* btn;
    // set header of navigation bar
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
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
    // configure leftBarButton
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH_SMALL, ICON_HEIGHT_SMALL)];
    [btn addTarget:self action:@selector(showMenuViewController:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"home.png"] forState:UIControlStateNormal];
    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.leftBarButtonItem = settingButton;
    
    // configure rightBarButton
    if(self.questionCategories) {
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH, ICON_HEIGHT)];
        [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = TAG_BUTTON_COIN;
        [btn setImage:[UIImage imageNamed:@"coin.png"] forState:UIControlStateNormal];
        self.coinButton = btn;
        [ComponentUtil addTextToButton:btn text:@"0"
                              fontSize:FONT_TINY2 chWidth:ICON_CHWIDTH chHeight:ICON_CHHEIGHT tag:TAG_MASTERVIEW_SCORE_TEXT];
        UIBarButtonItem *coinButtonBarItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:coinButtonBarItem, nil];
        
        [self updateNavigationIndex:self.mCurrentPage];
    }
    [self addPageControl];
}

- (void)addPageControl
{
    self.titleLabel = [[UILabel alloc] init]; 
    self.navbarView = [[UIView alloc] init];
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = self.mPageSize;
    self.pageControl.currentPage = 0;
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    [self.navbarView addSubview:self.titleLabel];
    [self.navbarView addSubview:self.pageControl];

    self.navigationItem.titleView = self.navbarView;

    // set subview width and height
    self.navbarView.frame = (CGRect){40, 0, self.view.frame.size.width - 80, 64};
    self.titleLabel.frame = (CGRect){0, 0, 100, 40};

    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:FONT_NAVIGATIONBAR];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.pageControl.frame = (CGRect){0, 0, 0, 0};
    
    // place subview in center
    CGPoint navbarCenter = [self.navbarView convertPoint:self.navbarView.center
                                                fromView:self.navbarView.superview];
    self.titleLabel.center = navbarCenter;
    self.pageControl.center = navbarCenter;

    //align vertical
    self.titleLabel.frame =  (CGRect){self.titleLabel.frame.origin.x, 4,
                self.titleLabel.frame.size.width, 
                self.titleLabel.frame.size.height};
    
    self.pageControl.frame =  (CGRect){self.pageControl.frame.origin.x,
                self.navbarView.frame.size.height - 19,
                self.pageControl.frame.size.width, 
                self.pageControl.frame.size.height};
}

-(UIViewController *)viewControllerAtIndex:(NSUInteger )index
{
    NSLog(@"viewControllerAtIndex index:%d", index);
    if (self.mPageSize == 0) {
        return nil;
    }else{
        QCViewController *contentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"qcViewController"];
        if([self.currentNavigationTitle isEqualToString:APP_SETTING] ||
           [self.currentNavigationTitle isEqualToString:SAVED_QUESTIONS]) {
            [contentVC init_data:nil navigationTitle:self.currentNavigationTitle];
        }
        else {
            QuestionCategory* qc = [self.questionCategories objectAtIndex:index];
            [contentVC init_data:qc navigationTitle:qc.category];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            contentVC.view.tag = index;
        });
        return contentVC;
    }
}

- (BOOL) isMenuShown
{
    SWRevealViewController* rvc = self.revealViewController;
    return (rvc.frontViewPosition == FrontViewPositionRight);
}

#pragma mark - pageViewController delegates

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (self.mCurrentPage <= 0) {
        return nil;
    }else{
        [self updateNavigationIndex:(viewController.view.tag - 1)];
        return [self viewControllerAtIndex:self.mCurrentPage];
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if (self.mCurrentPage >= self.mPageSize - 1) {
        return nil;
    }else{
        [self updateNavigationIndex:(viewController.view.tag + 1)];
        return [self viewControllerAtIndex:self.mCurrentPage];
    }
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.mPageSize;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

- (void) updateNavigationTitle:(NSString*) navigationTitle
{
    
    if([navigationTitle isEqualToString:APP_SETTING] ||
       [navigationTitle isEqualToString:SAVED_QUESTIONS]) {
        self.currentNavigationTitle = navigationTitle;
        self.navigationItem.title = self.currentNavigationTitle;
    }
    else {
        self.currentNavigationTitle = [navigationTitle lowercaseString];
        int index = [ComponentUtil getIndexByCategory:self.currentNavigationTitle];
        [self updateNavigationIndex:index];
    }
}

- (void) updateNavigationIndex:(int) index
{
    NSLog(@"updateNavigationTitle index:%d", index);
    // TODO index = (index+count) mod index
    int count = [self.questionCategories count];
    if(index<0)
        index = index + count;
    if(index>=count)
        index = index -count;
    
    self.mCurrentPage = index;
    
    if(index<0 || index>=[self.questionCategories count]) {
        NSLog(@"errror, invalid index:%d", index);
        return;
    }
    
    if (self.questionCategories) {
        QuestionCategory* qc = [self.questionCategories objectAtIndex:self.mCurrentPage];
        self.navigationItem.title = [qc.category capitalizedString];
        self.titleLabel.text = [qc.category capitalizedString];
        self.pageControl.currentPage = self.mCurrentPage;
    }
    [self refreshScore];
}

-(void)refreshScore
{
    if (self.questionCategories) {
        QuestionCategory* qc = [self.questionCategories objectAtIndex:self.mCurrentPage];
        [ComponentUtil updateScoreText:qc.category btn:self.coinButton tag:TAG_MASTERVIEW_SCORE_TEXT];
    }
}

@end
