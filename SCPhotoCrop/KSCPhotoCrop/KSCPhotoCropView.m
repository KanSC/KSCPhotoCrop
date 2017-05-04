//
//  Created by KanSC on 2016/11/16.
//  Copyright © 2016年 KanSC. All rights reserved.
//

#import "KSCPhotoCropView.h"
#import "KSCCropAreaView.h"
#import "Masonry.h"

#define WIDTH(_view)  CGRectGetWidth(_view.bounds)
#define HEIGHT(_view) CGRectGetHeight(_view.bounds)
#define MAXX(frame) CGRectGetMaxX(frame)
#define MAXY(frame) CGRectGetMaxY(frame)
#define MINX(frame) CGRectGetMinX(frame)
#define MINY(frame) CGRectGetMinY(frame)

@interface UIImage(Handler)
@end
@implementation UIImage(Handler)
- (UIImage *)cropImg:(CGRect)frame imageView:(UIImageView *)imageView {
    CGRect cropFrame = frame;
    CGFloat orgX = cropFrame.origin.x * (self.size.width / imageView.frame.size.width);
    CGFloat orgY = cropFrame.origin.y * (self.size.height / imageView.frame.size.height);
    CGFloat width = cropFrame.size.width * (self.size.width / imageView.frame.size.width);
    CGFloat height = cropFrame.size.height * (self.size.height / imageView.frame.size.height);
    CGRect cropRect = CGRectMake(orgX, orgY, width, height);
    CGImageRef imgRef = CGImageCreateWithImageInRect(self.CGImage, cropRect);
    
    CGFloat deviceScale = [UIScreen mainScreen].scale;
    UIGraphicsBeginImageContextWithOptions(cropFrame.size, 0, deviceScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, cropFrame.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextDrawImage(context, CGRectMake(0, 0, cropFrame.size.width, cropFrame.size.height), imgRef);
    UIImage *newImg = UIGraphicsGetImageFromCurrentImageContext();
    CGImageRelease(imgRef);
    UIGraphicsEndImageContext();
    return newImg;
}
@end

@interface MaskView : UIView

@end
@implementation MaskView
- (instancetype)init {
    if (self = [super init]) {
        [self setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:.7]];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:.7]];
    }
    return self;
}
@end

@interface KSCPhotoCropView () <CropAreaDelegate>
{
    CGPoint p_point;
    CGFloat moveMaxX;
    CGFloat moveMaxY;
}
@property (nonatomic, weak) KSCCropAreaView *cropAreaView;
@property (nonatomic, weak) UIImageView *toCropImageView;
@property (nonatomic, weak) MaskView *topMaskView;
@property (nonatomic, weak) MaskView *leftMaskView;
@property (nonatomic, weak) MaskView *rightMaskView;
@property (nonatomic, weak) MaskView *bottomMaskView;
@end

@implementation KSCPhotoCropView

