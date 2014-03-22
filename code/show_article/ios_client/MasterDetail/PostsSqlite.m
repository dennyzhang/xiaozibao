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
    const char *sql_stmt = "CREATE TABLE IF NOT EXISTS POSTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, POSTID TEXT UNIQUE, SUMMARY TEXT, CATEGORY TEXT, TITLE TEXT, CONTENT TEXT, SOURCE TEXT, READCOUNT INT DEFAULT 0, ISSAVED INT DEFAULT 0)";
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

+ (bool)cleanCache: (sqlite3 *)postsDB
            dbPath:(NSString *)dbPath
{
    bool ret;
    const char *dbpath = [dbPath UTF8String];
    sqlite3_stmt *statement = NULL;
    NSString *deleteSQL = @"DELETE FROM POSTS WHERE issaved=0;";
    const char *delete_stmt = [deleteSQL UTF8String];
    
    [lock lock];
    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        sqlite3_prepare_v2(postsDB, delete_stmt, -1, &statement, NULL);
        
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

+ (Posts*)getPost: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
           postId:(NSString *)postId
{
    Posts* ret = nil;
    const char *dbpath = [dbPath UTF8String];
    sqlite3_stmt *statement;
    NSString *querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISSAVED FROM POSTS WHERE POSTID=\"%@\"", postId];
    const char *query_stmt = [querySQL UTF8String];
    [lock lock];
    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        if (sqlite3_prepare_v2(postsDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                ret = [[Posts alloc] init];
                NSString* postid = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 0)];
                NSString* summary = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 1)];
                NSString* category = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 2)];
                NSString* title = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 3)];
                NSString* content = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 4)];
                content = [content stringByReplacingOccurrencesOfString: @"dennyseperator" withString:@"\""];
                NSString* source = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                NSNumber *readcount = [NSNumber numberWithInt:(int)sqlite3_column_int(statement, 6)];
                NSNumber *issaved = [NSNumber numberWithInt:(int)sqlite3_column_int(statement, 7)];
                // NSString* readCountStr = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                // NSString* isSavedStr = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)];

                // NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                // [f setNumberStyle:NSNumberFormatterDecimalStyle];
                // NSNumber* readcount = [f numberFromString:readCountStr];

                // NSNumber* issaved = [f numberFromString:isSavedStr];
                
                [ret setPostid:postid];
                [ret setSummary:summary];
                [ret setCategory:category];
                [ret setTitle:title];
                [ret setContent:content];
                [ret setSource:source];
                [ret setReadcount:readcount];
                [ret setIssaved:[issaved intValue]];
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
           source:(NSString *)source
         content:(NSString *)content
{
    bool ret;
    const char *dbpath = [dbPath UTF8String];
    NSLog(@"savePost. id:%@, title:%@", postId, title);
    sqlite3_stmt *statement = NULL;
    content = [content stringByReplacingOccurrencesOfString: @"\"" withString:@"dennyseperator"];
    NSString *insertSQL = [NSString
                           stringWithFormat:
                           @"INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                            postId, category, summary, title, source, content];
    const char *insert_stmt = [insertSQL UTF8String];
    
    [lock lock];
    if (sqlite3_open(dbpath, &postsDB) == SQLITE_OK)
    {
        sqlite3_prepare_v2(postsDB, insert_stmt, -1, &statement, NULL);
        
        if (sqlite3_step(statement) != SQLITE_DONE) {
            NSLog(@"%@", [NSString stringWithUTF8String:(char*)sqlite3_errmsg(postsDB)]);
            NSLog(@"insertSQL:%@",insertSQL);
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

// TODO: refine later
+ (bool)loadPosts: (sqlite3 *)postsDB
           dbPath:(NSString *) dbPath
            topic:(NSString *)topic
          objects:(NSMutableArray *) objects
    hideReadPosts:(BOOL) hideReadPosts
        tableview:(UITableView *)tableview
{
    NSLog(@"loadposts, topic:%@, hideReadPosts:%d",topic, hideReadPosts);
    bool ret = NO;
    const char *dbpath = [dbPath UTF8String];
    sqlite3_stmt *statement;
    NSString *querySQL;
    if ([topic isEqualToString:SAVED_POSTS]) {
      querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISSAVED FROM POSTS WHERE issaved=1 ORDER BY ID DESC LIMIT 10", topic];
    }
    else {
      if (hideReadPosts == true) {
        querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISSAVED  FROM POSTS WHERE CATEGORY =\"%@\" and READCOUNT=0 ORDER BY ID DESC LIMIT 10", topic];
      }
      else {
        querySQL = [NSString stringWithFormat: @"SELECT POSTID, SUMMARY, CATEGORY, TITLE, CONTENT, SOURCE, READCOUNT, ISSAVED FROM POSTS WHERE CATEGORY =\"%@\" ORDER BY ID DESC LIMIT 10", topic];
      }
    }
    //NSLog(@"sql: %@", querySQL);
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
                content = [content stringByReplacingOccurrencesOfString: @"dennyseperator" withString:@"\""];
                NSString* source = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 5)];
                NSNumber *readcount = [NSNumber numberWithInt:(int)sqlite3_column_int(statement, 6)];
                NSNumber *issaved = [NSNumber numberWithInt:(int)sqlite3_column_int(statement, 7)];
                // NSString* readCountStr = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 6)];
                // NSString* isSavedStr = [[NSString alloc] initWithUTF8String:(const char *) sqlite3_column_text(statement, 7)];
                
                // NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                // [f setNumberStyle:NSNumberFormatterDecimalStyle];
                // NSNumber* readcount = [f numberFromString:readCountStr];
                
                // NSNumber* issaved = [f numberFromString:isSavedStr];

                [post setPostid:postid];
                [post setSummary:summary];
                [post setCategory:category];
                [post setTitle:title];
                [post setContent:content];
                [post setSource:source];
                [post setReadcount:readcount];
                [post setIssaved:[issaved intValue]];
                
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

+ (bool)updatePostIssaved: (sqlite3 *)postsDB
                  dbPath:(NSString *) dbPath
                  postId:(NSString *)postId
                  issaved:(BOOL)issaved
                   topic:(NSString *)topic
{
    bool ret;
    const char *dbpath = [dbPath UTF8String];
    NSLog(@"UpdatePostIssaved. id:%@, topic:%@", postId, topic);
    sqlite3_stmt *statement = NULL;
    NSString *updateSql = [NSString
                           stringWithFormat:
                           @"UPDATE POSTS SET issaved=%d WHERE postid=\"%@\" and category=\"%@\"",
                            issaved, postId, topic];
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
