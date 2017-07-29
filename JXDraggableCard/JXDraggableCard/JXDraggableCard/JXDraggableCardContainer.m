//
//  JXDraggableCardContainer.m
//  JXDraggableCard
//
//  Created by mac on 17/7/29.
//  Copyright © 2017年 JXIcon. All rights reserved.
//

#import "JXDraggableCardContainer.h"

static CGFloat const kPreloadViewCount = 3.0f;// 当前显示卡片总个数
static CGFloat const kSecondCard_Scale = 0.98f;// 第二个的卡片缩放大小
static CGFloat const kTherdCard_Scale = 0.96f; // 第三个的卡片缩放大小
static CGFloat const kCard_Margin = 7.0f;  // 卡片的Y值递增间距
static CGFloat const kDragCompleteCoefficient_width_default = 0.8f;
static CGFloat const kDragCompleteCoefficient_height_default = 0.6f;

typedef NS_ENUM(NSInteger, MoveSlope) {
    MoveSlopeTop = 1,
    MoveSlopeBottom = -1
};

@interface JXDraggableCardContainer ()

@property (nonatomic, assign) MoveSlope moveSlope;
@property (nonatomic, assign) CGRect defaultFrame; // 最前面cardView的frame
@property (nonatomic, assign) CGFloat cardCenterX;
@property (nonatomic, assign) CGFloat cardCenterY;
@property (nonatomic, assign) NSInteger loadedIndex;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) NSMutableArray *currentViews;
@property (nonatomic, assign) BOOL isInitialAnimation; // 是否可以拖拽动画


@end

@implementation JXDraggableCardContainer
#pragma mark - lazy load
- (NSMutableArray *)currentViews{
    if (_currentViews == nil) {
        _currentViews = [NSMutableArray array];
    }
    return _currentViews;
}

#pragma mark - init
- (id)init
{
    self = [super init];
    if (self) {
        [self setUp];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cardViewTap:)];
        [self addGestureRecognizer:tapGesture];
        
        _canDraggableDirection = JXDraggableDirectionLeft | JXDraggableDirectionLeft;
    }
    return self;
}

- (void)setUp
{
    _moveSlope = MoveSlopeTop;
    _loadedIndex = 0.0f;
    _currentIndex = 0.0f;
}

#pragma mark -- Public
-(void)reloadCardContainer
{
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    [self.currentViews removeAllObjects];
    
    [self setUp];
    /// 布局卡片
    [self loadNextView];
    _isInitialAnimation = NO;
    [self viewInitialAnimation];
}

- (UIView *)getCurrentView
{
    return [self.currentViews firstObject];
}

- (void)movePositionWithDirection:(JXDraggableDirection)direction isAutomatic:(BOOL)isAutomatic undoHandler:(void (^)())undoHandler
{
    [self cardViewDirectionAnimation:direction isAutomatic:isAutomatic undoHandler:undoHandler];
}



#pragma mark -- Private
/// 布局卡片
- (void)loadNextView{
    
    // 1.几个卡片
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(cardContainerViewNumberOfViewInIndex:)]) {
        
        NSInteger index = [self.dataSource cardContainerViewNumberOfViewInIndex:_loadedIndex];
        
        // 2.判断是否是布局完所有的卡片
        if (index != 0 && index == _currentIndex) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardContainerViewDidCompleteAll:)]) {
                
                [self.delegate cardContainerViewDidCompleteAll:self];
            }
        }
        
        // 3.添加下一个卡片
        if (_loadedIndex < index) {
            
            // index如果小于三个就显示index的个数，大于3个最多显示三个
            NSInteger preloadViewCont = index <= kPreloadViewCount ? index : kPreloadViewCount;
            
            for (NSInteger i = self.currentViews.count; i < preloadViewCont; i++) {
                
                if (self.dataSource && [self.dataSource respondsToSelector:@selector(cardContainerViewNextViewWithIndex:)]) {
                    
                    UIView *view = [self.dataSource cardContainerViewNextViewWithIndex:_loadedIndex];
                    
                    if (view) {
                        _defaultFrame = view.frame;
                        _cardCenterX = view.center.x;
                        _cardCenterY = view.center.y;
                        
                        [self addSubview:view];
                        // 将一个View推送到背后
                        [self sendSubviewToBack:view];
                        [self.currentViews addObject:view];
                    
                        // 第二个卡片的位置
                        if (i == 1 && _currentIndex != 0) {
                            view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + kCard_Margin, _defaultFrame.size.width, _defaultFrame.size.height);
                            view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kSecondCard_Scale,kSecondCard_Scale);
                        }
                        
                        // 第三个卡片位置
                        if (i == 2 && _currentIndex != 0) {
                            view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + (kCard_Margin * 2), _defaultFrame.size.width, _defaultFrame.size.height);
                            view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kTherdCard_Scale,kTherdCard_Scale);
                        }
                        
                        // 加1
                        _loadedIndex++;
                        _currentIndex++;
                    }
                    
                }
            }
            
            
        }
        
        // 最外卡片添加pan手势
        UIView *view = [self getCurrentView];
        if (view) {
            UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
            [view addGestureRecognizer:gesture];
        }
        
        
    }
    
}


