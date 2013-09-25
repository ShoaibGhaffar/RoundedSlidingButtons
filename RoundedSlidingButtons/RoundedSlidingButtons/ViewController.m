//
//  ViewController.m
//  RoundedSlidingButtonsView
//
//  Created by Shoaib Mac Mini on 11/09/2013.
//  Copyright (c) 2013 Shoaib Mac Mini. All rights reserved.
//

#import "ViewController.h"
#import "RoundedSlidingButtons.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //--
    
    UIButton* btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    
    UIButton* btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    
    UIButton* btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn3 setImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    
    UIButton* btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn4 setImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    
    UIButton* btn5 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn5 setImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];

    RoundedSlidingButtons* roundedSlidingButton;
    //--
    roundedSlidingButton = [[RoundedSlidingButtons alloc] initWithDirection:kRoundedSliderDirectionAntiClockWise Radius:180 StartingDegree:0 Spacing:20 CenterPosition:CGPointMake(400, 400) ButtonSize:CGSizeMake(40, 40) ParentView:self.view Buttons:btn1, btn2, btn3, btn4, btn5, nil];
} //F.E.

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
} //F.E>

@end
