//
//  JXCardView.m
//  JXDraggableCard
//
//  Created by mac on 17/7/29.
//  Copyright © 2017年 JXIcon. All rights reserved.
//

#import "JXCardView.h"

@implementation JXCardView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupCardView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCardView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupCardView];
    }
    return self;
}

- (void)setupCardView {
    // Shadow
    //    self.layer.shadowColor = [UIColor blackColor].CGColor;
    //    self.layer.shadowOpacity = 0.33;
    //    self.layer.shadowOffset = CGSizeMake(0, 0);
    //    self.layer.shadowRadius = 0.5;
    
    self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.layer.borderWidth = 0.4f;
    self.layer.shouldRasterize = YES;
    self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    self.layer.cornerRadius = 7.0;
}

@end