- (void)viewInitialAnimation{
    
    for (UIView *view  in self.currentViews) {
        view.alpha = 0.0;
    }
    
    UIView *view = [self getCurrentView];
    if (!view) { return; }
    __weak JXDraggableCardContainer *weakself = self;
    
    view.alpha = 1.0;
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.5f,0.5f);
    
    // 实现连续的动画
    /*！
     completion为动画执行完毕以后执行的代码块
     options为动画执行的选项。可以参考这里
     delay为动画开始执行前等待的时间
     */
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.05f,1.05f);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
             view.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.95f,0.95f);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0f,1.0f);
                
            } completion:^(BOOL finished) {
                
                for (UIView *view in self.currentViews) {
                    view.alpha = 1.0;
                }
                
                [UIView animateWithDuration:0.25f delay:0.01f options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction animations:^{
                    
                    [weakself cardViewDefaultScale];
                    
                } completion:^(BOOL finished) {
                    
                    weakself.isInitialAnimation = YES;
                    
                }];
                
                
            }];
            
        }];
        
    }];
    
    
}




/**
 卡片动画处理

 @param direction 方向
 @param isAutomatic 是否要形变
 @param undoHandler 完成动画block
 */
- (void)cardViewDirectionAnimation:(JXDraggableDirection)direction isAutomatic:(BOOL)isAutomatic undoHandler:(void (^)())undoHandler{
    
    if (!_isInitialAnimation) { return; }
    UIView *view = [self getCurrentView];
    if (!view) { return; }
    
    __weak typeof(self) weakself = self;
    
    if (direction == JXDraggableDirectionDefault) {
        view.transform = CGAffineTransformIdentity;
        // 回弹效果的动画
        /**!
         usingSpringWithDamping：表示弹性属性
         initialSpringVelocity：初速度
         options：可选项，一些可选的动画效果，包括重复等
         
         1.常规动画属性设置（可以同时选择多个进行设置）
         UIViewAnimationOptionLayoutSubviews：动画过程中保证子视图跟随运动。**提交动画的时候布局子控件，表示子控件将和父控件一同动画。**
         UIViewAnimationOptionAllowUserInteraction：动画过程中允许用户交互。
         UIViewAnimationOptionBeginFromCurrentState：所有视图从当前状态开始运行。
         UIViewAnimationOptionRepeat：重复运行动画。
         UIViewAnimationOptionAutoreverse ：动画运行到结束点后仍然以动画方式回到初始点。**执行动画回路,前提是设置动画无限重复**
         UIViewAnimationOptionOverrideInheritedDuration：忽略嵌套动画时间设置。**忽略外层动画嵌套的时间变化曲线**
         UIViewAnimationOptionOverrideInheritedCurve：忽略嵌套动画速度设置。**通过改变属性和重绘实现动画效果，如果key没有提交动画将使用快照**
         UIViewAnimationOptionAllowAnimatedContent：动画过程中重绘视图（注意仅仅适用于转场动画）。
         UIViewAnimationOptionShowHideTransitionViews：视图切换时直接隐藏旧视图、显示新视图，而不是将旧视图从父视图移除（仅仅适用于转场动画）**用显隐的方式替代添加移除图层的动画效果**
         UIViewAnimationOptionOverrideInheritedOptions ：不继承父动画设置或动画类型。**忽略嵌套继承的选项**
         ----------------------------------------------------------------------------
         2.动画速度控制（可从其中选择一个设置）时间函数曲线相关**时间曲线函数**
         UIViewAnimationOptionCurveEaseInOut：动画先缓慢，然后逐渐加速。
         UIViewAnimationOptionCurveEaseIn ：动画逐渐变慢。
         UIViewAnimationOptionCurveEaseOut：动画逐渐加速。
         UIViewAnimationOptionCurveLinear ：动画匀速执行，默认值。
         -----------------------------------------------------------------------------
         3.转场类型（仅适用于转场动画设置，可以从中选择一个进行设置，基本动画、关键帧动画不需要设置）**转场动画相关的**
         UIViewAnimationOptionTransitionNone：没有转场动画效果。
         UIViewAnimationOptionTransitionFlipFromLeft ：从左侧翻转效果。
         UIViewAnimationOptionTransitionFlipFromRight：从右侧翻转效果。
         UIViewAnimationOptionTransitionCurlUp：向后翻页的动画过渡效果。
         UIViewAnimationOptionTransitionCurlDown ：向前翻页的动画过渡效果。
         UIViewAnimationOptionTransitionCrossDissolve：旧视图溶解消失显示下一个新视图的效果。
         UIViewAnimationOptionTransitionFlipFromTop ：从上方翻转效果。
         UIViewAnimationOptionTransitionFlipFromBottom：从底部翻转效果。
         
         补充：关于最后一组转场动画它一般是用在这个方法中的：
         　　　　[UIView transitionFromView: toView: duration: options:  completion:^(****BOOL****finished) {}];
         该方法效果是插入一面视图移除一面视图，期间可以使用一些转场动画效果。
         
         
         */
        
        [UIView animateWithDuration:0.55
                              delay:0.0
             usingSpringWithDamping:0.6
              initialSpringVelocity:0.0
                            options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             view.frame = _defaultFrame;
                             
                             [weakself cardViewDefaultScale];
                         } completion:^(BOOL finished) {
                         }];
        
        return;
    }
    
    if (!undoHandler) {
        [self.currentViews removeObject:view];
        _currentIndex++;
        [self loadNextView];
    }
    
    
    if (direction == JXDraggableDirectionRight || direction == JXDraggableDirectionLeft || direction == JXDraggableDirectionDown) {
        
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             if (direction == JXDraggableDirectionLeft) {
                                 view.center = CGPointMake(-1 * (weakself.frame.size.width), view.center.y);
                                 
                                 if (isAutomatic) {
                                     view.transform = CGAffineTransformMakeRotation(-1 * M_PI_4);
                                 }
                             }
                             
                             if (direction == JXDraggableDirectionRight) {
                                 view.center = CGPointMake((weakself.frame.size.width * 2), view.center.y);
                                 
                                 if (isAutomatic) {
                                     view.transform = CGAffineTransformMakeRotation(direction * M_PI_4);
                                 }
                             }
                             
                             if (direction == JXDraggableDirectionDown) {
                                 view.center = CGPointMake(view.center.x, (weakself.frame.size.height * 1.5));
                             }
                             
                             if (!undoHandler) {
                                 [weakself cardViewDefaultScale];
                             }
                             
                         } completion:^(BOOL finished) {
                             if (!undoHandler) {
                                 [view removeFromSuperview];
                                 
                             } else  {
                                 if (undoHandler) { undoHandler(); }
                             }
                         }];
    }
    
    if (direction == JXDraggableDirectionUp) {
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             
                             if (direction == JXDraggableDirectionUp) {
                                 if (isAutomatic) {
                                     view.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.03,0.97);
                                     view.center = CGPointMake(view.center.x, view.center.y + kCard_Margin);
                                 }
                             }
                             
                         } completion:^(BOOL finished) {
                             [UIView animateWithDuration:0.35
                                                   delay:0.0
                                                 options:UIViewAnimationOptionCurveLinear | UIViewAnimationOptionAllowUserInteraction
                                              animations:^{
                                                  view.center = CGPointMake(view.center.x, -1 * ((weakself.frame.size.height) / 2));
                                                  [weakself cardViewDefaultScale];
                                              } completion:^(BOOL finished) {
                                                  if (!undoHandler) {
                                                      [view removeFromSuperview];
                                                  } else  {
                                                      if (undoHandler) { undoHandler(); }
                                                  }
                                              }];
                         }];
    }

    
}

