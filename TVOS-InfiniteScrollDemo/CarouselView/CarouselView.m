//
//  CarouselView.m
//  TVOS-InfiniteScrollDemo
//
//  Created by lchen on 07/02/2017.
//  Copyright © 2017 lchen. All rights reserved.
//

#import "CarouselView.h"
#import "CarouselViewCell.h"
#import "CarouselViewLayout.h"

typedef NS_ENUM(NSUInteger, JumDirection)
{
    JumpForward,
    JumpBackward,
};

typedef NS_ENUM(NSUInteger, VisibleStatus)
{
    VisibleStatusUnknow,
    VisibleStatusTrue,
    VisibleStatusFalse,
};

@interface CarouselView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) CarouselViewLayout *layout;

@property (nonatomic, assign) BOOL jumping;

@property (nonatomic, assign) UIFocusHeading focusHeading;

@property (nonatomic, strong) NSIndexPath *manualFocusCell;

@property (nonatomic, assign) NSInteger initiallyFocusedItem;

@property (nonatomic, assign) NSInteger currentlyFocusedItem;

@property (nonatomic, assign) VisibleStatus visibleStatus;

@end

@implementation CarouselView
static NSString *reuseIdentifier = @"CarouselModuleCell";
static const NSInteger buffer = 2;


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame collectionViewLayout:[[CarouselViewLayout alloc] init]])
    {
        self.layout = (CarouselViewLayout *)self.collectionViewLayout;
        [self registerClass:[CarouselViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
        self.delegate = self;
        self.dataSource = self;
        self.visibleStatus = VisibleStatusUnknow;
    }
    return self;
}

- (NSIndexPath *)adjustedIndexPathForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.item;
    NSInteger wrapped = (row - buffer < 0) ? (self.carouselContentArray.count + (row - buffer)) : (row - buffer);
    NSInteger adjustedRow = wrapped % self.carouselContentArray.count;
    return [NSIndexPath indexPathForItem:adjustedRow inSection:0];
}

- (void)setCarouselContentArray:(NSArray *)carouselContentArray
{
    _carouselContentArray = carouselContentArray;
    [self reloadData];
    [self setNeedsFocusUpdate];
}

- (void)reloadData
{
    [super reloadData];
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self scrollToItemAtIndex:buffer animated:NO];
                       if (self.visibleStatus == VisibleStatusUnknow)
                       {
                           self.visibleStatus = VisibleStatusTrue;
                       }
                       if (self.visibleStatus == VisibleStatusTrue)
                       {
                           [self beginAutoScroll];
                       }
                   });
}

#pragma mark - focus

- (BOOL)collectionView:(UICollectionView *)collectionView shouldUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context
{
    NSIndexPath *toIndexPath = context.nextFocusedIndexPath;
    if (!toIndexPath)
    {
        [self beginAutoScroll];
        return YES;
    }
    
    if (!context.previouslyFocusedIndexPath)
    {
        if (self.visibleStatus == VisibleStatusUnknow)
        {
            self.visibleStatus = VisibleStatusFalse;
        }
        [self stopAutoScroll];
        return YES;
    }
    
    if ((self.initiallyFocusedItem != 0) && ABS(toIndexPath.item - self.initiallyFocusedItem) > 1)
    {
        return NO;
    }
    self.focusHeading = context.focusHeading;
    self.currentlyFocusedItem = toIndexPath.row;
    if (self.focusHeading == UIFocusHeadingLeft && toIndexPath.row < buffer)
    {
        self.jumping = YES;
        self.currentlyFocusedItem += self.carouselContentArray.count;
    }
    
    if (self.focusHeading == UIFocusHeadingRight && toIndexPath.row > buffer + self.carouselContentArray.count)
    {
        self.jumping = YES;
        self.currentlyFocusedItem -= self.carouselContentArray.count;
    }
    
    self.manualFocusCell = [NSIndexPath indexPathForRow:self.currentlyFocusedItem inSection:0];
    return YES;
    
}

- (NSIndexPath *)indexPathForPreferredFocusedViewInCollectionView:(UICollectionView *)collectionView
{
    return self.manualFocusCell;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator
{
    if (!self.jumping)
    {
        return;
    }
    self.jumping = NO;
    
    if (self.focusHeading == UIFocusHeadingLeft)
    {
        [self jump:JumpForward];
    }
    else
    {
        [self jump:JumpBackward];
    }
    self.currentlyFocusedItem = self.manualFocusCell.row;
    [self setNeedsFocusUpdate];
}

#pragma mark - UICollectionView delegate & dataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.carouselContentArray.count + 2 * buffer;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *adjustedIndexPath = [self adjustedIndexPathForIndexPath:indexPath];
    CarouselViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:adjustedIndexPath];
    cell.titleString = self.carouselContentArray[adjustedIndexPath.row];
    cell.index = adjustedIndexPath.row;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    CarouselViewCell *cell = (CarouselViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([self.carouselDelegate respondsToSelector:@selector(clickedCarouselViewAtIndex:)])
    {
        [self.carouselDelegate clickedCarouselViewAtIndex:cell.index];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self beginAutoScroll];
}

#pragma mark - touches handler

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.initiallyFocusedItem = self.currentlyFocusedItem;
    [super touchesBegan:touches withEvent:event];
}

- (void)scrollToItemAtIndex:(NSInteger)index animated:(BOOL)animated
{
    CGFloat initialOffset = [self.layout offsetForItemAtIndex:index];
    if (initialOffset != -MAXFLOAT)
    {
        [self setContentOffset:CGPointMake(initialOffset, self.contentOffset.y) animated:animated];
    }
    self.currentlyFocusedItem = index;
    self.manualFocusCell = [NSIndexPath indexPathForRow:self.currentlyFocusedItem inSection:0];
    [self setNeedsFocusUpdate];
}

- (void)beginAutoScroll
{
    if (self.autoScroll)
    {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(scrollToNextPage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

- (void)stopAutoScroll
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)scrollToNextPage
{
    NSInteger nextItemIndex = self.currentlyFocusedItem + 1;
    if (nextItemIndex >= buffer + self.carouselContentArray.count)
    {
        nextItemIndex -= self.carouselContentArray.count;
        [self jump:JumpBackward];
    }
    [self scrollToItemAtIndex:nextItemIndex animated:YES];
}

#pragma mark - jump

- (void)jump:(JumDirection)direction
{
    CGFloat currentOffset = self.contentOffset.x;
    CGFloat jumpOffset = self.carouselContentArray.count * self.layout.totalItemWidth;
    if (direction == JumpBackward)
    {
        jumpOffset *= -1;
    }
    [self setContentOffset:CGPointMake(currentOffset + jumpOffset, self.contentOffset.y) animated:NO];
}

- (void)dealloc
{
    [self.timer invalidate];
    self.timer = nil;
}


@end
