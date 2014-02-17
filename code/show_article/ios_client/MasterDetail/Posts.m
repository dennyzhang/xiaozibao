//
// posts.m
// MasterDetail
//
// Created by mac on 13-7-22.
// Copyright (c) 2013年 mac. All rights reserved.
//

#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"

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
              comment:(NSString*) comment
{
  NSString *urlStr=SERVERURL;
  NSURL *url = [NSURL URLWithString:urlStr];
  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                         userid, @"uid", postid, @"postid", comment, @"comment",
                         nil];
  NSLog(@"feedbackPost, url:%@", urlStr);
  AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
  NSURLRequest *request = [client requestWithMethod:@"POST" path:@"api_feedback_post" parameters:params];

  AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
      NSString *status = [JSON valueForKeyPath:@"status"];
      if ([status isEqualToString:@"ok"]) {
         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:
                      @"Submited successfuly!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [alert show];
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
