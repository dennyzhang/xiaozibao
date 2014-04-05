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

@interface DetailViewController () {
  NSTimeInterval startTime;
  sqlite3 *postsDB;
  NSString *dbPath;
}
- (void)configureView;
- (void)refreshComponentsLayout;
@end

@implementation DetailViewController
@synthesize detailItem;
@synthesize detailUITextView, imageView, titleTextView, linkTextView;
@synthesize coinButton, shouldShowCoin, contentPrefix;

- (void)viewDidLoad
{
    [super viewDidLoad];
    dbPath = [PostsSqlite getDBPath];
    postsDB = [PostsSqlite openSqlite:dbPath];

    UIBarButtonItem* barButtonItem = self.navigationItem.leftBarButtonItem;
    [barButtonItem setTarget: self];
    [barButtonItem setAction: @selector( test: )];
    
    NSLog(@"self.detailItem.readcount: %d", [self.detailItem.readcount intValue]);
    if ([self.detailItem.readcount intValue] == 1){
      [UserProfile addInteger:self.detailItem.category key:POST_VISIT_KEY offset:1];
    }
    // update readcount
    self.detailItem.readcount = [NSNumber numberWithInt:(1+[self.detailItem.readcount intValue])];

    [PostsSqlite addPostReadCount:postsDB dbPath:dbPath
                           postId:self.detailItem.postid category:self.detailItem.category];

    contentPrefix = @"\n\n\n\n\n\n\n"; // TODO workaround
    if (!self.detailUITextView) {
      NSLog(@"here!");
      self.detailUITextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                                           self.view.frame.size.height)];
      contentPrefix = @"\n\n\n\n\n\n\n\n\n\n"; // TODO workaround
      [self.view addSubview:self.detailUITextView];
    }
    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    self.detailUITextView.clipsToBounds = NO;
    self.detailUITextView.backgroundColor = [UIColor clearColor];
    [self.detailUITextView setFont:[UIFont fontWithName:FONT_NAME_CONTENT size:FONT_NORMAL]];
    self.title = @"";
    self.detailUITextView.editable = false;
    self.detailUITextView.selectable = false;
    // TODO, when jump to webView, the bottom doesn't look natural
    //self.detailUITextView.frame =  CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
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

