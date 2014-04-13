//
//  MyToolTip.h
//  MasterDetail
//
//  Created by mac on 14-4-13.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyToolTip : NSObject

@property (nonatomic, strong) NSDictionary *contents;
@property (nonatomic, strong) NSArray      *colorSchemes;
@property (nonatomic, strong) NSDictionary	*titles;

+(MyToolTip *)singleton;
-(NSArray*) getColorSchmeme;
-(NSString*) getContentByKey:(NSNumber*) key;
-(NSString*) getTitleByKey:(NSNumber*) key;
@end
