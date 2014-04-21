//
//  QCViewController.m
//  MasterDetail
//
//  Created by mac on 14-4-20.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "QCViewController.h"
#import "AFJSONRequestOperation.h"
#import "DetailViewController.h"

@interface QCViewController () {
    sqlite3 *postsDB;
    NSString *dbPath;
    UIView* footerView;
    UIView* headerView;
    int bottom_num;
}

@property (atomic, retain) QuestionCategory *currentQC;
@property (nonatomic, retain) NSString* navigationTitle;

@end

@implementation QCViewController

- (void) init_data:(QuestionCategory *)qc
   navigationTitle:(NSString*)navigationTitle_t
{
   NSLog(@"QCViewController init_data");
  self.currentQC = qc;
  self.navigationTitle = navigationTitle_t;
}

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
    NSLog(@"QCViewController viewDidLoad");
    [super viewDidLoad];

    self.view.backgroundColor = DEFAULT_BACKGROUND_COLOR;

    self->dbPath = [MyGlobal singleton].dbPath;
    //NSLog(@"self->postsDB:%@, self->dbPath:%@", self->postsDB, self->dbPath);

    if (self.currentQC) {
      [self.currentQC loadPosts:self->postsDB dbPath:self->dbPath];

      // init table indicator
      [self initTableIndicatorView];

    }

    NSLog(@"QCViewController viewDidLoad. current category:%@, currentQC questions count:%d",
          self.currentQC.category, [self.currentQC.questions count]);

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