#pragma mark - user defined event selectors
-(IBAction) barButtonEvent:(id)sender
{
    UIButton* btn = sender;
    if (btn.tag == TAG_BUTTON_COIN_DETAILVIEW) {
        ReviewViewController *reviewViewController = [[ReviewViewController alloc]init];
    
        self.navigationController.navigationBarHidden = NO;
        reviewViewController.category = self.detailItem.category;
        [self.navigationController pushViewController:reviewViewController animated:YES];
    }
    
    if (btn.tag == TAG_BUTTON_VOTEUP || btn.tag == TAG_BUTTON_VOTEDOWN || btn.tag == TAG_BUTTON_FAVORITE) {
        // mark locally, then send request to remote server
        NSString* imgName = @"";
        NSString* fieldName = @"";
        BOOL boolValue = false;
        if (btn.tag == TAG_BUTTON_VOTEUP) {
            // exclusive check
            if ((detailItem.isvoteup == FALSE) && (detailItem.isvotedown == TRUE)) {
                NSString* msg = @"You can only either voteup or votedown the same post.";
                [ComponentUtil infoMessage:nil msg:msg enforceMsgBox:TRUE];
                return;
            }

            imgName = (detailItem.isvoteup == NO)?@"thumbs_up-512.png":@"thumb_up-512.png";
            detailItem.isvoteup = !detailItem.isvoteup;
            fieldName = @"isvoteup";
            boolValue = detailItem.isvoteup;
            NSLog(@"detailItem.isvoteup:%d, imgName:%@", detailItem.isvoteup, imgName);
            if (boolValue) {
              [UserProfile addInteger:self.detailItem.category key:POST_VOTEUP_KEY offset:1];
            }
            else {
              [UserProfile addInteger:self.detailItem.category key:POST_VOTEUP_KEY offset:-1];
            }
        }
        if (btn.tag == TAG_BUTTON_VOTEDOWN) {
            // exclusive check
            if ((detailItem.isvotedown == FALSE) && (detailItem.isvoteup == TRUE)) {
                NSString* msg = @"You can only either voteup or votedown the same post.";
                [ComponentUtil infoMessage:nil msg:msg enforceMsgBox:TRUE];
                return;
            }

            imgName = (detailItem.isvotedown == NO)?@"thumbs_down-512.png":@"thumb_down-512.png";
            detailItem.isvotedown = !detailItem.isvotedown;
            fieldName = @"isvotedown";
            boolValue = detailItem.isvotedown;
            if (boolValue) {
              [UserProfile addInteger:self.detailItem.category key:POST_VOTEDOWN_KEY offset:1];
            }
            else {
              [UserProfile addInteger:self.detailItem.category key:POST_VOTEDOWN_KEY offset:-1];
            }
        }
        if (btn.tag == TAG_BUTTON_FAVORITE) {
            imgName = (detailItem.isfavorite == NO)?@"hearts-512.png":@"heart-512.png";
            detailItem.isfavorite = ! detailItem.isfavorite;
            fieldName = @"isfavorite";
            boolValue = detailItem.isfavorite;
            if (boolValue) {
              [UserProfile addInteger:self.detailItem.category key:POST_FAVORITE_KEY offset:1];
            }
            else {
              [UserProfile addInteger:self.detailItem.category key:POST_FAVORITE_KEY offset:-1];
            }
        }
        
        [PostsSqlite updatePostBoolField:postsDB dbPath:dbPath
                                  postId:detailItem.postid boolValue:boolValue
                               fieldName:fieldName category:detailItem.category];
        [btn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        
        NSString* userid = [[NSUserDefaults standardUserDefaults] stringForKey:@"Userid"];
        NSLog(@"userid:%@", userid);
        [self feedbackPost:userid
                    postid:detailItem.postid
                  category:detailItem.category btn:btn
                   postsDB:postsDB dbPath:dbPath];

        // tell client where to find favorite questions
        if (btn.tag == TAG_BUTTON_FAVORITE) {
            NSString* msg = @"Save the question to as favorite.\nSee: Preference --> Saved questions";
            if (detailItem.isfavorite == NO) {
                msg = @"Unsave the question";
            }
            [ComponentUtil infoMessage:nil msg:msg enforceMsgBox:TRUE];
        }

    }
    [ComponentUtil updateScoreText:self.detailItem.category btn:self.coinButton tag:TAG_SCORE_TEXT];
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
        comment = @"tag envoteup" ;
    }
    if (btn.tag == TAG_BUTTON_VOTEDOWN) {
        comment = @"tag envotedown" ;
    }
    if (btn.tag == TAG_BUTTON_FAVORITE) {
        comment = @"tag enfavorite" ;
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
        //[self configureView];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailUITextView.text = [self getContent:self.detailItem.content];
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
    [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH, ICON_HEIGHT)];
    [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = TAG_BUTTON_VOTEUP;
    if (detailItem.isvoteup == YES) {
        [btn setImage:[UIImage imageNamed:@"thumbs_up-512.png"] forState:UIControlStateNormal];
    }
    else {
        [btn setImage:[UIImage imageNamed:@"thumb_up-512.png"] forState:UIControlStateNormal];
    }
    UIBarButtonItem *voteUpBarButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH, ICON_HEIGHT)];
    [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = TAG_BUTTON_VOTEDOWN;
    if (detailItem.isvotedown == YES) {
        [btn setImage:[UIImage imageNamed:@"thumbs_down-512.png"] forState:UIControlStateNormal];
    }
    else {
        [btn setImage:[UIImage imageNamed:@"thumb_down-512.png"] forState:UIControlStateNormal];
    }
    UIBarButtonItem *voteDownBarButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH_SMALL, ICON_HEIGHT_SMALL)];
    [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = TAG_BUTTON_FAVORITE;
    if (detailItem.isfavorite == YES) {
        [btn setImage:[UIImage imageNamed:@"hearts-512.png"] forState:UIControlStateNormal];
    }
    else {
        [btn setImage:[UIImage imageNamed:@"heart-512.png"] forState:UIControlStateNormal];
    }
    UIBarButtonItem *saveFavoriteBarButton = [[UIBarButtonItem alloc] initWithCustomView:btn];

    if ([self.shouldShowCoin intValue] == 1) {
      btn = [UIButton buttonWithType:UIButtonTypeCustom];
      [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH, ICON_HEIGHT)];
      [btn addTarget:self action:@selector(barButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
      btn.tag = TAG_BUTTON_COIN_DETAILVIEW;
      [btn setImage:[UIImage imageNamed:@"coin.png"] forState:UIControlStateNormal];
      self.coinButton = btn;
      NSInteger score = [UserProfile scoreByCategory:self.detailItem.category];
      [ComponentUtil addTextToButton:btn text:[NSString stringWithFormat: @"%d", (int)score]
                            fontSize:FONT_TINY2 chWidth:ICON_CHWIDTH chHeight:ICON_CHHEIGHT tag:TAG_SCORE_TEXT];

      UIBarButtonItem* coinBarButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
      self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:coinBarButton, saveFavoriteBarButton, voteDownBarButton, voteUpBarButton, nil];
    }
    else {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:saveFavoriteBarButton, voteDownBarButton, voteUpBarButton, nil];
    }
}