- (instancetype)initWithWhetherCanChangeFrame:(BOOL)whetherCanChangeFrame {
    if (self == [super init]) {
        _whetherCanChangeArea = whetherCanChangeFrame;
        [self configure];
        [self initCropAreaView];
        [self initMaskViews];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame whetherCanChangeFrame:(BOOL)whetherCanChangeFrame {
    if (self == [super initWithFrame:frame]) {
        _whetherCanChangeArea = whetherCanChangeFrame;
        [self configure];
        [self initCropAreaView];
        [self initMaskViews];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super initWithCoder:aDecoder]) {
        _whetherCanChangeArea = YES;
        [self configure];
        [self initCropAreaView];
        [self initMaskViews];
    }
    return self;
}
- (void)configure {
    _minWidth  = 30;
    _minHeight = 30;
    _initialFrame = CGRectMake(0, 0, 30, 30);
}
- (void)initCropAreaView {
    
    __weak typeof(self) weakSelf = self;
    UIImageView *toCropImageView = [[UIImageView alloc] init];
    [toCropImageView setUserInteractionEnabled:YES];
    [toCropImageView setContentMode:UIViewContentModeScaleToFill];
    [self addSubview:toCropImageView];
    [toCropImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(weakSelf.mas_width);
        make.height.mas_equalTo(weakSelf.mas_height);
        make.center.mas_equalTo(weakSelf);
    }];
    _toCropImageView = toCropImageView;
    
    KSCCropAreaView *cropAreaView = [[KSCCropAreaView alloc] initWithFrame:_initialFrame];
    [cropAreaView setDelegate:self];
    [_toCropImageView addSubview:cropAreaView];
    
    UIPanGestureRecognizer *cropAreaMoveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self                                                                              action:@selector(moveCropAreaView:)];
    [cropAreaView addGestureRecognizer:cropAreaMoveGesture];
    _cropAreaView = cropAreaView;
}
- (void)initMaskViews {
    
    __weak typeof(self) weakSelf = self;
    
    MaskView *topMaskView = [[MaskView alloc] init];
    [_toCropImageView addSubview:topMaskView];
    [topMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(weakSelf);
        make.bottom.mas_equalTo(weakSelf.cropAreaView.mas_top);
    }];
    _topMaskView = topMaskView;
    
    MaskView *bottomMaskView = [[MaskView alloc] init];
    [_toCropImageView addSubview:bottomMaskView];
    [bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(weakSelf);
        make.top.mas_equalTo(weakSelf.cropAreaView.mas_bottom);
    }];
    _bottomMaskView = bottomMaskView;
    
    MaskView *leftMaskView = [[MaskView alloc] init];
    [_toCropImageView addSubview:leftMaskView];
    [leftMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.topMaskView.mas_bottom);
        make.bottom.mas_equalTo(weakSelf.bottomMaskView.mas_top);
        make.left.mas_equalTo(weakSelf.mas_left);
        make.right.mas_equalTo(weakSelf.cropAreaView.mas_left);
    }];
    _leftMaskView = leftMaskView;
    
    MaskView *rightMaskView = [[MaskView alloc] init];
    [_toCropImageView addSubview:rightMaskView];
    [rightMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(weakSelf.topMaskView.mas_bottom);
        make.bottom.mas_equalTo(weakSelf.bottomMaskView.mas_top);
        make.right.mas_equalTo(weakSelf.mas_right);
        make.left.mas_equalTo(weakSelf.cropAreaView.mas_right);
    }];
    _rightMaskView = rightMaskView;
    
    [_toCropImageView bringSubviewToFront:_cropAreaView];
}
- (void)setOriginalImage:(UIImage *)originalImage {
    _originalImage = originalImage;
    [_toCropImageView setImage:_originalImage];
    
    __weak typeof(self) weakSelf = self;
    
    [_toCropImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.offset(weakSelf.originalImage.size.width);
        make.height.offset(weakSelf.originalImage.size.height);
    }];
}
- (void)moveCropAreaView:(UIPanGestureRecognizer *)gesture {
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:{
            p_point = [gesture locationInView:_cropAreaView];
        }   break;
        case UIGestureRecognizerStateEnded:{
            p_point = [gesture locationInView:_cropAreaView];
        }   break;
        case UIGestureRecognizerStateChanged:{
            [self moveRightwithLocation:p_point moveGestureRecognizer:gesture];
        }   break;
        default:
            break;
    }
}
- (void)moveRightwithLocation:(CGPoint)point moveGestureRecognizer:(UIGestureRecognizer *)recognizer {
    
    CGRect frame = _cropAreaView.frame;
    CGPoint _point = [recognizer locationInView:_cropAreaView.superview];
    frame.origin.x = _point.x - point.x;
    frame.origin.y = _point.y - point.y;
    
    if (MINX(frame)<=0) {
        frame.origin.x = 0;
    }
    if (MINY(frame)<=0) {
        frame.origin.y = 0;
    }
    if (MAXX(frame)>=MAXX(_toCropImageView.frame)) {
        frame.origin.x = WIDTH(_toCropImageView)-WIDTH(_cropAreaView);
    }
    if (MAXY(frame)>=MAXY(_toCropImageView.frame)) {
        frame.origin.y = HEIGHT(_toCropImageView)-HEIGHT(_cropAreaView);
    }
    _cropAreaView.frame = frame;
    
//        [self frameChange];
}