#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self.navigationTitle isEqualToString:APP_SETTING]) {
        return 2;
    }
    
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if ([self.navigationTitle isEqualToString:APP_SETTING]) {
        return @" ";
    }
    else
        return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.navigationTitle isEqualToString:APP_SETTING]) {
        if (section == 0) {
            return 5;
        }
        if (section == 1) {
            return 2;
        }
        return 0;
    }
    else
      return [self.currentQC.questions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    cell.textLabel.font = [UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL];
    if ([self.navigationTitle isEqualToString:APP_SETTING]) {
        [self appSettingRows:cell indexPath:indexPath];
        return cell;
    }
    else {
        if (indexPath.row> [self.currentQC.questions count]) { // TODO
            NSLog(@"Error cellForRowAtIndexPath. indexPath.row:%d, questions count:%d",
                  indexPath.row, [self.currentQC.questions count]);
            return nil;
        }
        Posts *post = self.currentQC.questions[indexPath.row];
        [[cell.contentView viewWithTag:TAG_TEXTVIEW_IN_CELL]removeFromSuperview];
        [[cell.contentView viewWithTag:TAG_METADATA_IN_CELL]removeFromSuperview];
        [[cell.contentView viewWithTag:TAG_ICON_IN_CELL]removeFromSuperview];
        
        cell.textLabel.text = @"";
        
        NSString* iconPath = [ComponentUtil getLogoIcon:post.source];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconPath]];
        
        [imageView setFrame:CGRectMake(cell.frame.size.width - 75,
                                       cell.frame.size.height - 45,
                                       63.0f, 33.0f)];
        
        [imageView setTag:TAG_ICON_IN_CELL];
        imageView.userInteractionEnabled = NO;
        [[cell contentView] addSubview:imageView];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectZero];
        [textView setTextColor:[UIColor blackColor]];
        [textView setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL]];
        [textView setBackgroundColor:[UIColor clearColor]];
        [textView setTag:TAG_TEXTVIEW_IN_CELL];
        textView.userInteractionEnabled = NO;
        [[cell contentView] addSubview:textView];
        [textView setText:post.title];
        [textView setFrame:CGRectMake(10, 10, cell.frame.size.width - 20, cell.frame.size.height - 10)];
        
        UITextView *metadataTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        [metadataTextView setTextColor:[UIColor blackColor]];
        [metadataTextView setFont:[UIFont fontWithName:FONT_NAME1 size:FONT_TINY]];
        [metadataTextView setBackgroundColor:[UIColor clearColor]];
        [metadataTextView setTag:TAG_METADATA_IN_CELL];
        metadataTextView.userInteractionEnabled = NO;
        [[cell contentView] addSubview:metadataTextView];
        //[metadataTextView setText:post.metadata];
        [metadataTextView setFrame:CGRectMake(10, cell.frame.size.height - 50, 100, 50)];
        
        NSString* voteupStr = [post.metadataDictionary objectForKey:@"voteup"];
        NSInteger voteup = [voteupStr intValue];
        if (voteup > 0) {
            UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:CGRectMake(0.0f, 0.0f, ICON_WIDTH, ICON_HEIGHT)];
            btn.tag = TAG_VOTEUP_IN_CELL;
            [btn setImage:[UIImage imageNamed:@"thumbs_up2.png"] forState:UIControlStateNormal];
            NSString* text = voteupStr;
            [ComponentUtil addTextToButton:btn text:text
                                  fontSize:FONT_TINY2 chWidth:9 chHeight:17 tag:TAG_VOTEUP_TEXT];
            
            [metadataTextView addSubview:btn];
        }
        
        [self markCellAsRead:cell post:post];
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.navigationTitle isEqualToString:APP_SETTING]) {
        return 50.0f;
    }
    return ROW_HEIGHT;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        NSLog(@"He press Cancel");
    }
    else {
        NSLog(@"clean cache, dbPath:%@", dbPath);
        self->dbPath = [MyGlobal singleton].dbPath; // TODO why we need this?
        [PostsSqlite openSqlite:dbPath];
        
        [PostsSqlite cleanCache:self->postsDB dbPath:self->dbPath];
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"IsEditorMode"] == 1) {
            [UserProfile cleanAllCategoryKey];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([self.navigationTitle isEqualToString:APP_SETTING]) {
        if([cell.textLabel.text isEqualToString:CLEAN_CACHE]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Clean cache Confirmation" message: @"Are you sure to clean all cache, except favorite questions?" delegate:self  cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
            
            [alert show];
        }
        
        if([cell.textLabel.text isEqualToString:FOLLOW_MAILTO]) {
            NSString* to=@"denny.zhang001@gmail.com";
            NSString* subject=@"Feedback for CoderQuiz";
            NSString* body=@"hi CoderQuiz\n";
            NSString* mailString = [NSString stringWithFormat:@"mailto:?to=%@&subject=%@&body=%@",
                                    [to stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                    
                                    [subject stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding],
                                    [body stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            NSLog(@"mailstring:%@", mailString);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailString]];
        }
        
        if([cell.textLabel.text isEqualToString:FOLLOW_TWITTER]) {
            NSString* snsUserName=@"dennyzhang001";
            UIApplication *app = [UIApplication sharedApplication];
            NSURL *snsURL = [NSURL URLWithString:[NSString stringWithFormat:@"tweetie://user?screen_name=%@", snsUserName]];
            if ([app canOpenURL:snsURL])
            {
                [app openURL:snsURL];
            }
            else {
                NSString* msg=[[NSString alloc] initWithFormat:@"Follow us by \nhttp://twitter.com/%@", snsUserName];
                UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:nil message:msg delegate:self
                                      cancelButtonTitle:nil
                                      otherButtonTitles:nil, nil];
                [alert show];
                [ComponentUtil timedAlert:alert];
            }
        }
        
        return nil;
    }
    
    return indexPath;
}

- (void)markCellAsRead:(UITableViewCell *)cell post:(Posts *)post
{
    UITextView *textView = (UITextView *)[cell viewWithTag:TAG_TEXTVIEW_IN_CELL];
    if ([post.readcount intValue] !=0) {
        textView.textColor = [UIColor grayColor];
    }
    else {
        textView.textColor = [UIColor blackColor];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if ([self.navigationTitle isEqualToString:APP_SETTING])
        return 30;
    return 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"MasterViewController segue identifier: %@", [segue identifier]);
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSLog(@"increate visit count, for category:%@. previous key:%d", self.currentQC.category,
              [UserProfile integerForKey:self.currentQC.category key:POST_VISIT_KEY]);
        Posts *post = self.currentQC.questions[indexPath.row];
        
        post.readcount = [NSNumber numberWithInt:(1+[post.readcount intValue])];

        DetailViewController* dvc = [segue destinationViewController];
        if ([self.currentQC.category isEqualToString:SAVED_QUESTIONS]) {
            [dvc setShouldShowCoin:[NSNumber numberWithInt:0]];
        }
        else {
            [dvc setShouldShowCoin:[NSNumber numberWithInt:1]];
        }
        dvc.detailItem = post;
        [self markCellAsRead:cell post:post];
    }
}

