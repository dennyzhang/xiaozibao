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
@property (nonatomic, strong) NSMutableArray  *visiblePopTipViews;
@property (nonatomic, strong) id              currentPopTipViewTarget;
@property (retain, nonatomic) IBOutlet UIView *popView;

+(MyToolTip *)singleton;

-(void)reset:(UIView*)view;
-(void)addToolTip:(id)withObject;
-(void)showToolTip;
- (IBAction)toolTipAction:(id)sender;

@end
