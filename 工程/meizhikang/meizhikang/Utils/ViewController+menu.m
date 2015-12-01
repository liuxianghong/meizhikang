//
//  ViewController+menu.m
//  meizhikang
//
//  Created by 刘向宏 on 15/11/28.
//  Copyright © 2015年 刘向宏. All rights reserved.
//

#import "ViewController+menu.h"
#import "SWRevealViewController.h"

@implementation UIViewController (menu)

-(IBAction)menuAciton:(id)sender
{
    if (self.revealViewController){
        [self.revealViewController revealToggle:sender];
    }
}
@end


@implementation UINavigationController (Light)

-(IBAction)menuAciton:(id)sender
{
    if (self.revealViewController){
        [self.revealViewController revealToggle:sender];
    }
}


-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
@end
