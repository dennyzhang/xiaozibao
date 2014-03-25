//
//  DetailViewController.m
//  MasterDetail
//
//  Created by mac on 13-7-13.
//  Copyright (c) 2013年 mac. All rights reserved.
//

#import "DetailViewController.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

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
    [super viewDidLoad];

    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;

    self.detailUITextView.clipsToBounds = NO;
    self.detailUITextView.backgroundColor = [UIColor clearColor];
    self.title = @"";
    self.detailUITextView.editable = false;
    self.detailUITextView.selectable = false;
    // TODO, when jump to webView, the bottom doesn't look natural
    self.titleTextView.frame =  CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
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
-(IBAction) barButtonEvent:(id)sender
{
    UIButton* btn = sender;
    if (btn.tag == TAG_BUTTON_COIN) {
        ReviewViewController *reviewViewController = [[ReviewViewController alloc]init];
    
        self.navigationController.navigationBarHidden = NO;
        reviewViewController.category = self.detailItem.category;
        //[self.navigationController.navigationItem setTitle:@"hello"];
        //self.navigationController.navigationBar.topItem.title = @"Your Title";

        [self.navigationController pushViewController:reviewViewController animated:YES];
    }
    
    if (btn.tag == TAG_BUTTON_VOTEUP || btn.tag == TAG_BUTTON_VOTEDOWN || btn.tag == TAG_BUTTON_FAVORITE) {
        // TODO remove code duplication
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
        // mark locally, then send request to remote server
        NSString* imgName = @"";
        NSString* fieldName = @"";
        BOOL boolValue = false;
        if (btn.tag == TAG_BUTTON_VOTEUP) {
            [UserProfile incInteger:self.detailItem.category key:POST_VOTEUP_KEY];
            imgName = (detailItem.isvoteup == NO)?@"thumbs_up-512.png":@"thumb_up-512.png";
            detailItem.isvoteup = !detailItem.isvoteup;
            fieldName = @"isvoteup";
            boolValue = detailItem.isvoteup;
            NSLog(@"detailItem.isvoteup:%d, imgName:%@", detailItem.isvoteup, imgName);
        }
        if (btn.tag == TAG_BUTTON_VOTEDOWN) {
            [UserProfile incInteger:self.detailItem.category key:POST_VOTEDOWN_KEY];
            imgName = (detailItem.isvotedown == NO)?@"thumbs_down-512.png":@"thumb_down-512.png";
            detailItem.isvotedown = !detailItem.isvotedown;
            fieldName = @"isvotedown";
            boolValue = detailItem.isvotedown;
        }
        if (btn.tag == TAG_BUTTON_FAVORITE) {
            [UserProfile incInteger:self.detailItem.category key:POST_FAVORITE_KEY];
            imgName = (detailItem.isfavorite == NO)?@"hearts-512.png":@"heart-512.png";
            detailItem.isfavorite = ! detailItem.isfavorite;
            fieldName = @"isfavorite";
            boolValue = detailItem.isfavorite;
        }
        
        [PostsSqlite updatePostBoolField:postsDB dbPath:dbPath
                                  postId:detailItem.postid boolValue:boolValue
                               fieldName:@"isvoteup" topic:detailItem.category];
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        
        if (btn.tag == TAG_BUTTON_VOTEUP || btn.tag == TAG_BUTTON_VOTEDOWN) {
            NSString* userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"Userid"];
            NSLog(@"userid:%@", userid);
            [self feedbackPost:userid
                        postid:detailItem.postid
                      category:detailItem.category btn:btn
                       postsDB:postsDB dbPath:dbPath];
        }
        if (btn.tag == TAG_BUTTON_FAVORITE) {
            NSString* msg = @"Mark as favorite.\nSee: Preference --> Favorite questions";
            if (detailItem.isfavorite == NO) {
                msg = @"Unmark as favorite";
            }
            [Posts infoMessage:nil msg:msg];
        }
    }
    
}

- (void) feedbackPost:(NSString*) userid
               postid:(NSString*) postid
             category:(NSString*) category
                  btn:(UIButton *) btn
              postsDB:(sqlite3 *)postsDB
               dbPath:(NSString *) dbPath
{
    NSString *urlStr=SERVERURL;
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSString* comment = INVALID_STRING;
    if (btn.tag == TAG_BUTTON_VOTEUP) {
        comment = @"tag voteup" ;
    }
    if (btn.tag == TAG_BUTTON_VOTEDOWN) {
        comment = @"tag votedown" ;
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            userid, @"uid", postid, @"postid",
                            category, @"category", comment, @"comment",
                            nil];
    NSLog(@"feedbackPost, url:%@, postid:%@, comment:%@", urlStr, postid, comment);
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    NSURLRequest *request = [client requestWithMethod:@"POST" path:@"api_feedback_post" parameters:params];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSString *status = [JSON valueForKeyPath:@"status"];
        if ([status isEqualToString:@"ok"]) {
            NSLog(@"perform operation after success");
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:
                                  [JSON valueForKeyPath:@"errmsg"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error to fetch url: %@. error: %@", urlStr, error);
    }];
    [operation start];
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
        NSString* shortUrl = [self shortUrl:self.detailItem.source];
        NSString* prefix = @"Link:  ";
        NSString* url =  [[NSString alloc] initWithFormat:@"%@%@", prefix, shortUrl];
        
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc]
                                                initWithString:url];
        
        [attString addAttributes:@{NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)}
                           range:NSMakeRange ([prefix length], [shortUrl length])];
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor]
                          range:NSMakeRange ([prefix length], [shortUrl length])];
        self.linkTextView.attributedText = attString;
    }
}

