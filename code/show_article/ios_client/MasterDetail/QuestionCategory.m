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
@synthesize allCategories;

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

+(QuestionCategory *)singleton {
    static QuestionCategory *shared = nil;
    
    if(shared == nil) {
        shared = [[QuestionCategory alloc] init];
        shared.allCategories = [[NSMutableArray alloc] init];
    }
    return shared;
}

-(NSMutableArray*) getAllCategories
{
  if (![self isCategoryListChanged]) {
    NSLog(@"update_category_list: categoryList not changed");
    return allCategories;
  }

    int i, count;
    [self.allCategories removeAllObjects];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* categoryList = [userDefaults stringForKey:@"CategoryList"];
    NSArray *stringArray = [categoryList componentsSeparatedByString: @","];
    
    count = [stringArray count];
    NSLog(@"update_category_list count:%d", count);
    
    for (i = 0; i < count; i ++) {
        // init tableView
        UITableView* questionTableView = [[UITableView alloc] init];
        
        UILabel* titleLabel_t = [UILabel new];
        titleLabel_t.text = [stringArray[i] capitalizedString];
        titleLabel_t.font = [UIFont systemFontOfSize:FONT_NAVIGATIONBAR];
        titleLabel_t.textColor = [UIColor whiteColor];
        
        QuestionCategory* questionCategory = [[QuestionCategory alloc] init];
        [questionCategory initialize:questionTableView titleLabel:titleLabel_t];
        [self.allCategories addObject:questionCategory];
    }
  return allCategories;
}

- (BOOL) isCategoryListChanged
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString* categoryList = [userDefaults stringForKey:@"CategoryList"];
  NSString* oldCategoryList = @"";
  int i, count = [self.allCategories count];
  for(i=0; i<count; i++) {
    QuestionCategory *qc = [self.allCategories objectAtIndex:i];
    oldCategoryList = [NSString stringWithFormat:@"%@%@,", oldCategoryList, qc.category];
  }
  NSLog(@"isCategoryListChanged oldCategoryList:%@ categoryList:%@", oldCategoryList, categoryList);
  return (![oldCategoryList isEqualToString:[NSString stringWithFormat:@"%@,", categoryList]]);
}

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