//
//  CarouselView.h
//  TVOS-InfiniteScrollDemo
//
//  Created by lchen on 07/02/2017.
//  Copyright © 2017 lchen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@protocol CarouselViewDelegate <NSObject>

- (void)clickedCarouselViewAtIndex:(NSInteger)index;

@end

@interface CarouselView : UICollectionView

@property (nonatomic, strong)   NSArray                     *carouselContentArray;
// current focused item index
@property (nonatomic, readonly) NSInteger                   currentlyFocusedItem;
@property (nonatomic, assign)   BOOL                        autoScroll;
@property (nonatomic, weak)     id<CarouselViewDelegate> carouselDelegate;

@end