- (void)addPostHeaderCompoents
{
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header.png"]];
    
    [self.imageView setFrame:CGRectZero];
    [self.detailUITextView addSubview:self.imageView];
    
    self.titleTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    self.titleTextView.editable = NO;
    self.titleTextView.backgroundColor = [UIColor clearColor];
    [self.titleTextView setFont:[UIFont fontWithName:FONT_NAME_TITLE size:FONT_SIZE_TITLE]];
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
    self.detailUITextView.selectable = NO;

    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(textWithSwipe:)];
    [self.view addGestureRecognizer:swipe];
    swipe.delegate = self;
}

- (void)refreshComponentsLayout
{
    CGFloat width = self.detailUITextView.frame.size.width;
    //CGFloat height = self.detailUITextView.frame.size.height;
    self.imageView.frame =  CGRectMake(0.0f, 0.0f, width, 200.0f);
    self.titleTextView.frame =  CGRectMake(10, 10, width - 20, 100);
    self.linkTextView.frame =  CGRectMake(width - 200,
                                          self.imageView.frame.size.height - 40,
                                          200, 40);
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

-(IBAction) test:(id)sender
{
  NSLog(@"test");
}

-(NSString*) getContent:(NSString*) content
{
  NSString* ret;
  if ([content length] > MAX_POST_CONTENT){
    // ret = [NSString stringWithFormat:@"%@%@... ...", contentPrefix,
    //                 [content substringWithRange:NSMakeRange(0, MAX_POST_CONTENT)]];
    ret = [NSString stringWithFormat:@"%@%@", contentPrefix, content];
  }
  else {
    ret = [NSString stringWithFormat:@"%@%@", contentPrefix, content];
  }
  return ret;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear");
    [ComponentUtil updateScoreText:self.detailItem.category btn:self.coinButton tag:TAG_SCORE_TEXT];

    startTime = [NSDate timeIntervalSinceReferenceDate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    int seconds = (int)ceilf([NSDate timeIntervalSinceReferenceDate] - startTime);
    
    if (seconds > MAX_SECONDS_FOR_VALID_STAY) {
      NSLog(@"Skip caculating: stay in the post for %d, which is over %d seconds",
            seconds, MAX_SECONDS_FOR_VALID_STAY);
    }
    else {
      NSLog(@"Stay for ove %d seconds", seconds);
      [UserProfile addInteger:self.detailItem.category key:POST_STAY_SECONDS_KEY offset:seconds];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGesture
{
    return YES;
}

-(void) textWithSwipe:(UISwipeGestureRecognizer*)recognizer {
    if (recognizer.direction == UISwipeGestureRecognizerDirectionRight){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
