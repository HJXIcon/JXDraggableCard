//
//  JXDraggableCardContainer.h
//  JXDraggableCard
//
//  Created by mac on 17/7/29.
//  Copyright © 2017年 JXIcon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JXDraggableCardContainer;

typedef NS_OPTIONS(NSInteger, JXDraggableDirection) {
    JXDraggableDirectionDefault     = 0,
    JXDraggableDirectionLeft        = 1 << 0,
    JXDraggableDirectionRight       = 1 << 1,
    JXDraggableDirectionUp          = 1 << 2,
    JXDraggableDirectionDown        = 1 << 3
};



@protocol JXDraggableCardContainerDataSource <NSObject>

- (UIView *)cardContainerViewNextViewWithIndex:(NSInteger)index;
- (NSInteger)cardContainerViewNumberOfViewInIndex:(NSInteger)index;


@end


@protocol JXDraggableCardContainerDelegate <NSObject>
/// 拖拽结束或者取消
- (void)cardContainerView:(JXDraggableCardContainer *)cardContainerView
    didEndDraggingAtIndex:(NSInteger)index
            draggableView:(UIView *)draggableView
       draggableDirection:(JXDraggableDirection)draggableDirection;

@optional

/// 布局完所有的卡片
- (void)cardContainerViewDidCompleteAll:(JXDraggableCardContainer *)container;

/// 选中卡片
- (void)cardContainerView:(JXDraggableCardContainer *)cardContainerView
         didSelectAtIndex:(NSInteger)index
            draggableView:(UIView *)draggableView;

/// 更新卡片位置形变
- (void)cardContainderView:(JXDraggableCardContainer *)cardContainderView updatePositionWithDraggableView:(UIView *)draggableView draggableDirection:(JXDraggableDirection)draggableDirection widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio;

@end


@interface JXDraggableCardContainer : UIView

/// 默认 JXDraggableDirectionLeft | JXDraggableDirectionRight
@property (nonatomic, assign) JXDraggableDirection canDraggableDirection;


@property (nonatomic, weak) id <JXDraggableCardContainerDataSource> dataSource;
@property (nonatomic, weak) id <JXDraggableCardContainerDelegate> delegate;

- (void)reloadCardContainer;


/**
 移除卡片

 @param direction 方向
 @param isAutomatic 是否自动
 @param undoHandler 完成block
 */
- (void)movePositionWithDirection:(JXDraggableDirection)direction isAutomatic:(BOOL)isAutomatic undoHandler:(void (^)())undoHandler;

@end
