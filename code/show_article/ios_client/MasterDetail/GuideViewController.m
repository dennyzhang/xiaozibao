//
//  GuideViewController.m
//  MasterDetail
//
//  Created by mac on 14-4-19.
//  Copyright (c) 2014年 mac. All rights reserved.
//

#import "GuideViewController.h"

@implementation GuideViewController

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    [super viewDidLoad];
    
    UIButton *btnEnter = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 28, 16)];
    [btnEnter addTarget:self action:@selector(actionEnter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnEnter];
    NSLog(@"after addsubview in didload");
    
}

-(void)actionEnter:(id)sender
{
    [self performSegueWithIdentifier:@"enterMain" sender:self];
}


@end
