//
//  UXCollectionViewFlowLayout.m
//  YALO
//
//  Created by VanDao on 7/19/16.
//  Copyright © 2016 VNG Corp. All rights reserved.
//

#import "UXCollectionViewFlowLayout.h"
#define kHeight 1000

@interface UXCollectionViewFlowLayout ()

@property (nonatomic, strong, readwrite) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSMutableArray *visibleIndexPath;
@property (nonatomic, assign) CGFloat veciloty;

@end

@implementation UXCollectionViewFlowLayout

- (instancetype)init {
    self = [super init];
    if (self){
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self setup];
    }
    return self;
}

- (void)setup {
    _dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    _visibleIndexPath = [[NSMutableArray alloc] init];
    _veciloty = 0;
    self.minimumLineSpacing = 5.0f;
}

- (void)prepareLayout {
    [super prepareLayout];
    
    // Need to overflow our actual visible rect slightly to avoid flickering.
    CGRect visibleRect = CGRectInset((CGRect){.origin = self.collectionView.bounds.origin, .size = self.collectionView.frame.size}, 0, -100);
    NSArray *visibleItems = [super layoutAttributesForElementsInRect:visibleRect];
    
    NSSet *visibleItemsIndexPaths = [NSSet setWithArray:[visibleItems valueForKey:@"indexPath"]];

    // Step 1: Remove any behaviours that are no longer visible.
    NSArray *invisibleBehaviours = [_dynamicAnimator.behaviors filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behaviour, NSDictionary *bindings) {
        return [visibleItemsIndexPaths containsObject:[(UICollectionViewLayoutAttributes *)[[behaviour items] firstObject] indexPath]] == NO;
    }]];
    [invisibleBehaviours enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [_dynamicAnimator removeBehavior:obj];
        [_visibleIndexPath removeObject:[(UICollectionViewLayoutAttributes *)[[obj items] firstObject] indexPath]];
    }];
    
    // Step 2: Add any newly visible behaviours.
    // A "newly visible" item is one that is in the itemsInVisibleRect(Set|Array) but not in the visibleIndexPathsSet
    NSArray *newlyVisibleItems = [visibleItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        return [_visibleIndexPath containsObject:item.indexPath] == NO;
    }]];
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *item, NSUInteger idx, BOOL *stop) {
        CGPoint center = item.center;
        UIAttachmentBehavior *springBehaviour = [[UIAttachmentBehavior alloc] initWithItem:item attachedToAnchor:center];
        
        springBehaviour.length = 1.0f;
        springBehaviour.damping = 0.5f;
        springBehaviour.frequency = 1.0f;
        
        CGFloat distanceFromTouch = fabs(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / kHeight;
        center.y += _veciloty < 0 ? MAX(_veciloty, _veciloty * scrollResistance) : MIN(_veciloty, _veciloty * scrollResistance);
        
        item.center = center;
        
        [_dynamicAnimator addBehavior:springBehaviour];
        [_visibleIndexPath addObject:item.indexPath];
    }];
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [_dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *dynamicLayoutAttributes = [_dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
    return (dynamicLayoutAttributes) ? dynamicLayoutAttributes : [super layoutAttributesForItemAtIndexPath:indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    _veciloty = newBounds.origin.y - self.collectionView.bounds.origin.y;
    
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        CGFloat distanceFromTouch = fabs(touchLocation.y - springBehaviour.anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / (kHeight);
        
        id item = (UICollectionViewLayoutAttributes *)([springBehaviour.items firstObject]);
        CGPoint center = ((UICollectionViewLayoutAttributes *)item).center;
        center.y += _veciloty < 0 ? MAX(_veciloty, _veciloty * scrollResistance) : MIN(_veciloty, _veciloty * scrollResistance);
        
        ((UICollectionViewLayoutAttributes *)item).center = center;
        
        [self.dynamicAnimator updateItemUsingCurrentState:item];
    }];
    
    return NO;
}

@end