#pragma mark -- Gesture Selector

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture{
    if (!_isInitialAnimation) { return; }
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint touchPoint = [gesture locationInView:self];
            if (touchPoint.y <= _cardCenterY) {
                _moveSlope = MoveSlopeTop;
            } else {
                _moveSlope = MoveSlopeBottom;
            }
        }
            break;
            
            
        case UIGestureRecognizerStateChanged:
        {
            CGPoint point = [gesture translationInView:self];
            CGPoint movedPoint = CGPointMake(gesture.view.center.x + point.x, gesture.view.center.y + point.y);
            gesture.view.center = movedPoint;
            
            [gesture.view setTransform:
             CGAffineTransformMakeRotation((gesture.view.center.x - _cardCenterX) / _cardCenterX * (_moveSlope * (M_PI / 20)))];
            
            [self cardViewUpDateScale];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(cardContainderView:updatePositionWithDraggableView:draggableDirection:widthRatio:heightRatio:)]) {
                
                if ([self getCurrentView]) {
                    
                    float ratio_w = (gesture.view.center.x - _cardCenterX) / _cardCenterX;
                    float ratio_h = (gesture.view.center.y - _cardCenterY) / _cardCenterY;
                    
                    JXDraggableDirection direction = JXDraggableDirectionDefault;
                    
                    if (fabs(ratio_h) > fabs(ratio_w)) {
                        
                        if (ratio_h <= 0) {
                            // up
                            if (_canDraggableDirection & JXDraggableDirectionUp) {
                                direction = JXDraggableDirectionUp;
                            } else {
                                direction = ratio_w <= 0 ? JXDraggableDirectionLeft : JXDraggableDirectionRight;
                            }
                            
                        } else {
                            // down
                            if (_canDraggableDirection & JXDraggableDirectionDown) {
                                direction = JXDraggableDirectionDown;
                            } else {
                                direction = ratio_w <= 0 ? JXDraggableDirectionLeft : JXDraggableDirectionRight;
                            }
                        }
                        
                    } else {
                        if (ratio_w <= 0) {
                            // left
                            if (_canDraggableDirection & JXDraggableDirectionLeft) {
                                direction = JXDraggableDirectionLeft;
                            } else {
                                direction = ratio_h <= 0 ? JXDraggableDirectionUp : JXDraggableDirectionDown;
                            }
                        } else {
                            // right
                            if (_canDraggableDirection & JXDraggableDirectionRight) {
                                direction = JXDraggableDirectionRight;
                            } else {
                                direction = ratio_h <= 0 ? JXDraggableDirectionUp : JXDraggableDirectionDown;
                            }
                        }
                        
                    }
                    
                    [self.delegate cardContainderView:self updatePositionWithDraggableView:gesture.view
                                   draggableDirection:direction
                                           widthRatio:fabs(ratio_w) heightRatio:fabsf(ratio_h)];
                }
            }
            
            [gesture setTranslation:CGPointZero inView:self];
                
            
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        {
            float ratio_w = (gesture.view.center.x - _cardCenterX) / _cardCenterX;
            float ratio_h = (gesture.view.center.y - _cardCenterY) / _cardCenterY;
            
            JXDraggableDirection direction = JXDraggableDirectionDefault;
            if (fabs(ratio_h) > fabs(ratio_w)) {
                if (ratio_h < - kDragCompleteCoefficient_height_default && (_canDraggableDirection & JXDraggableDirectionUp)) {
                    // up
                    direction = JXDraggableDirectionUp;
                }
                
                if (ratio_h > kDragCompleteCoefficient_height_default && (_canDraggableDirection & JXDraggableDirectionDown)) {
                    // down
                    direction = JXDraggableDirectionDown;
                }
                
            } else {
                
                if (ratio_w > kDragCompleteCoefficient_width_default && (_canDraggableDirection & JXDraggableDirectionRight)) {
                    // right
                    direction = JXDraggableDirectionRight;
                }
                
                if (ratio_w < - kDragCompleteCoefficient_width_default && (_canDraggableDirection & JXDraggableDirectionLeft)) {
                    // left
                    direction = JXDraggableDirectionLeft;
                }
            }
            
            if (direction == JXDraggableDirectionDefault) {
                [self cardViewDirectionAnimation:JXDraggableDirectionDefault isAutomatic:NO undoHandler:nil];
            } else {
                if (self.delegate && [self.delegate respondsToSelector:@selector(cardContainerView:didEndDraggingAtIndex:draggableView:draggableDirection:)]) {
                    [self.delegate cardContainerView:self didEndDraggingAtIndex:_currentIndex draggableView:gesture.view draggableDirection:direction];
                }
            }

        }
            break;
            

        default:
            break;
    }
}

