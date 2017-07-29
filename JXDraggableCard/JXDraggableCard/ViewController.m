//
//  ViewController.m
//  JXDraggableCard
//
//  Created by mac on 17/7/29.
//  Copyright © 2017年 JXIcon. All rights reserved.
//

#import "ViewController.h"
#import "JXDraggableCardContainer.h"
#import "CardView.h"

#define RGB(r, g, b)	 [UIColor colorWithRed: (r) / 255.0 green: (g) / 255.0 blue: (b) / 255.0 alpha : 1]

@interface ViewController ()<JXDraggableCardContainerDelegate, JXDraggableCardContainerDataSource>

@property (nonatomic, strong) JXDraggableCardContainer *container;
@property (nonatomic, strong) NSMutableArray *datas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"卡片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"重置" style:1 target:self action:@selector(resetAction)];
    
    self.view.backgroundColor = RGB(235, 235, 235);
    
    _container = [[JXDraggableCardContainer alloc]init];
    _container.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    _container.backgroundColor = [UIColor clearColor];
    _container.dataSource = self;
    _container.delegate = self;
    _container.canDraggableDirection = JXDraggableDirectionLeft | JXDraggableDirectionRight | JXDraggableDirectionUp;
    [self.view addSubview:_container];
    
    for (int i = 0; i < 4; i++) {
        
        UIView *view = [[UIView alloc]init];
        CGFloat size = self.view.frame.size.width / 4;
        view.frame = CGRectMake(size * i, self.view.frame.size.height - 150, size, size);
        view.backgroundColor = [UIColor clearColor];
        [self.view addSubview:view];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 10, size - 20, size - 20);
        [button setBackgroundColor:RGB(66, 172, 225)];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"Futura-Medium" size:18];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = button.frame.size.width / 2;
        button.tag = i;
        [button addTarget:self action:@selector(buttonTap:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        
        if (i == 0) { [button setTitle:@"Up" forState:UIControlStateNormal]; }
        if (i == 1) { [button setTitle:@"Down" forState:UIControlStateNormal]; }
        if (i == 2) { [button setTitle:@"Left" forState:UIControlStateNormal]; }
        if (i == 3) { [button setTitle:@"Right" forState:UIControlStateNormal]; }
    }
    
    [self loadData];
    
    [_container reloadCardContainer];
    
}


- (void)loadData
{
    _datas = [NSMutableArray array];
    
    for (int i = 0; i < 4; i++) {
        NSDictionary *dict = @{@"image" : [NSString stringWithFormat:@"%d",i + 1],
                               @"name" : @"JXDraggableCardContainer Demo"};
        [_datas addObject:dict];
    }
}

- (void)resetAction{
    [_container reloadCardContainer];
}

#pragma mark -- Selector
- (void)buttonTap:(UIButton *)button
{
    if (button.tag == 0) {
        [_container movePositionWithDirection:JXDraggableDirectionUp isAutomatic:YES undoHandler:nil];
        
    }
    if (button.tag == 1) {
        __weak ViewController *weakself = self;
        [_container movePositionWithDirection:JXDraggableDirectionDown isAutomatic:YES undoHandler:^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                                     message:@"想要重置?"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [weakself.container movePositionWithDirection:JXDraggableDirectionDown isAutomatic:YES undoHandler:nil];
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [weakself.container movePositionWithDirection:JXDraggableDirectionDefault isAutomatic:YES undoHandler:nil];
            }]];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }];
        
    }
    if (button.tag == 2) {
        [_container movePositionWithDirection:JXDraggableDirectionLeft isAutomatic:YES undoHandler:nil];
    }
    if (button.tag == 3) {
        [_container movePositionWithDirection:JXDraggableDirectionRight isAutomatic:YES undoHandler:nil];
    }
    
    
}

#pragma mark -- JXDraggableCardContainer DataSource
- (UIView *)cardContainerViewNextViewWithIndex:(NSInteger)index
{
    NSDictionary *dict = _datas[index];
    CardView *view = [[CardView alloc]initWithFrame:CGRectMake(10, 64, self.view.frame.size.width - 20, self.view.frame.size.width - 20)];
    view.backgroundColor = [UIColor whiteColor];
    view.imageView.image = [UIImage imageNamed:dict[@"image"]];
    view.label.text = [NSString stringWithFormat:@"%@  %ld",dict[@"name"],(long)index];
    return view;
}

- (NSInteger)cardContainerViewNumberOfViewInIndex:(NSInteger)index
{
    return _datas.count;
}

#pragma mark -- JXDraggableCardContainer Delegate
- (void)cardContainerView:(JXDraggableCardContainer *)cardContainerView didEndDraggingAtIndex:(NSInteger)index draggableView:(UIView *)draggableView draggableDirection:(JXDraggableDirection)draggableDirection
{
    if (draggableDirection == JXDraggableDirectionLeft) {
        [cardContainerView movePositionWithDirection:draggableDirection
                                         isAutomatic:NO undoHandler:nil];
    }
    
    if (draggableDirection == JXDraggableDirectionRight) {
        [cardContainerView movePositionWithDirection:draggableDirection
                                         isAutomatic:NO undoHandler:nil];
    }
    
    if (draggableDirection == JXDraggableDirectionUp) {
        [cardContainerView movePositionWithDirection:draggableDirection
                                         isAutomatic:NO undoHandler:nil];
    }
    
}

- (void)cardContainderView:(JXDraggableCardContainer *)cardContainderView updatePositionWithDraggableView:(UIView *)draggableView draggableDirection:(JXDraggableDirection)draggableDirection widthRatio:(CGFloat)widthRatio heightRatio:(CGFloat)heightRatio
{
    CardView *view = (CardView *)draggableView;
    
    if (draggableDirection == JXDraggableDirectionDefault) {
        view.selectedView.alpha = 0;
    }
    
    if (draggableDirection == JXDraggableDirectionLeft) {
        view.selectedView.backgroundColor = RGB(215, 104, 91);
        view.selectedView.alpha = widthRatio > 0.8 ? 0.8 : widthRatio;
    }
    
    if (draggableDirection == JXDraggableDirectionRight) {
        view.selectedView.backgroundColor = RGB(114, 209, 142);
        view.selectedView.alpha = widthRatio > 0.8 ? 0.8 : widthRatio;
    }
    
    if (draggableDirection == JXDraggableDirectionUp) {
        view.selectedView.backgroundColor = RGB(66, 172, 225);
        view.selectedView.alpha = heightRatio > 0.8 ? 0.8 : heightRatio;
    }
}

- (void)cardContainerViewDidCompleteAll:(JXDraggableCardContainer *)container;
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//        [container reloadCardContainer];
    });
}

- (void)cardContainerView:(JXDraggableCardContainer *)cardContainerView didSelectAtIndex:(NSInteger)index draggableView:(UIView *)draggableView
{
    NSLog(@"++ index : %ld",(long)index);
}



@end
