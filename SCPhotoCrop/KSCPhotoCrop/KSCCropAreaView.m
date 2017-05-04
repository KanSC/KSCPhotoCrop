//
//  SCCropAreaView.m
//  SCPhotoCropEditor
//
//  Created by KanSC on 2016/11/16.
//  Copyright © 2016年 KanSC. All rights reserved.
//

#import "KSCCropAreaView.h"
#import "Masonry.h"

@interface CornerView : UIView
@end
@implementation CornerView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for(UIView *subView in self.subviews) {
        if(CGRectContainsPoint(subView.frame, point)) {
            return subView;
        }
    }
    if(CGRectContainsPoint(self.bounds, point)) {
        return self;
    }
    return nil;
}
@end

@interface MidLineView : UIView
@end
@implementation MidLineView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for(UIView *subView in self.subviews) {
        if(CGRectContainsPoint(subView.frame, point)) {
            return subView;
        }
    }
    if(CGRectContainsPoint(self.bounds, point)) {
        return self;
    }
    return nil;
}
@end

#define WIDTH(_view)  CGRectGetWidth(_view.bounds)
#define HEIGHT(_view) CGRectGetHeight(_view.bounds)
#define MAXX(_view) CGRectGetMaxX(_view.frame)
#define MAXY(_view) CGRectGetMaxY(_view.frame)
#define MINX(_view) CGRectGetMinX(_view.frame)
#define MINY(_view) CGRectGetMinY(_view.frame)

#define MID_LINE_HEIGHT 10
#define MID_LINE_XY (MID_LINE_HEIGHT*.6)

#define CORNER_WIDTH_HEIGHT  20
#define CORNER_XY (CORNER_WIDTH_HEIGHT*.6)

@interface KSCCropAreaView ()
@property (nonatomic, weak) MidLineView *topMidView;
@property (nonatomic, weak) MidLineView *leftMidView;
@property (nonatomic, weak) MidLineView *rightMidView;
@property (nonatomic, weak) MidLineView *bottomMidView;
@property (nonatomic, weak) CornerView *leftTopCorner;
@property (nonatomic, weak) CornerView *rightTopCorner;
@property (nonatomic, weak) CornerView *leftBottomCorner;
@property (nonatomic, weak) CornerView *rightBottomCorner;
@end
@implementation KSCCropAreaView

