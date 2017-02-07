//
//  CarouselViewCell.h
//  TVOS-InfiniteScrollDemo
//
//  Created by lchen on 07/02/2017.
//  Copyright © 2017 lchen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarouselViewCell : UICollectionViewCell

@property (nonatomic, copy) NSString *titleString;
@property (nonatomic, assign) NSInteger index;

@end