- (void) hideSwitchChanged:(id)sender {
    if ([sender isKindOfClass:[UISwitch class]]) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        UISwitch* switchControl = sender;
        if (switchControl.tag == TAG_SWITCH_HIDE_READ_POST) {
            [QuestionCategory clearIsLoaded];
            [userDefaults setInteger:(int)switchControl.on forKey:@"HideReadPosts"];
            [userDefaults synchronize];
        }
        if (switchControl.tag == TAG_SWITCH_EDITOR_MODE) {
            [userDefaults setInteger:(int)switchControl.on forKey:@"IsEditorMode"];
            [userDefaults synchronize];
        }
        if (switchControl.tag == TAG_SWITCH_DEBUG_MODE) {
          [userDefaults setInteger:(int)switchControl.on forKey:@"IsDebugMode"];
          [userDefaults synchronize];
        }
    }
}


- (void) appSettingRows:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            aSwitch.on = YES;
            aSwitch.tag = TAG_SWITCH_HIDE_READ_POST;
            [aSwitch addTarget:self action:@selector(hideSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"Auto hide read questions";
            cell.accessoryView = aSwitch;
            if ([userDefaults integerForKey:@"HideReadPosts"] == 0) {
                aSwitch.on = false;
            }
            else {
                aSwitch.on = true;
            }
        }
        if (indexPath.row == 1) {
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            aSwitch.on = YES;
            aSwitch.tag = TAG_SWITCH_EDITOR_MODE;
            [aSwitch addTarget:self action:@selector(hideSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"Enable editor mode";
            cell.accessoryView = aSwitch;
            if ([userDefaults integerForKey:@"IsEditorMode"] == 0) {
                aSwitch.on = false;
            }
            else {
                aSwitch.on = true;
            }
        }
        if (indexPath.row == 2) {
            cell.textLabel.text = CLEAN_CACHE;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        if (indexPath.row == 3) {
            cell.textLabel.text = USER_ID;
            CGFloat field_width = 225;
            CGFloat frame_width = self.view.frame.size.width;
            UITextField *playerTextField = [[UITextField alloc] 
                                            initWithFrame:CGRectMake(frame_width - field_width,
                                                                     10, field_width, 30)];
            playerTextField.text = [ComponentUtil getUserId];
            playerTextField.font = [UIFont systemFontOfSize:FONT_TINY];
            playerTextField.textAlignment = NSTextAlignmentRight;
            playerTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            playerTextField.returnKeyType = UIReturnKeyDone;
            playerTextField.borderStyle = UITextBorderStyleNone;
            playerTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            playerTextField.delegate = self;
            cell.accessoryView = playerTextField;
        }
        if (indexPath.row == 4) {
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            aSwitch.on = YES;
            aSwitch.tag = TAG_SWITCH_DEBUG_MODE;
            [aSwitch addTarget:self action:@selector(hideSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = @"Show verbose errmsg";
            cell.accessoryView = aSwitch;
            if ([userDefaults integerForKey:@"IsDebugMode"] == 0) {
                aSwitch.on = false;
            }
            else {
                aSwitch.on = true;
            }
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            cell.textLabel.text = FOLLOW_TWITTER;
        }
        
        if (indexPath.row == 1) {
            cell.textLabel.text = FOLLOW_MAILTO;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString* uid = textField.text;
    uid = [uid stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"Userid"];
    [textField resignFirstResponder];
    return YES;
}
 
#pragma mark - refresh
- (void)stopActivityIndicator:(bool)shouldAppendHead {
    if (shouldAppendHead == TRUE) {
        [(UIActivityIndicatorView *)[headerView viewWithTag:TAG_TABLE_HEADER_INDIACTOR] stopAnimating];
    }
    else {
        [(UIActivityIndicatorView *)[footerView viewWithTag:TAG_TABLE_FOOTER_INDIACTOR] stopAnimating];
    }
}

-(void)initTableIndicatorView
{
    // headerView
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 20.0)];
    UIActivityIndicatorView * actIndHeader = [[UIActivityIndicatorView alloc]
                                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actIndHeader.tag = TAG_TABLE_HEADER_INDIACTOR;
    actIndHeader.frame = CGRectMake(150.0, 5.0, 20.0, 20.0);
    
    actIndHeader.hidesWhenStopped = YES;
    
    [headerView addSubview:actIndHeader];
    
    self.tableView.tableHeaderView = headerView;
    
    // footerView
    footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
    
    UIActivityIndicatorView * actIndFooter = [[UIActivityIndicatorView alloc]
                                              initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    actIndFooter.tag = TAG_TABLE_FOOTER_INDIACTOR;
    actIndFooter.frame = CGRectMake(150.0, 5.0, 20.0, 20.0);
    
    actIndFooter.hidesWhenStopped = YES;
    
    [footerView addSubview:actIndFooter];
    
    self.tableView.tableFooterView = footerView;
}

- (void) refreshTableHead
{
    NSLog(@"refreshTableHead");
    [(UIActivityIndicatorView *)[headerView viewWithTag:TAG_TABLE_HEADER_INDIACTOR] startAnimating];
    [self fetchArticleList:[ComponentUtil getUserId] category_t:self.currentQC.category
               start_num_t:0
          shouldAppendHead:YES];
}

- (void) refreshTableTail
{
    NSLog(@"refreshTableTail");
    [(UIActivityIndicatorView *)[footerView viewWithTag:TAG_TABLE_FOOTER_INDIACTOR] startAnimating];
    [self fetchArticleList:[ComponentUtil getUserId] category_t:self.currentQC.category
               start_num_t:self->bottom_num * PAGE_COUNT
          shouldAppendHead:NO];
}

#pragma mark - load data
- (bool)addToTableView:(int)index
                  post:(Posts*)post
{
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"HideReadPosts"] == 1) {
        if (post.readcount.intValue !=0 )
            return YES;
    }
    
    bool ret = YES;
    [self.currentQC.questions insertObject:post atIndex:index];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    //NSLog(@"after addToTableView currentQuestions.count:%d", [self.currentQC.questions count]);
    return ret;
}

- (void)fetchArticleList:(NSString*)userid
              category_t:(NSString*)category_t
             start_num_t:(int)start_num_t
        shouldAppendHead:(bool)shouldAppendHead
{
    if ([self.navigationItem.title isEqualToString:SAVED_QUESTIONS])
        return;
    NSString *urlPrefix=SERVERURL;
    // TODO: voteup defined by users
    NSString *sortMethod;
    NSString *urlStr;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"IsEditorMode"] == 0) {
        // If anyone votedown, it's not shown
        sortMethod = @"hotest";
        urlStr= [NSString stringWithFormat: @"%@api_list_posts_in_topic?uid=%@&topic=%@&start_num=%d&count=%d&sort_method=%@&votedown=0",
                 urlPrefix, userid, category_t, start_num_t, PAGE_COUNT, sortMethod];
    }
    else {
        sortMethod = @"latest";
        urlStr= [NSString stringWithFormat: @"%@api_list_posts_in_topic?uid=%@&topic=%@&start_num=%d&count=%d&sort_method=%@",
                 urlPrefix, userid, category_t, start_num_t, PAGE_COUNT, sortMethod];
    }
    
    NSLog(@"fetchArticleList, url:%@", urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self stopActivityIndicator:shouldAppendHead];
        NSArray *idList = [JSON valueForKeyPath:@"postid"];
        NSArray *metadataList = [JSON valueForKeyPath:@"metadata"];
        Posts *post = nil;
        int i, count = [idList count];
        
        NSLog(@"count:%d, merge result dbPath: %@, postsDB:%@", count, self->dbPath, self->postsDB);
        
        // bypass sqlite lock problem
        if (shouldAppendHead) {
            // TODO remove code duplication
            for(i=count-1; i>=0; i--) {
                //NSLog(@"fetchArticleList i:%d, id:%@, metadata:%@", i, idList[i], metadataList[i]);
                if ([Posts containId:self.currentQC.questions postId:idList[i]] == NO) {
                    post = [PostsSqlite getPost:self->postsDB dbPath:self->dbPath postId:idList[i]];
                    if (post == nil) {
                        [self fetchJson:self.currentQC.questions
                                 urlStr:[[urlPrefix stringByAppendingString:@"api_get_post?postid="] stringByAppendingString:idList[i]]
                       shouldAppendHead:shouldAppendHead];
                    }
                    else {
                        int index = 0;
                        if (shouldAppendHead != YES){
                            index = [self.currentQC.questions count];
                        }
                        [self addToTableView:index post:post];
                    }
                }
            }
        }
        else{
            for(i=0; i<count; i++) {
                if ([Posts containId:self.currentQC.questions postId:idList[i]] == NO) {
                    post = [PostsSqlite getPost:self->postsDB dbPath:self->dbPath postId:idList[i]];
                    if (post == nil) {
                        [self fetchJson:self.currentQC.questions
                                 urlStr:[[urlPrefix stringByAppendingString:@"api_get_post?postid="] stringByAppendingString:idList[i]]
                       shouldAppendHead:shouldAppendHead];
                    }
                    else {
                        int index = 0;
                        if (shouldAppendHead != YES){
                            index = [self.currentQC.questions count];
                        }
                        [self addToTableView:index post:post];
                    }
                }
            }
        }
        for(i=0; i<count; i++) {
            [PostsSqlite updatePostMetadata:self->postsDB dbPath:self->dbPath
                                     postId:idList[i] metadata:metadataList[i]
                                   category:self.currentQC.category];
            
        }
        if (shouldAppendHead == NO) {
            self->bottom_num = 1 + self->bottom_num;
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self stopActivityIndicator:shouldAppendHead];
        [ComponentUtil infoMessage:@"Error to get specific post list"
                               msg:[NSString stringWithFormat:@"url:%@, error:%@", urlStr, error]
                     enforceMsgBox:FALSE];
    }];
    
    [operation start];
}

