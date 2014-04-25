//
//  QuestionCategory.m
//  MasterDetail
//
//  Created by mac on 14-4-16.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "QuestionCategory.h"

@implementation QuestionCategory

@synthesize category, questions, isloaded;
@synthesize allCategories;

- (void)initialize:(NSString*)category_t
{
  self.questions = [[NSMutableArray alloc] init];
  self.category = category_t;
  self.isloaded = NO;
}

-(void) loadPosts
{
  if(self.isloaded) {
    NSLog(@"loadPosts: no need to load again");
    return;
  }
  [PostsSqlite getDefaultPosts:self.category objects:self.questions
                 hideReadPosts:[[NSUserDefaults standardUserDefaults] integerForKey:@"HideReadPosts"]];

  self.isloaded = YES;
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
    
    count = (int)[stringArray count];
    //NSLog(@"update_category_list count:%d", count);
    
    for (i = 0; i < count; i ++) {
//        UILabel* titleLabel_t = [UILabel new];
//        titleLabel_t.text = [stringArray[i] capitalizedString];
//        titleLabel_t.font = [UIFont systemFontOfSize:FONT_NAVIGATIONBAR];
//        titleLabel_t.textColor = [UIColor whiteColor];

        QuestionCategory* questionCategory = [[QuestionCategory alloc] init];
        [questionCategory initialize:stringArray[i]];
        [self.allCategories addObject:questionCategory];
    }
  return allCategories;
}

- (BOOL) isCategoryListChanged
{
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  NSString* categoryList = [userDefaults stringForKey:@"CategoryList"];
  NSString* oldCategoryList = @"";
  int i, count = (int)[self.allCategories count];
  for(i=0; i<count; i++) {
    QuestionCategory *qc = [self.allCategories objectAtIndex:i];
    oldCategoryList = [NSString stringWithFormat:@"%@%@,", oldCategoryList, qc.category];
  }
  NSLog(@"isCategoryListChanged oldCategoryList:%@ categoryList:%@", oldCategoryList, categoryList);
  return (![oldCategoryList isEqualToString:[NSString stringWithFormat:@"%@,", categoryList]]);
}

+(void)clearIsLoaded
{
  NSMutableArray *questionCategories = [[QuestionCategory singleton] getAllCategories];
  int i, count = (int)[questionCategories count];
  for(i=0; i<count; i++) {
    QuestionCategory* qc = [questionCategories objectAtIndex:i];
    qc.isloaded = NO;
  }
}

@end