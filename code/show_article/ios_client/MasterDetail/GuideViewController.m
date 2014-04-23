//
//  GuideViewController.m
//  MasterDetail
//
//  Created by mac on 14-4-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "GuideViewController.h"

@interface GuideViewController ()
@property int mPageSize;
@property (strong, nonatomic) UIPageViewController *mPageViewController;
@property (strong, nonatomic) UIButton *btnEnter;
@end

@implementation GuideViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    return; // TODO
    // show tutorial for only once in each version
    if (![ComponentUtil shouldShowTutorial]) {
        [self performSegueWithIdentifier:@"enterMain" sender:self];
    }
    else {
        //NSLog(@"set currentTutorialVersion: %@", [ComponentUtil currentTutorialVersion]);
        [[NSUserDefaults standardUserDefaults]
         setObject:[ComponentUtil currentTutorialVersion]
         forKey:@"tutorialVersion"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"viewDidLoad");
    
    self.mPageSize = 3;
    
    // init pageViewController
    self.mPageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"guidePageViewController"];
    self.mPageViewController.dataSource = self;
    
    UIViewController *startingVC = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingVC];
    [self.mPageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
    // pageViewController setting
    self.mPageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self addChildViewController:_mPageViewController];
    [self.view addSubview:_mPageViewController.view];
    [self.mPageViewController didMoveToParentViewController:self];
    
    UIPageControl *pageControl = [UIPageControl appearanceWhenContainedIn:[self.mPageViewController class], nil];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:53.0/255 green:171.0/255 blue:1.0 alpha:1.0];
    pageControl.backgroundColor = [UIColor colorWithRed:246.0/255 green:246.0/255 blue:246.0/255 alpha:1.0];
    
    int offsetX, offsetY;
    offsetX = 320 - 55;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (screenHeight >= 568.0f) {
        // 4 inches
        offsetY = 568 - 35;
    }else{
        // 3.5 inches
        offsetY = 480 - 35;
    }
    
    self.btnEnter = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, 40, 30)];
    [self.btnEnter setImage:[UIImage imageNamed:@"enter.png" ] forState:UIControlStateNormal];
    [self.btnEnter setImage:[UIImage imageNamed:@"enter_highlighted.png"] forState:UIControlStateHighlighted];
    [self.btnEnter addTarget:self action:@selector(actionEnter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.btnEnter];
    self.btnEnter.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PageViewController
-(UIViewController *)viewControllerAtIndex:(NSUInteger )index
{
    // NSLog(@"viewControllerAtIndex: %d", index);
    if (self.mPageSize == 0) {
        return nil;
    }else{
        UIViewController *contentVC = [self.storyboard instantiateViewControllerWithIdentifier:@"pageContentViewController"];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *guideImg;
            
            float screenHeight = [UIScreen mainScreen].bounds.size.height;
            if (screenHeight >= 568.0f) {
                // 4 inch
                guideImg = @"1136_guide";
            }else{
                // 3.5 inch
                guideImg = @"960_guide";
            }
            
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.view.frame];
            [contentVC.view addSubview:imgView];
            NSString *imgName = [NSString stringWithFormat:@"%@%d.png", guideImg, index+1];
            //NSLog(@"imgName:%@", imgName);
            imgView.image = [UIImage imageNamed:imgName];
            contentVC.view.tag = index;
        });
        return contentVC;
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    self.btnEnter.hidden = YES;
    int oldViewId;
    UIViewController* uiViewController = (UIViewController*)viewController;
    oldViewId = uiViewController.view.tag;
    if (oldViewId<=0)
        return nil;
    return [self viewControllerAtIndex:oldViewId-1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    
    int oldViewId;
    UIViewController* uiViewController = (UIViewController*)viewController;
    oldViewId = uiViewController.view.tag;
    //NSLog(@"viewControllerAfterViewController: oldViewId: %d", oldViewId);
    
    if (oldViewId == self.mPageSize -1)
    {
        self.btnEnter.hidden = NO;
    }
    else
    {
        self.btnEnter.hidden = YES;
    }

    if (oldViewId >= self.mPageSize -1)
        return nil;

    return [self viewControllerAtIndex:oldViewId+1];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return self.mPageSize;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - event handler
-(void)actionEnter:(id)sender
{
    //  NSLog(@"actionEnter");
    [self performSegueWithIdentifier:@"enterMain" sender:self];
}

@end
