//
//  ViewController.m
//  TVOS-InfiniteScrollDemo
//
//  Created by lchen on 07/02/2017.
//  Copyright © 2017 lchen. All rights reserved.
//

#import "ViewController.h"
#import "CarouselView.h"

@interface ViewController ()<CarouselViewDelegate>

@property (nonatomic, strong) CarouselView *carouselView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.carouselView = [[CarouselView alloc] initWithFrame:CGRectMake(0.0f, 300.0f, self.view.bounds.size.width, 608.0f)];
    self.carouselView.backgroundColor= [UIColor whiteColor];
    self.carouselView.carouselDelegate = self;
    self.carouselView.carouselContentArray = @[@"red", @"organge", @"yellow", @"green", @"blue"];
    self.carouselView.autoScroll = YES;
    [self.view addSubview:self.carouselView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.carouselView.frame = CGRectMake(0.0f, 300.0f, CGRectGetWidth(self.view.bounds), 608.0f);
}

- (void)clickedCarouselViewAtIndex:(NSInteger)index
{
    NSLog(@"*******%ld*********", index);
}

@end
