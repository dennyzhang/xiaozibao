//
//  DetailViewController.m
//  MasterDetail
//
//  Created by mac on 13-7-13.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import "DetailViewController.h"
#import "Posts.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;

@end

@implementation DetailViewController
@synthesize detailItem;

#pragma mark - Managing the detail item

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
      self.detailUITextView.text = [[NSString alloc] initWithFormat:@"\n\n\n\n\n\n%@ ", self.detailItem.content];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailUITextView.clipsToBounds = NO;
    
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

    self.navigationItem.rightBarButtonItems =
      [NSArray arrayWithObjects:moreButton, saveFavoriteButton, voteDownButton, voteUpButton, nil];
    
    self.title = @"";
    
    self.detailUITextView.editable = false;
    self.detailUITextView.selectable = false;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comments-512.png"]];
    
    [imageView setFrame:CGRectMake(0.0f, 0.0f, 150.0f, 150.0f)];
    [self.detailUITextView addSubview:imageView];

    UITextView* linkTextView = [[UITextView alloc] initWithFrame:CGRectMake(140, 60, 200, 60)];
    if ([detailItem.source isEqualToString:@""])
        detailItem.source = @"http://www.baidu.com/1341341414";
    linkTextView.text =  [[NSString alloc] initWithFormat:@"Link %@ ", detailItem.source];
    linkTextView.dataDetectorTypes = UIDataDetectorTypeLink;
    linkTextView.editable = NO;
    linkTextView.backgroundColor = NULL;
    [self.detailUITextView addSubview:linkTextView];

    self.detailUITextView.scrollEnabled = YES;
    self.detailUITextView.dataDetectorTypes = UIDataDetectorTypeLink;
    [self configureView];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidScrollToTop");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"Finished scrolling");
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{   
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    
    self.masterPopoverController = popoverController;
}

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

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}    

@end
