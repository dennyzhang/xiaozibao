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

- (void) hideFeedback:(BOOL)shouldEnable
{
    self.votedownButton.hidden = shouldEnable;
    self.voteupButton.hidden = shouldEnable;
    self.votesubmitButton.hidden = shouldEnable;
    self.feedbackUITextField.hidden = shouldEnable;
}

-(IBAction) VoteUpButton:(id)sender 
{
    NSLog(@"Vote Up");
}

-(IBAction) VoteDownButton:(id)sender 
{
    NSLog(@"Vote Down");
}

-(IBAction) submitButton:(id)sender 
{
    self.feedbackUITextField.text = @"here";
    NSLog(@"Submit Button");
}

- (void)configureView
{
    // Update the user interface for the detail item.
    [self hideFeedback:true];
    
    if (self.detailItem) {
        self.detailUITextView.text = self.detailItem.content;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.detailUITextView.clipsToBounds = NO;
    //self.detailUITextView.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 10.0f, 0.0f, 10.0f);
    
    //self.detailUITextView.contentInset = UIEdgeInsetsMake(10.0f, 10.0f, 0.0f, 10.0f);

    [self configureView];
    
    /*
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineHeightMultiple = 50.0f;
    paragraphStyle.maximumLineHeight = 50.0f;
    paragraphStyle.minimumLineHeight = 50.0f;
    
    NSString *string = self.detailUITextView.text;
    NSDictionary *ats = @{
                          NSFontAttributeName : [UIFont fontWithName:@"DIN Medium" size:16.0f],
                          NSParagraphStyleAttributeName : paragraphStyle,
                          };
    
    self.detailUITextView.attributedText = [[NSAttributedString alloc] initWithString:string attributes:ats];
     */
    
    /*
    UIButton *favButton = [[UIButton alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"btn_loved" ofType:@"jpg"];
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
    [favButton setImage:image forState:UIControlStateNormal];

    [favButton addTarget:self action:@selector(judgePost:)
        forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *collectButton = [[UIBarButtonItem alloc]
                               initWithCustomView:favButton];
    
    */
    UIBarButtonItem *collectButton = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks
                                      target:self
                                      action:@selector(judgePost:)];
     
    
   //[collectButton setImage:[UIImage imageNamed:@"btn_loved.png"] forState:UIControlStateNormal];
    //[UIImage imageNamed:@"btn_loved.png"]

    self.navigationItem.rightBarButtonItem = collectButton;
    
    self.title = @"";
    
    self.detailUITextView.editable = false;
    self.detailUITextView.selectable = false;
    // swipe right
    UISwipeGestureRecognizer *swipeGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeGesture:)];
    [self.view addGestureRecognizer:swipeGesture];

    // swipe left
    UISwipeGestureRecognizer *swipeLeftGesture=[[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeLeftGesture:)];
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeftGesture];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)recognizer {
    [self configureView];
}

- (void)handleSwipeLeftGesture:(UISwipeGestureRecognizer *)recognizer {
    if (self.detailItem) {
        [self hideFeedback:false];
        self.detailUITextView.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{

    barButtonItem.title = NSLocalizedString(@"Master", @"Master");

    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];

    self.masterPopoverController = popoverController;
}


- (void)judgePost:(id)sender
{
    NSLog(@"add to favorite");
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}    

@end