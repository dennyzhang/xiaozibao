//
// posts postsSqlite.m
// MasterDetail
//
// Created by mac on 13-7-21.
// Copyright (c) 2013年 mac. All rights reserved.
//

#import "PostsSqlite.h"

@implementation PostsSqlite
NSLock *lock;

+ (bool)initDB: (sqlite3 *)postsDB
        dbPath:(NSString *) dbPath
{
  bool ret = NO;

  char *errMsg;
  const char *dbpath = [dbPath UTF8String];
  NSLog(@"initDB");
  const char *sql_stmt = "CREATE TABLE IF NOT EXISTS POSTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, POSTID TEXT UNIQUE, SUMMARY TEXT, CATEGORY TEXT, TITLE TEXT, CONTENT TEXT, READCOUNT INT DEFAULT 0, MARK INTEGER DEFAULT 0)";
  //const char *sql_stmt = "drop table posts";
  if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
      if (sqlite3_exec(postsDB, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
          ret = NO;
          NSLog(@"err for initDB");
          NSLog(@"%s", errMsg);
        }

      ret = YES;
    }
  sqlite3_close(postsDB);
  return ret;
}

+ (Posts*)getPost: (sqlite3 *)postsDB
          dbPath:(NSString *) dbPath
          postId:(NSString *)postId
{
  Posts* ret = nil;
  const char *dbpath = [dbPath UTF8String];
  sqlite3_stmt *statement;
  NSString *querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, READCOUNT FROM POSTS WHERE POSTID=\"%@\"", postId];
    NSLog(@"here here2222222222: %@", dbPath);
  const char *query_stmt = [querySQL UTF8String];
  [lock lock];
  if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        NSLog(@"open ok\n");
      if (sqlite3_prepare_v2(postsDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            NSLog(@"query ok\n");
          if (sqlite3_step(statement) == SQLITE_ROW)
            {
                 NSLog(@"row ok\n");
              ret = [[Posts alloc] init];
              NSString* postid = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
              NSString* summary = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
              NSString* category = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
              NSString* title = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
              NSString* content = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
              content = [content stringByReplacingOccurrencesOfString: @"dennyseperator" withString:@"\""];
              NSString* readCountStr = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];

              NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
              [f setNumberStyle:NSNumberFormatterDecimalStyle];
              NSNumber* readcount = [f numberFromString:readCountStr];
               
              [ret setPostid:postid];
              [ret setSummary:summary];
              [ret setCategory:category];
              [ret setTitle:title];
              [ret setContent:content];
              [ret setReadcount:readcount];
            }
        }
      sqlite3_finalize(statement);
      sqlite3_close(postsDB);
    }
  [lock unlock];
  return ret;
}

+ (bool)savePost: (sqlite3 *)postsDB
          dbPath:(NSString *) dbPath
          postId:(NSString *)postId
          summary:(NSString *)summary
        category:(NSString *)category
           title:(NSString *)title
         content:(NSString *)content
{
  bool ret;
  const char *dbpath = [dbPath UTF8String];
  NSLog(@"savePost. id:%@, title:%@", postId, title);
  sqlite3_stmt *statement = NULL;
  content = [content stringByReplacingOccurrencesOfString: @"\"" withString:@"dennyseperator"];
  NSString *insertSQL = [NSString
                          stringWithFormat:
                            @"INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, CONTENT) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                          postId, category, summary, title, content];
  const char *insert_stmt = [insertSQL UTF8String];

  [lock lock];
  if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
      sqlite3_prepare_v2(postsDB, insert_stmt, -1, &statement, NULL);

      if (sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"%@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)]);
   //     NSLog(@"insertSQL:%@",insertSQL);
        ret = NO;
      }
      else
        ret = YES;
    }
  else {
    ret = NO;
  }

  sqlite3_finalize(statement);
  sqlite3_close(postsDB);
  [lock unlock];
  return ret;
}

