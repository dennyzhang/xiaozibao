//
// posts.m
// MasterDetail
//
// Created by mac on 13-7-22.
// Copyright (c) 2013年 mac. All rights reserved.
//
#import "Posts.h"
#import "constants.h"

@implementation Posts
@synthesize postid, title, summary, category, content, source, readcount;
@synthesize isfavorite, isvoteup, isvotedown;

- (id)init
{
  self = [super init];
  if(self) {
    // Initialization code here
    postid=@"";
    title=@"";
    summary=@"";
    category=@"";
    content=@"";
    source=@"";
    isfavorite=NO;
    isvoteup=NO;
    isvotedown=NO;
    readcount=[NSNumber numberWithInt:0];
  }
  return self;
}

+ (void)getCategoryList:(NSUserDefaults *)userDefaults
{
     NSString *urlPrefix=SERVERURL;
     NSString *urlStr= [NSString stringWithFormat: @"%@api_list_topic", urlPrefix];
     NSURL *url = [NSURL URLWithString:urlStr];
     NSLog(@"getCategoryList, url:%@", urlStr);
     AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
     NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                             path:urlStr
                                                       parameters:nil];
     AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
     [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
     [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSString *response_str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSLog(@"Response of list_category: %@", response_str);
         [userDefaults setObject:response_str forKey:@"CategoryList"];
         [userDefaults synchronize];
       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
       }];
     [operation start];
}

+ (bool)containId:(NSMutableArray*) objects
           postId:(NSString*)postId
{
   bool ret = NO;
   NSUInteger i, count = [objects count];
   Posts* post;
   for(i=0; i<count; i++) {
       post = objects[i];
       if ([post.postid isEqualToString:postId] == 1) {
          ret = YES;
          break;
       }
   }
   return ret;
}

@end
