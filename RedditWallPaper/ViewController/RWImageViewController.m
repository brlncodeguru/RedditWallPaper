//
//  RWImageViewController.m
//  RedditWallPaper
//
//  Created by Lakshminarayana B R on 9/4/16.
//  Copyright © 2016 Lakshminarayana B R. All rights reserved.
//

#import "RWImageViewController.h"

@interface RWImageViewController ()

@end

@implementation RWImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imgVwSource;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
