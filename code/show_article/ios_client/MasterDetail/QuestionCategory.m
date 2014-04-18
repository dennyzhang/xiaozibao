//
//  QuestionCategory.m
//  MasterDetail
//
//  Created by mac on 14-4-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "QuestionCategory.h"

@implementation QuestionCategory

@synthesize category, questions, tableView, titleLabel, isloaded;

- (void)initialize:(UITableView*)tableView_t
        titleLabel:(UILabel*)titleLabel_t
{
  self.questions = [[NSMutableArray alloc] init];
  self.tableView = tableView_t;
  self.titleLabel = titleLabel_t;
  self.category = self.titleLabel.text;
  self.isloaded = NO;
  // NSLog(@"initalize self.tableView:%@", self.tableView); //TODO
}

// TODO: memory leak

+ (void) load_category:(QuestionCategory*) questionCategory
               postsDB:(sqlite3 *)postsDB
             dbPath:(NSString *) dbPath
{
    // return if already loaded
    if(questionCategory.isloaded) {
        NSLog(@"no need to load again");
        return;
    }

    [questionCategory.tableView reloadData];
    
    [PostsSqlite loadPosts:postsDB dbPath:dbPath category:questionCategory.category
                   objects:questionCategory.questions
             hideReadPosts:[[NSUserDefaults standardUserDefaults] integerForKey:@"HideReadPosts"]
                 tableview:questionCategory.tableView];
    questionCategory.isloaded = YES;
}

@end