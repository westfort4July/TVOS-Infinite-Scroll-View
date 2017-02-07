//
//  CarouselViewLayout.h
//  TVOS-InfiniteScrollDemo
//
//  Created by lchen on 07/02/2017.
//  Copyright © 2017 lchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarouselViewLayout : UICollectionViewFlowLayout

- (CGFloat)totalItemWidth;

- (CGFloat)offsetForItemAtIndex:(NSInteger)index;

@end
