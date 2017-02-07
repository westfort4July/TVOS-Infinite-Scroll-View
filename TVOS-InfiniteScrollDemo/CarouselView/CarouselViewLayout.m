//
//  CarouselViewLayout.m
//  TVOS-InfiniteScrollDemo
//
//  Created by lchen on 07/02/2017.
//  Copyright © 2017 lchen. All rights reserved.
//

#import "CarouselViewLayout.h"
#import "CarouselView.h"

@implementation CarouselViewLayout

- (void)prepareLayout
{
    [super prepareLayout];
    self.itemSize = CGSizeMake(1740.0f, 560.0f);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.minimumLineSpacing = 20.0f;
}

- (CGFloat)totalItemWidth
{
    return self.itemSize.width + self.minimumLineSpacing;
}

- (CGFloat)offsetForItemAtIndex:(NSInteger)index
{
    NSInteger pageSize = 1;
    NSInteger pageIndex = index;
    NSInteger firstItemOnpageIndex = pageSize * pageIndex;
    NSIndexPath *firstItemOnPage = [NSIndexPath indexPathForRow:firstItemOnpageIndex inSection:0];
    UICollectionViewLayoutAttributes *cellLayoutAttributes = [self layoutAttributesForItemAtIndexPath:firstItemOnPage];
    
    if (cellLayoutAttributes)
    {
        CGFloat offset = (self.collectionView.bounds.size.width - pageSize * self.totalItemWidth - self.minimumLineSpacing) * 0.5 + self.minimumLineSpacing;
        return cellLayoutAttributes.frame.origin.x - offset;
    }
    else
    {
        return -MAXFLOAT;
    }
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CarouselView *collectionView = (CarouselView *)self.collectionView;
    CGFloat offset = [self offsetForItemAtIndex:collectionView.currentlyFocusedItem];
    if (offset != -MAXFLOAT)
    {
        return CGPointMake(offset, proposedContentOffset.y);
    }
    else
    {
        return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
    }
}

@end
