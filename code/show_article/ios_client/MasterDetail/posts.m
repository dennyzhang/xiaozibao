//
// posts.m
// MasterDetail
//
// Created by mac on 13-7-22.
// Copyright (c) 2013年 mac. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"

#import "Posts.h"
#import "constants.h"

@implementation Posts
@synthesize postid, title, summary, category, content, readcount;

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
    readcount=[NSNumber numberWithInt:0];
  }
  return self;
}

+ (void) feedbackPost:(NSString*) userid
               postid:(NSString*) postid
             category:(NSString*) category
              comment:(NSString*) comment
                button:(UIButton *) button
{
  NSString *urlStr=SERVERURL;
  NSURL *url = [NSURL URLWithString:urlStr];
  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                                         userid, @"uid", postid, @"postid",
                                       category, @"category", comment, @"comment",
                         nil];
  NSLog(@"feedbackPost, url:%@", urlStr);
  AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
  NSURLRequest *request = [client requestWithMethod:@"POST" path:@"api_feedback_post" parameters:params];

  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
      NSString *status = [JSON valueForKeyPath:@"status"];
      if ([status isEqualToString:@"ok"]) {
         button.enabled = false;
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

+ (NSMutableArray *)getCategoryList
{
     NSMutableArray *_objects = [[NSMutableArray alloc] init];

     NSString *urlPrefix=SERVERURL;
     NSString *urlStr= [NSString stringWithFormat: @"%@api_list_topic", urlPrefix];
     NSURL *url = [NSURL URLWithString:urlStr];

     AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
     NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET"
                                                             path:urlStr
                                                       parameters:nil];
     AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
     [httpClient registerHTTPOperationClass:[AFHTTPRequestOperation class]];
     [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSString *response_str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

         NSLog(@"Response: %@", response_str);

         [_objects insertObject:@"test1" atIndex:0];
         [_objects insertObject:@"test2" atIndex:0];

       } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         [_objects insertObject:@"linux" atIndex:0];
         [_objects insertObject:@"cloud" atIndex:0];
         [_objects insertObject:@"security" atIndex:0];
         [_objects insertObject:@"algorithm" atIndex:0];
         [_objects insertObject:@"product" atIndex:0];
         [_objects insertObject:@"concept" atIndex:0];
       }];
     [operation start];
     return _objects;
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
