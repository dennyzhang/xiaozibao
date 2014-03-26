//
//  componentUtil.h
//  MasterDetail
//
//  Created by mac on 14-3-26.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "constants.h"

@interface ComponentUtil : NSObject
+ (void) addScoreToButton:(UIButton*) btn score:(NSInteger)score
                 fontSize:(NSInteger)fontSize
               chWidth:(NSInteger)chWidth
               chHeight:(NSInteger)chHeight
                 tag:(NSInteger)tag;

@end