- (instancetype)init {
    if (self == [super init]) {
        [self configure];
        [self initCornerViews];
        [self initMidLineViews];
        [self addGesture];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self configure];
        [self initCornerViews];
        [self initMidLineViews];
        [self addGesture];
    }
    return self;
}
- (void)configure {
    [self.layer setBorderWidth:1.0f];
    [self.layer setBorderColor:[UIColor blueColor].CGColor];
}
- (void)initCornerViews {
    
    CornerView *leftTopCorner = [[CornerView alloc] initWithFrame:CGRectMake(0, 0, CORNER_WIDTH_HEIGHT, CORNER_WIDTH_HEIGHT)];
    leftTopCorner.tag = LEFT_TOP_CORNER_TAG;
    [self addSubview:leftTopCorner];
    [leftTopCorner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(CORNER_WIDTH_HEIGHT);
        make.left.mas_equalTo(self.mas_left).offset(-CORNER_XY);
        make.top.mas_equalTo(self.mas_top).offset(-CORNER_XY);
    }];
    _leftTopCorner = leftTopCorner;
    
    CornerView *rightTopCorner = [[CornerView alloc] init];
    rightTopCorner.tag = RIGHT_TOP_CORNER_TAG;
    [self addSubview:rightTopCorner];
    [rightTopCorner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(CORNER_WIDTH_HEIGHT);
        make.right.mas_equalTo(self.mas_right).offset(CORNER_XY);
        make.top.mas_equalTo(self.mas_top).offset(-CORNER_XY);
    }];
    _rightTopCorner = rightTopCorner;
    
    CornerView *leftBottomCorner = [[CornerView alloc] init];
    leftBottomCorner.tag = LEFT_BOTTOM_CORNER_TAG;
    [self addSubview:leftBottomCorner];
    [leftBottomCorner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(CORNER_WIDTH_HEIGHT);
        make.left.mas_equalTo(self.mas_left).offset(-CORNER_XY);
        make.bottom.mas_equalTo(self.mas_bottom).offset(CORNER_XY);
    }];
    _leftBottomCorner = leftBottomCorner;
    
    CornerView *rightBottomCorner = [[CornerView alloc] init];
    rightBottomCorner.tag = RIGHT_BOTTOM_CORNER_TAG;
    [self addSubview:rightBottomCorner];
    [rightBottomCorner mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.offset(CORNER_WIDTH_HEIGHT);
        make.right.mas_equalTo(self.mas_right).offset(CORNER_XY);
        make.bottom.mas_equalTo(self.mas_bottom).offset(CORNER_XY);
    }];
    _rightBottomCorner = rightBottomCorner;
}
- (void)initMidLineViews {
    
    MidLineView *topMidView = [[MidLineView alloc] init];
    topMidView.tag = TOP_LINE_MID_TAG;
    [self addSubview:topMidView];
    [topMidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_leftTopCorner.mas_right);
        make.right.mas_equalTo(_rightTopCorner.mas_left);
        make.height.offset(MID_LINE_HEIGHT);
        make.top.mas_equalTo(self.mas_top).offset(-MID_LINE_XY);
    }];
    
    MidLineView *leftMidView = [[MidLineView alloc] init];
    leftMidView.tag = LEFT_LINE_MID_TAG;
    [self addSubview:leftMidView];
    [leftMidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_leftTopCorner.mas_bottom);
        make.bottom.mas_equalTo(_leftBottomCorner.mas_top);
        make.width.offset(MID_LINE_HEIGHT);
        make.left.mas_equalTo(self.mas_left).offset(-MID_LINE_XY);
    }];
    _leftMidView = leftMidView;
    
    MidLineView *rightMidView = [[MidLineView alloc] init];
    rightMidView.tag = RIGHT_LINE_MID_TAG;
    [self addSubview:rightMidView];
    [rightMidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_rightTopCorner.mas_bottom);
        make.bottom.mas_equalTo(_rightBottomCorner.mas_top);
        make.width.offset(MID_LINE_HEIGHT);
        make.right.mas_equalTo(self.mas_right).offset(MID_LINE_XY);
    }];
    _rightMidView = rightMidView;
    
    MidLineView *bottomMidView = [[MidLineView alloc] init];
    bottomMidView.tag = BOTTOM_LINE_MID_TAG;
    [self addSubview:bottomMidView];
    [bottomMidView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_leftTopCorner.mas_right);
        make.right.mas_equalTo(_rightTopCorner.mas_left);
        make.height.offset(MID_LINE_HEIGHT);
        make.bottom.mas_equalTo(self.mas_bottom).offset(MID_LINE_XY);
    }];
    _bottomMidView = bottomMidView;
}
- (void)addGesture {
    
    UIPanGestureRecognizer *leftTopCornerPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self                                                                              action:@selector(moveGesture:)];
    [_leftTopCorner     addGestureRecognizer:leftTopCornerPanGesture];
    UIPanGestureRecognizer *leftBottomCornerPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self                                                                              action:@selector(moveGesture:)];
    [_leftBottomCorner  addGestureRecognizer:leftBottomCornerPanGesture];
    UIPanGestureRecognizer *rightTopCornerPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
    [_rightTopCorner    addGestureRecognizer:rightTopCornerPanGesture];
    UIPanGestureRecognizer *rightBottomCornerPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self                                                                              action:@selector(moveGesture:)];
    [_rightBottomCorner addGestureRecognizer:rightBottomCornerPanGesture];
    
    UIPanGestureRecognizer *topLinePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self                                                                              action:@selector(moveGesture:)];
    [_topMidView addGestureRecognizer:topLinePanGesture];
    
    UIPanGestureRecognizer *leftLinePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self                                                                              action:@selector(moveGesture:)];
    [_leftMidView addGestureRecognizer:leftLinePanGesture];
    
    UIPanGestureRecognizer *rightLinePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self                                                                              action:@selector(moveGesture:)];
    [_rightMidView addGestureRecognizer:rightLinePanGesture];
    
    UIPanGestureRecognizer *bottomLinePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self                                                                              action:@selector(moveGesture:)];
    [_bottomMidView addGestureRecognizer:bottomLinePanGesture];
}
- (void)moveGesture:(UIPanGestureRecognizer *)gesture {
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        UIView *cornerView = gesture.view;
        if ([_delegate respondsToSelector:@selector(cropAreaViewMove:gesture:)]) {
            [_delegate cropAreaViewMove:cornerView.tag gesture:gesture];
        }
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    for(UIView *subView in self.subviews) {
        if(CGRectContainsPoint(subView.frame, point)) {
            return subView;
        }
    }
    if(CGRectContainsPoint(self.bounds, point)) {
        return self;
    }
    return nil;
}

@end