- (void)cropAreaViewMove:(CornerLineViewTag)tag gesture:(UIPanGestureRecognizer *)gesture {
    
    NSLog(@"%d",_whetherCanChangeArea);
    if (!_whetherCanChangeArea) {
        return;
    }
    
    CGPoint point = [gesture locationInView:_cropAreaView.superview];
    NSLog(@"point:%@",NSStringFromCGPoint(point));
    
    CGRect frame = _cropAreaView.frame;
    CGFloat xValue = point.x-frame.origin.x;
    CGFloat yValue = point.y-frame.origin.y;
    
    NSLog(@"%f,%f",xValue,point.x);
    switch (tag) {
        case LEFT_TOP_CORNER_TAG:{
            frame = [self checkTopBottom:frame point:[gesture velocityInView:gesture.view] yValue:yValue];
            frame = [self checkLeftRight:frame point:[gesture velocityInView:gesture.view] xValue:xValue];
            
            frame = [self checkMinHeight:frame];
            frame = [self checkMinY:frame yValue:yValue];
            frame = [self checkMaxY:frame yValue:yValue];
            
            frame = [self checkMinWidth:frame];
            frame = [self checkMinX:frame xValue:xValue];
            frame = [self checkMaxX:frame xValue:xValue];
        }   break;
        case LEFT_BOTTOM_CORNER_TAG:{
            
            frame.size.height = yValue;
            
            frame = [self checkLeftRight:frame point:[gesture velocityInView:gesture.view] xValue:xValue];
            
            frame = [self checkMinWidth:frame];
            frame = [self checkMinX:frame xValue:xValue];
            frame = [self checkMaxX:frame xValue:xValue];
            
            frame = [self checkMinHeight:frame];
            frame = [self checkMaxHeight:frame yValue:yValue];
        }   break;
        case RIGHT_TOP_CORNER_TAG:{
            
            frame.size.width   = xValue;
            
            frame = [self checkTopBottom:frame point:[gesture velocityInView:gesture.view] yValue:yValue];
            
            frame = [self checkMinHeight:frame];
            frame = [self checkMinWidth:frame];
            frame = [self checkMinY:frame yValue:yValue];
            frame = [self checkMaxWidth:frame xValue:xValue];
            frame = [self checkMaxY:frame yValue:yValue];
        }   break;
        case RIGHT_BOTTOM_CORNER_TAG:{
            frame.size.width  = point.x-frame.origin.x;
            frame.size.height = point.y-frame.origin.y;
            
            frame = [self checkMinWidth:frame];
            frame = [self checkMinHeight:frame];
            frame = [self checkMaxWidth:frame xValue:xValue];
            frame = [self checkMaxHeight:frame yValue:yValue];
        }   break;
        case LEFT_LINE_MID_TAG:{
            frame = [self checkLeftRight:frame point:[gesture velocityInView:gesture.view] xValue:xValue];
            frame = [self checkMinWidth:frame];
            frame = [self checkMinX:frame xValue:xValue];
            frame = [self checkMaxX:frame xValue:xValue];
        }   break;
        case TOP_LINE_MID_TAG:{
            
            frame = [self checkTopBottom:frame point:[gesture velocityInView:gesture.view] yValue:yValue];
            frame = [self checkMinHeight:frame];
            frame = [self checkMinY:frame yValue:yValue];
            frame = [self checkMaxY:frame yValue:yValue];
        }   break;
        case RIGHT_LINE_MID_TAG:{
            frame.size.width = xValue;
            frame = [self checkMinWidth:frame];
            frame = [self checkMaxWidth:frame xValue:xValue];
        }   break;
        case BOTTOM_LINE_MID_TAG:{
            frame.size.height = yValue;
            frame = [self checkMinHeight:frame];
            frame = [self checkMaxHeight:frame yValue:yValue];
        }   break;
        default:
            break;
    }
    _cropAreaView.frame = frame;
    moveMaxX = _toCropImageView.bounds.size.width-_rightMaskView.bounds.size.width-_minWidth;
    moveMaxY = _toCropImageView.bounds.size.height-_bottomMaskView.bounds.size.height-_minHeight;
    
    //    [self frameChange];
}
- (void)setInitialFrame:(CGRect)initialFrame {
    _initialFrame = initialFrame;
    
    CGFloat x = _initialFrame.origin.x;
    CGFloat y = _initialFrame.origin.y;
    CGFloat width  = _initialFrame.size.width;
    CGFloat height = _initialFrame.size.height;
    
    if (x+width>_toCropImageView.bounds.size.width) {
        _initialFrame.size.width = _toCropImageView.bounds.size.width-x;
    }
    if (y+height>_toCropImageView.bounds.size.height) {
        _initialFrame.size.height = _toCropImageView.bounds.size.height-y;
    }
    _cropAreaView.frame = _initialFrame;
}

