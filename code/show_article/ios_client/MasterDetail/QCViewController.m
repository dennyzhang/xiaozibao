//
//  QCViewController.m
//  MasterDetail
//
//  Created by mac on 14-4-20.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "QCViewController.h"

@interface QCViewController () {
    sqlite3 *postsDB;
    NSString *dbPath;
}
@end

@implementation QCViewController

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

    self->postsDB = [PostsSqlite openSqlite:dbPath];
    self->dbPath = [PostsSqlite getDBPath];

    [self.currentQC loadPosts:self->postsDB dbPath:self->dbPath];

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentQC.questions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = DEFAULT_BACKGROUND_COLOR;
    cell.textLabel.font = [UIFont fontWithName:FONT_NAME1 size:FONT_NORMAL];
    if ([self.navigationItem.title isEqualToString:APP_SETTING]) {
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
    if ([self.navigationItem.title isEqualToString:APP_SETTING]) {
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
        self->dbPath = [PostsSqlite getDBPath]; // TODO why we need this?
        [PostsSqlite openSqlite:dbPath];
        
        [PostsSqlite cleanCache:postsDB dbPath:dbPath];
        if ([[NSUserDefaults standardUserDefaults] integerForKey:@"IsEditorMode"] == 1) {
            [UserProfile cleanAllCategoryKey];
        }
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([self.navigationItem.title isEqualToString:APP_SETTING]) {
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
    if ([self.navigationItem.title isEqualToString:APP_SETTING])
        return 30;
    return 0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"MasterViewController segue identifier: %@", [segue identifier]);
    NSIndexPath *indexPath = [self.currentQC.tableView indexPathForSelectedRow];
    UITableViewCell *cell = [self.currentQC.tableView cellForRowAtIndexPath:indexPath];
    
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSLog(@"increate visit count, for category:%@. previous key:%d", self.currentQC.category,
              [UserProfile integerForKey:self.currentQC.category key:POST_VISIT_KEY]);
        Posts *post = self.currentQC.questions[indexPath.row];
        
        post.readcount = [NSNumber numberWithInt:(1+[post.readcount intValue])];
        [self markCellAsRead:cell post:post];

        // if ([self.currentQC.category isEqualToString:SAVED_QUESTIONS]) {
        //     [[segue destinationViewController] setShouldShowCoin:[NSNumber numberWithInt:0]];
        // }
        // else {
        //     [[segue destinationViewController] setShouldShowCoin:[NSNumber numberWithInt:1]];
        // }

        DetailViewController* dvc = [segue destinationViewController];
        dvc.detailItem = post;
        //  [dvc view];
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
        if (indexPath.row == 3) {
            cell.textLabel.text = CLEAN_CACHE;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }

        if (indexPath.row == 4) {
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

@end
