//
//  MyToolTip.h
//  MasterDetail
//
//  Created by mac on 14-4-13.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMPopTipView.h"

@interface MyToolTip : NSObject <CMPopTipViewDelegate>

@property (nonatomic, strong) NSDictionary    *contents;
@property (nonatomic, strong) NSArray         *colorSchemes;
@property (nonatomic, strong) NSDictionary    *titles;
@property (nonatomic, strong) NSMutableArray  *visiblePopTipViews;
@property (nonatomic, strong) id              currentPopTipViewTarget;
@property (retain, nonatomic) IBOutlet UIView *popView;

+(MyToolTip *)singleton;

-(NSArray*) getColorSchmeme;
-(NSString*) getContentByKey:(NSNumber*) key;
-(NSString*) getTitleByKey:(NSNumber*) key;
-(void)reset:(UIView*)view;
-(void)removeObject:(CMPopTipView *)popTipView;
-(void)addObject:(CMPopTipView *)popTipView;

- (IBAction)toolTipAction:(id)sender;
@end