- (UIImage *)cutOutImage {
    return [_originalImage cropImg:_cropAreaView.frame imageView:_toCropImageView];
}

- (CGRect)checkTopBottom:(CGRect)frame point:(CGPoint)point yValue:(CGFloat)yValue {
    if(point.y>0) {
        frame.size.height -= yValue;
        if ((frame.origin.y+=yValue)>=moveMaxY) {
            frame.origin.y = moveMaxY;
        }
    } else {
        frame.origin.y    += yValue;
        frame.size.height -= yValue;
    }
    return frame;
}
- (CGRect)checkLeftRight:(CGRect)frame point:(CGPoint)point xValue:(CGFloat)xValue {
    if(point.x>0) {
        frame.size.width -= xValue;
        if ((frame.origin.x+=xValue)>=moveMaxX) {
            frame.origin.x = moveMaxX;
        }
    } else {
        frame.origin.x   += xValue;
        frame.size.width -= xValue;
    }
    return frame;
}
- (CGRect)checkMinY:(CGRect)frame yValue:(CGFloat)yValue {
    if (frame.origin.y+yValue<=0) {
        frame.origin.y = 0;
        frame.size.height = HEIGHT(_toCropImageView)-(HEIGHT(_toCropImageView)-MAXY(_cropAreaView.frame));
    }
    return frame;
}
- (CGRect)checkMaxY:(CGRect)frame yValue:(CGFloat)yValue {
    if ((frame.origin.y+yValue)>=moveMaxY) {
        frame.origin.y = moveMaxY;
        frame.size.height = _minHeight;
    }
    return frame;
}
- (CGRect)checkMinX:(CGRect)frame xValue:(CGFloat)xValue {
    if (frame.origin.x+xValue<=0) {
        frame.origin.x = 0;
        frame.size.width = WIDTH(_toCropImageView)-(WIDTH(_toCropImageView)-MAXX(_cropAreaView.frame));
    }
    return frame;
}
- (CGRect)checkMaxX:(CGRect)frame xValue:(CGFloat)xValue {
    if (frame.origin.x+xValue>=moveMaxX) {
        frame.origin.x = moveMaxX;
        frame.size.width = _minWidth;
    }
    return frame;
}
- (CGRect)checkMinWidth:(CGRect)frame {
    if (frame.size.width<=_minWidth) {
        frame.size.width = _minWidth;
    }
    return frame;
}
- (CGRect)checkMaxWidth:(CGRect)frame xValue:(CGFloat)xValue {
    if (frame.origin.x+xValue>=MAXX(_toCropImageView.frame)) {
        frame.size.width = WIDTH(_toCropImageView)-frame.origin.x;
    }
    return frame;
}
- (CGRect)checkMinHeight:(CGRect)frame {
    if (frame.size.height<=_minHeight) {
        frame.size.height = _minHeight;
    }
    return frame;
}
- (CGRect)checkMaxHeight:(CGRect)frame yValue:(CGFloat)yValue {
    if (frame.origin.y+yValue>=MAXY(_toCropImageView.frame)) {
        frame.size.height = HEIGHT(_toCropImageView)-frame.origin.y;
    }
    return frame;
}

@end