- (void)addMenuCompoents
{
    UIButton *btn;
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 33.0f)];
    [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = TAG_BUTTON_VOTEUP;
    if (detailItem.isvoteup == YES) {
        [btn setImage:[UIImage imageNamed:@"thumbs_up-512.png"] forState:UIControlStateNormal];
    }
    else {
        [btn setImage:[UIImage imageNamed:@"thumb_up-512.png"] forState:UIControlStateNormal];
    }
    UIBarButtonItem *voteUpButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 33.0f)];
    [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = TAG_BUTTON_VOTEDOWN;
    if (detailItem.isvotedown == YES) {
        [btn setImage:[UIImage imageNamed:@"thumbs_down-512.png"] forState:UIControlStateNormal];
    }
    else {
        [btn setImage:[UIImage imageNamed:@"thumb_down-512.png"] forState:UIControlStateNormal];
    }
    UIBarButtonItem *voteDownButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 33.0f)];
    [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = TAG_BUTTON_FAVORITE;
    if (detailItem.isfavorite == YES) {
        [btn setImage:[UIImage imageNamed:@"hearts-512.png"] forState:UIControlStateNormal];
    }
    else {
        [btn setImage:[UIImage imageNamed:@"heart-512.png"] forState:UIControlStateNormal];
    }
    UIBarButtonItem *saveFavoriteButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 33.0f)];
    [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = TAG_BUTTON_MORE;
    [btn setImage:[UIImage imageNamed:@"more-512.png"] forState:UIControlStateNormal];
    UIBarButtonItem *moreButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 22.0f, 33.0f)];
    [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = TAG_BUTTON_COMMENT;
    [btn setImage:[UIImage imageNamed:@"comments-512.png"] forState:UIControlStateNormal];
    UIBarButtonItem *commentButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, 33.0f, 33.0f)];
    [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = TAG_BUTTON_COIN;
    [btn setImage:[UIImage imageNamed:@"coin.png"] forState:UIControlStateNormal];

    NSInteger score = [UserProfile scoreByCategory:self.detailItem.category];
    [ReviewViewController addScoreToButton:btn score:score fontSize:FONT_TINY chWidth:9 chHeight:25];

    UIBarButtonItem *coinButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:coinButton, saveFavoriteButton, voteDownButton, voteUpButton, nil];
}

- (void)addPostHeaderCompoents
{
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header.png"]];
    
    [self.imageView setFrame:CGRectZero];
    [self.detailUITextView addSubview:self.imageView];
    
    self.titleTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.titleTextView.editable = NO;
    self.titleTextView.backgroundColor = [UIColor clearColor];
    [self.titleTextView setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL]];
    [self.detailUITextView addSubview:self.titleTextView];
    
    self.linkTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.linkTextView.editable = NO;
    self.linkTextView.textColor = [UIColor greenColor];
    
    self.linkTextView.backgroundColor = [UIColor clearColor];
    self.linkTextView.dataDetectorTypes = UIDataDetectorTypeNone;
    
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
    self.linkTextView.frame =  CGRectMake(width - 200, 140, 200, 60);
}

- (void)browseWebPage:(NSString*)url
{
    UIViewController *webViewController = [[UIViewController alloc]init];
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0,0,
                                                                    self.view.frame.size.width,
                                                                    self.view.frame.size.height
                                                                    + self.navigationController.navigationBar.frame.size.height
                                                                    + 20)];
    
    self.navigationController.navigationBarHidden = NO;
    webView.scalesPageToFit= YES;
    NSURL *nsurl = [NSURL URLWithString:url];
    
    NSURLRequest *nsrequest = [NSURLRequest requestWithURL:nsurl];
    [webView loadRequest:nsrequest];
    [webViewController.view addSubview:webView];
    [self.navigationController pushViewController:webViewController  animated:YES];
}

- (NSString*)shortUrl:(NSString*) url
{
    if ([url isEqualToString:@""]) {
        return @"";
    }
    int max_len = 25;
    NSString* ret = [url substringToIndex:max_len];
    ret = [ret stringByAppendingString:@"..." ];
    return ret;
}

@end
