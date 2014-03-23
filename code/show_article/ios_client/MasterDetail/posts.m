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
@synthesize postid, title, summary, category, content, source, readcount, isfavorite;

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
        // TODO
        NSLog(@"perform operation after success");
        //button.enabled = false;
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
         NSLog(@"Response of list_topic: %@", response_str);
         [userDefaults setObject:response_str forKey:@"TopicList"];
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

+(void)infoMessage:(NSString *) title
               msg:(NSString *) msg
{
    UIAlertView *alert = [[UIAlertView alloc]
                                      initWithTitle:title message:msg delegate:self
                                  cancelButtonTitle:nil
                                  otherButtonTitles:nil, nil];
    [alert show];
    [Posts timedAlert:alert];

}

+(void)timedAlert:(UIAlertView *) alertView
{
    [self performSelector:@selector(dismissAlert:) withObject:alertView afterDelay:HIDE_MESSAGEBOX_DELAY];
}

+(void)dismissAlert:(UIAlertView *) alertView
{
    [alertView dismissWithClickedButtonIndex:nil animated:YES];
}

@end