- (void)fetchJson:(NSMutableArray*) listObject
           urlStr:(NSString*)urlStr
 shouldAppendHead:(bool)shouldAppendHead
{
    
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        Posts* post = [[Posts alloc] init];
        [post setPostid:[JSON valueForKeyPath:@"id"]];
        [post setTitle:[JSON valueForKeyPath:@"title"]];
        [post setSummary:[JSON valueForKeyPath:@"summary"]];
        [post setCategory:[JSON valueForKeyPath:@"category"]];
        [post setContent:[JSON valueForKeyPath:@"content"]];
        [post setSource:[JSON valueForKeyPath:@"source"]];
        [post set_metadata:[JSON valueForKeyPath:@"metadata"]];
        [post setReadcount:[NSNumber numberWithInt:0]];
        
        if ([PostsSqlite savePost:self->postsDB dbPath:self->dbPath
                           postId:post.postid summary:post.summary category:post.category
                            title:post.title source:post.source content:post.content
                         metadata:post.metadata] == NO) {
            [ComponentUtil infoMessage:@"Error to insert post"
                                   msg:[NSString stringWithFormat:@"postid:%@, title:%@", post.postid, post.title]
                         enforceMsgBox:FALSE];
        }
        
        int index = 0;
        if (shouldAppendHead != YES){
            index = [listObject count];
        }
        [self addToTableView:index post:post];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [ComponentUtil infoMessage:@"Error to get specific post"
                               msg:[NSString stringWithFormat:@"url:%@, error:%@", urlStr, error]
                     enforceMsgBox:FALSE];
        
    }];
    
    [operation start];
}

#pragma mark - scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//NSLog(@"scrollViewDidScroll, scrollView:%@", scrollView);
    if (![self isQuestionChannel])
        return;
    // when reach the top
    if (scrollView.contentOffset.y <= 0)
    {
        [(UIActivityIndicatorView *)[headerView viewWithTag:TAG_TABLE_HEADER_INDIACTOR] startAnimating];
    }
    
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        [(UIActivityIndicatorView *)[footerView viewWithTag:TAG_TABLE_FOOTER_INDIACTOR] startAnimating];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  //NSLog(@"scrollViewDidEndDecelerating, scrollView:%@", scrollView);
    if (![self isQuestionChannel])
        return;
    
    // when reach the top
    if (scrollView.contentOffset.y <= 0)
    {
        [self refreshTableHead];
    }
    
    // when reaching the bottom
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height)
    {
        [self refreshTableTail];
    }
}

#pragma mark - private functions
- (BOOL) isQuestionChannel
{
    return (![self.navigationTitle isEqualToString:SAVED_QUESTIONS] &&
            ![self.navigationTitle isEqualToString:APP_SETTING]);
}

@end
