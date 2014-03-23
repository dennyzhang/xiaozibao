//
//  DetailViewController.m
//  MasterDetail
//
//  Created by mac on 13-7-13.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;
- (void)refreshComponentsLayout;
@end

@implementation DetailViewController
@synthesize detailItem;
@synthesize detailUITextView, imageView, titleTextView, linkTextView;


- (void)viewDidLoad
{
    //TODO define function to make code shorter
    [super viewDidLoad];

    self.detailUITextView.clipsToBounds = NO;
    self.title = @"";
    self.detailUITextView.editable = false;
    self.detailUITextView.selectable = false;

    [self addMenuCompoents];
    [self addPostHeaderCompoents];

    [self configureView];
    // hide and show navigation bar
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapRecognized:)];
    singleTap.numberOfTapsRequired = 1;
    [self.detailUITextView addGestureRecognizer:singleTap];

    // refreshComponentsLayout
    [self refreshComponentsLayout];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        NSLog(@"Portrait orientattion");
    }
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        NSLog(@"Landscape orientattion");
    }
    [self refreshComponentsLayout];
}

- (void)linkTextSingleTapRecognized:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"loading: %@", self.detailItem.source);
    [self browseWebPage:self.detailItem.source];
}

#pragma mark - Hide/Show navigationBar

- (void)singleTapRecognized:(UIGestureRecognizer *)gestureRecognizer {
    NSLog(@"single tap");
    if (self.navigationController.navigationBarHidden == YES) {
        self.navigationController.navigationBarHidden = NO;
    }
    else{
        self.navigationController.navigationBarHidden = YES;
    }
}

// - (void)scrollViewDidScroll:(UIScrollView *)scrollView
// {
//      //NSLog(@"scrollViewDidScroll");
//      if (self.navigationController.navigationBarHidden == NO) {
//        self.navigationController.navigationBarHidden = YES;
//      }
// }

// - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
// {
//     NSLog(@"Finished scrolling");
//     self.navigationController.navigationBarHidden = NO; 
// }

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{   
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}    

#pragma mark - user defined event selectors
- (void)forwardPost:(id)sender
{
    NSLog(@"forwardPost");
}

- (void)commentPost:(id)sender
{
    NSLog(@"commentPost");
}

- (void)moreAction:(id)sender
{
    NSLog(@"moreAction");
}

- (void)savePostAsFavorite:(id)sender
{
    NSLog(@"add to favorite");
    UIButton *btn= (UIButton*)sender;

    // TODO: call below, only if the async request is done correctly
    detailItem.issaved = ! detailItem.issaved;
    
    if (detailItem.issaved == YES) {
        [btn setImage:[UIImage imageNamed:@"hearts-512.png"] forState:UIControlStateNormal];
    }
    else {
        [btn setImage:[UIImage imageNamed:@"heart-512.png"] forState:UIControlStateNormal];
    }

    // TODO remove code duplication
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(
                                                   NSDocumentDirectory, NSUserDomainMask, YES);
    
    docsDir = [dirPaths objectAtIndex:0];
    
    sqlite3 *postsDB;
    NSString *databasePath = [[NSString alloc]
                               initWithString: [docsDir stringByAppendingPathComponent:
                                                          @"posts.db"]];

    //if ([filemgr fileExistsAtPath: databasePath ] == NO)
    if ([PostsSqlite initDB:postsDB dbPath:databasePath] == NO) {
        NSLog(@"Error: Failed to open/create database");
    }

    [PostsSqlite updatePostIssaved:postsDB dbPath:databasePath
                           postId:detailItem.postid issaved:detailItem.issaved topic:detailItem.category];

}

-(IBAction) VoteUpButton:(id)sender
{
    NSLog(@"VoteUpButton");
    
    UIButton *btn= (UIButton*)sender;

    // TODO: call below, only if the async request is done correctly    
    [btn setImage:[UIImage imageNamed:@"thumbs_up-512.png"]  forState:UIControlStateNormal];

    [Posts feedbackPost:@"denny" postid:detailItem.postid category:detailItem.category
                comment:@"tag voteup" button:btn];
}

-(IBAction) VoteDownButton:(id)sender
{
    NSLog(@"VoteDownButton");
    UIButton *btn= (UIButton*)sender;

    // TODO: call below, only if the async request is done correctly    
    [btn setImage:[UIImage imageNamed:@"thumbs_down-512.png"]  forState:UIControlStateNormal];

    [Posts feedbackPost:@"denny" postid:detailItem.postid category:detailItem.category
                comment:@"tag votedown" button:btn];
  
}