/// 点击卡片
- (void)cardViewTap:(UITapGestureRecognizer *)gesture
{
    if (!self.currentViews || self.currentViews.count == 0) {
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardContainerView:didSelectAtIndex:draggableView:)]) {
        [self.delegate cardContainerView:self didSelectAtIndex:_currentIndex draggableView:gesture.view];
    }
}



#pragma mark - 卡片形变
/// 默认形变
- (void)cardViewDefaultScale{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cardContainderView:updatePositionWithDraggableView:draggableDirection:widthRatio:heightRatio:)]) {
        
        [self.delegate cardContainderView:self updatePositionWithDraggableView:[self getCurrentView]
                       draggableDirection:JXDraggableDirectionDefault
                               widthRatio:0 heightRatio:0];
    }
    
    
    for (int i = 0; i < self.currentViews.count; i ++) {
        UIView *view = self.currentViews[i];
        if (i == 0) {
            view.transform = CGAffineTransformIdentity;
            view.frame = _defaultFrame;
        }
        
        if (i == 1) {
            view.transform = CGAffineTransformIdentity;
            view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + kCard_Margin, _defaultFrame.size.width, _defaultFrame.size.height);
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kSecondCard_Scale,kSecondCard_Scale);
        }
        if (i == 2) {
            view.transform = CGAffineTransformIdentity;
            view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + (kCard_Margin * 2), _defaultFrame.size.width, _defaultFrame.size.height);
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kTherdCard_Scale,kTherdCard_Scale);
        }
    }
    
}