+ (bool)mark: (sqlite3 *)postsDB
      dbPath:(NSString *)dbPath
      postId:(NSString *)postId
        mark:(BOOL)mark
{
    bool ret;
    const char *dbpath = [dbPath UTF8String];
    sqlite3_stmt *statement = NULL;
      NSString *updateSQL = [NSString stringWithFormat: @"UPDATE POSTS set MARK=%i where postid=\"%@\"", mark,postId];

    const char *insert_stmt = [updateSQL UTF8String];
    
    [lock lock];
    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        sqlite3_prepare_v2(postsDB, insert_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"%@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)]);
            NSLog(@"updateSQL:%@",updateSQL);
            ret = NO;
        }
        else
            ret = YES;
    }
    else {
        NSLog(@"Error:mark failed");
        ret = NO;
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(postsDB);
    [lock unlock];
    return ret;
}

// TODO: refine later
+ (bool)loadPosts: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
            topic:(NSString *)topic
          objects:(NSMutableArray *) objects
        tableview:(UITableView *)tableview
{
    NSString *querySQL;
  NSLog(@"loadposts, topic:%@",topic);
  bool ret = NO;
  const char *dbpath = [dbPath UTF8String];
  sqlite3_stmt *statement;
    if ([topic isEqualToString:@"Saved posts"]) {
        querySQL = [NSString stringWithFormat: @"SELECT postid, summary, category, title, content, readcount FROM POSTS where MARK=1  order by id desc limit 10"];

    }
    else
    {
        querySQL = [NSString stringWithFormat: @"SELECT postid, summary, category, title, content, readcount FROM POSTS where category =\"%@\"  order by id desc limit 10", topic];
    }
  const char *query_stmt = [querySQL UTF8String];
  [lock lock];
  if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
      if (sqlite3_prepare_v2(postsDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
          while (sqlite3_step(statement) == SQLITE_ROW)
            {
              Posts* post = [[Posts alloc] init];
              NSString* postid = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
              NSString* summary = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
              NSString* category = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
              NSString* title = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
              NSString* content = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
              NSString* readCountStr = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
              content = [content stringByReplacingOccurrencesOfString: @"dennyseperator" withString:@"\""];

              NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
              [f setNumberStyle:NSNumberFormatterDecimalStyle];
              NSNumber* readcount = [f numberFromString:readCountStr];

              [post setPostid:postid];
              [post setSummary:summary];
              [post setCategory:category];
              [post setTitle:title];
              [post setContent:content];
              [post setReadcount:readcount];

              [objects insertObject:post atIndex:0];

              NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
              [tableview insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
              ret = YES;
            }
        }
      sqlite3_finalize(statement);
      sqlite3_close(postsDB);
    }
  [lock unlock];
  return ret;
}


+ (bool)addPostReadCount: (sqlite3 *)postsDB
                  dbPath:(NSString *) dbPath
                  postId:(NSString *)postId
                   topic:(NSString *)topic
{
  bool ret;
  const char *dbpath = [dbPath UTF8String];
  NSLog(@"addPostReadCount. id:%@, topic:%@", postId, topic);
  sqlite3_stmt *statement = NULL;
  NSString *updateSql = [NSString
                          stringWithFormat:
                            @"UPDATE POSTS SET readcount=readcount+1 WHERE postid=\"%@\" and category=\"%@\"",
                          postId, topic];
  const char *sql_stmt = [updateSql UTF8String];
    
  [lock lock];
  if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
      sqlite3_prepare_v2(postsDB, sql_stmt, -1, &statement, NULL);

      if (sqlite3_step(statement) != SQLITE_DONE) {
        NSLog(@"%@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)]);
        ret = NO;
      }
      else
        ret = YES;
    }
  else {
    ret = NO;
  }

  sqlite3_finalize(statement);
  sqlite3_close(postsDB);
  [lock unlock];
  return ret;
}
@end