#pragma mark - Private functions
- (void)setDetailItem:(Posts*)newDetailItem
{
    if (detailItem != newDetailItem) {
        detailItem = newDetailItem;
        // Update the view.
        [self configureView];
    }
    
    NSLog(@"self.masterPopoverController: %@", self.masterPopoverController);
    if (self.masterPopoverController != nil) {
        
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        // TODO: here
      self.detailUITextView.text = [[NSString alloc] initWithFormat:@"\n\n\n\n%@ ", self.detailItem.content];
      self.titleTextView.text = self.detailItem.title;
      self.linkTextView.text =  [[NSString alloc] initWithFormat:@"Link %@ ", self.detailItem.source];
    }
}

- (void)addMenuCompoents
{
    UIButton *btn;

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 33.0f)];
    [btn addTarget:self action:@selector(VoteUpButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"thumb_up-512.png"] forState:UIControlStateNormal];
    UIBarButtonItem *voteUpButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 33.0f)];
    [btn addTarget:self action:@selector(VoteDownButton:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"thumb_down-512.png"] forState:UIControlStateNormal];
    UIBarButtonItem *voteDownButton = [[UIBarButtonItem alloc] initWithCustomView:btn];

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 33.0f)];
    [btn addTarget:self action:@selector(savePostAsFavorite:) forControlEvents:UIControlEventTouchUpInside];
    if (detailItem.issaved == YES) {
      [btn setImage:[UIImage imageNamed:@"hearts-512.png"] forState:UIControlStateNormal];
    }
    else {
      [btn setImage:[UIImage imageNamed:@"heart-512.png"] forState:UIControlStateNormal];
    }
    UIBarButtonItem *saveFavoriteButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 33.0f)];
    [btn addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"more-512.png"] forState:UIControlStateNormal];
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithCustomView:btn];

    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 33.0f)];
    [btn addTarget:self action:@selector(commentPost:) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"comments-512.png"] forState:UIControlStateNormal];
    UIBarButtonItem *commentButton = [[UIBarButtonItem alloc] initWithCustomView:btn];

    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                      target:self
                                      action:@selector(forwardPost:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:moreButton, saveFavoriteButton, voteDownButton, voteUpButton, nil];
}

- (void)addPostHeaderCompoents
{
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header.png"]];

    [self.imageView setFrame:CGRectZero];
    [self.detailUITextView addSubview:self.imageView];

    self.titleTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.titleTextView.editable = NO;
    self.titleTextView.backgroundColor = NULL;
    [self.titleTextView setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL]];
    [self.detailUITextView addSubview:self.titleTextView];

    self.linkTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.linkTextView.editable = NO;
    self.linkTextView.backgroundColor = NULL;

    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkTextSingleTapRecognized:)];
    singleTap.numberOfTapsRequired = 1;
    [self.linkTextView addGestureRecognizer:singleTap];


    [self.detailUITextView addSubview:self.linkTextView];

    self.detailUITextView.scrollEnabled = YES;
    self.detailUITextView.dataDetectorTypes = UIDataDetectorTypeLink;
    self.detailUITextView.delegate = self;
}

- (void)refreshComponentsLayout
{

    // self.detailUITextView.frame =  CGRectMake(100, 100, 500.0f, 150.0f);

    // NSLog(@"x:%f, y:%f", self.detailUITextView.frame.origin.x, self.detailUITextView.frame.origin.y);
    // NSLog(@"width1:%f, width2:%f", self.detailUITextView.frame.size.width, self.view.frame.size.width);
    // NSLog(@"height1:%f, height2:%f", self.detailUITextView.frame.size.height, self.view.frame.size.height);

    // //self.detailUITextView.frame.origin.x,
    // self.detailUITextView.frame = CGRectMake(100,
    //                                          100,
    //                                          self.view.frame.size.width - 30,
    //                                          self.detailUITextView.frame.size.height);
    // NSLog(@"x:%f, y:%f", self.detailUITextView.frame.origin.x, self.detailUITextView.frame.origin.y);
    // NSLog(@"width1:%f, width2:%f", self.detailUITextView.frame.size.width, self.view.frame.size.width);
    
    CGFloat width = self.detailUITextView.frame.size.width;
    self.imageView.frame =  CGRectMake(0.0f, 0.0f, width, 200.0f);
    self.titleTextView.frame =  CGRectMake(20, 20, 280, 80);
    self.linkTextView.frame =  CGRectMake(width - 220.0f, 140, 200, 60);
}

- (void)browseWebPage:(NSString*)url
{
    UIViewController *webViewController = [[UIViewController alloc]init];
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0,0,320,480)];
    webView.scalesPageToFit= YES;
    NSURL *nsurl = [NSURL URLWithString:url];

    NSURLRequest *nsrequest = [NSURLRequest requestWithURL:nsurl];
    [webView loadRequest:nsrequest];
    [webViewController.view addSubview:webView];
    [self.navigationController pushViewController:webViewController  animated:YES];
}
@end
