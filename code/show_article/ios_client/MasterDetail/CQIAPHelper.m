//
//  CQIAPHelper.m
//  MasterDetail
//
//  Created by mac on 14-4-27.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "CQIAPHelper.h"

@implementation CQIAPHelper

+ (CQIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static CQIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"CoderQuiz",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