/// 更新每一张卡片的形变
- (void)cardViewUpDateScale{
    UIView *view = [self getCurrentView];
    
    float ratio_w = fabs((view.center.x - _cardCenterX) / _cardCenterX);
    float ratio_h = fabs((view.center.y - _cardCenterY) / _cardCenterY);
    float ratio = ratio_w > ratio_h ? ratio_w : ratio_h;
    
    // 两张卡片的时候
    if (self.currentViews.count == 2) {
        if (ratio <= 1) {
            UIView *view = self.currentViews[1];
            view.transform = CGAffineTransformIdentity;
            view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + (kCard_Margin - (ratio * kCard_Margin)), _defaultFrame.size.width, _defaultFrame.size.height);
            
            view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kSecondCard_Scale + (ratio * (1 - kSecondCard_Scale)),kSecondCard_Scale + (ratio * (1 - kSecondCard_Scale)));
        }
    }
    
    /// 三张卡片的时候
    if (self.currentViews.count == 3) {
        if (ratio <= 1) {
            {
                UIView *view = self.currentViews[1];
                view.transform = CGAffineTransformIdentity;
                view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + (kCard_Margin - (ratio * kCard_Margin)), _defaultFrame.size.width, _defaultFrame.size.height);
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kSecondCard_Scale + (ratio * (1 - kSecondCard_Scale)),kSecondCard_Scale + (ratio * (1 - kSecondCard_Scale)));
            }
            {
                UIView *view = self.currentViews[2];
                view.transform = CGAffineTransformIdentity;
                view.frame = CGRectMake(_defaultFrame.origin.x, _defaultFrame.origin.y + ((kCard_Margin * 2) - (ratio * kCard_Margin)), _defaultFrame.size.width, _defaultFrame.size.height);
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity,kTherdCard_Scale + (ratio * (kSecondCard_Scale - kTherdCard_Scale)),kTherdCard_Scale + (ratio * (kSecondCard_Scale - kTherdCard_Scale)));
            }
        }
    }
    
    
    
}



@end
