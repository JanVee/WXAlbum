//
//  JanFlowLayout.m
//  WXAlbum
//
//  Created by Jan on 15/8/16.
//  Copyright (c) 2015年 Jan. All rights reserved.
//

#import "JanFlowLayout.h"

#define kHorizontalCheckmarkInset 4.0
#define kVericalCheckmarkInset 2.0

@implementation JanFlowLayout

#pragma mark - 当边界发生改变时，是否应该刷新布局。如果YES则在边界变化（一般是scroll到其他地方）时，将重新计算需要的布局信息。
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

/**
1: 返回rect中的所有的元素的布局属性
2: 返回的是包含UICollectionViewLayoutAttributes的NSArray
3: UICollectionViewLayoutAttributes可以是cell，追加视图或装饰视图的信息，
4: 通过不同的UICollectionViewLayoutAttributes初始化方法可以得到不同类型的UICollectionViewLayoutAttributes：
 
 layoutAttributesForCellWithIndexPath:
 layoutAttributesForSupplementaryViewOfKind:withIndexPath:
 layoutAttributesForDecorationViewOfKind:withIndexPath:
 
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect;
{
    NSMutableArray *attributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    for (UICollectionViewLayoutAttributes *attrs in [attributes copy]) {
        [attributes addObject:[self layoutAttributesForSupplementaryViewOfKind:@"check" atIndexPath:attrs.indexPath]];
    }
    return attributes;
}

/**
 UICollectionViewLayout的功能为向UICollectionView提供布局信息，
 不仅包括cell的布局信息，也包括追加视图和装饰视图的布局信息。
 实现一个自定义layout的常规做法是继承UICollectionViewLayout类
 */

#pragma mark - 重写layoutAttributesForSupplementaryViewOfKind方法,返回对应于indexPath的位置的追加视图的布局属性

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CGRect collectionViewBounds = self.collectionView.bounds;
    CGFloat collectionViewXOffset = self.collectionView.contentOffset.x;
    UICollectionViewLayoutAttributes *cellAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
    UICollectionViewLayoutAttributes *checkAttributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    checkAttributes.size = CGSizeMake(28, 28);
    checkAttributes.zIndex = 100;
    CGFloat checkVerticalCenter = checkAttributes.size.height/2+3;
    checkAttributes.center = (CGPoint){
        CGRectGetMaxX(cellAttributes.frame) - kHorizontalCheckmarkInset - checkAttributes.size.width/2,
        checkVerticalCenter
    };
    CGFloat leftSideOfCell = CGRectGetMinX(cellAttributes.frame);
    CGFloat rightSideOfVisibleArea = collectionViewXOffset + CGRectGetWidth(collectionViewBounds);
    if (leftSideOfCell < rightSideOfVisibleArea && CGRectGetMaxX(checkAttributes.frame) >= rightSideOfVisibleArea) {
        checkAttributes.center = (CGPoint){
            rightSideOfVisibleArea - checkAttributes.size.width/2,
            checkVerticalCenter
        };
    }
    if (CGRectGetMinX(checkAttributes.frame) < leftSideOfCell + kHorizontalCheckmarkInset) {
        checkAttributes.center = (CGPoint) {
            leftSideOfCell + kHorizontalCheckmarkInset + checkAttributes.size.width/2,
            checkVerticalCenter
        };
    }
    return checkAttributes;
}
@end
