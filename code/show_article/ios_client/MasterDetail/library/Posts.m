//
// posts.m
// MasterDetail
//
// Created by mac on 13-7-22.
// Copyright (c) 2013年 mac. All rights reserved.
//
#import "myGlobal.h"
#import "Posts.h"

@implementation Posts
@synthesize postid, title, summary, category, content, source, readcount;
@synthesize isfavorite, isvoteup, isvotedown, metadata, metadataDictionary;

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
    metadata=@"";
    isfavorite=NO;
    isvoteup=NO;
    isvotedown=NO;
    readcount=[NSNumber numberWithInt:0];
    metadataDictionary = [[NSMutableDictionary alloc] init];
  }
  return self;
}

- (void)set_metadata:(NSString *)metadata_t
{
  self.metadata = metadata_t;
  self.metadataDictionary = [[NSMutableDictionary alloc] init];
  NSArray* stringArray = [metadata_t componentsSeparatedByString: @"&"];
  NSArray* array;
  NSString* keypair;
  NSString* key;
  NSString* value;
  if (![self.metadata isEqualToString:@""]) {
    for(int i = 0; i < [stringArray count]; i++) {
      keypair=[stringArray objectAtIndex:i];
      array=[keypair componentsSeparatedByString: @"="];
      if ([array count] != 2) {
        NSLog(@"Error invalid metadata: %@", metadata);
      }
      key = [array objectAtIndex:0];
      value = [array objectAtIndex:1];
      [self.metadataDictionary setValue:value forKey:key];
    }
  }
  //NSLog(@"self.metadataDictionary:%@", self.metadataDictionary);
}

+ (void)updateCategoryList:(NSUserDefaults *)userDefaults
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
