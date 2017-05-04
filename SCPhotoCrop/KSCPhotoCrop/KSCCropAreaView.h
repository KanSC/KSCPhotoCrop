//
//  SCCropAreaView.h
//  SCPhotoCropEditor
//
//  Created by KanSC on 2016/11/16.
//  Copyright © 2016年 KanSC. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CornerLineViewTag) {
    LEFT_TOP_CORNER_TAG = 100,
    LEFT_BOTTOM_CORNER_TAG,
    RIGHT_TOP_CORNER_TAG,
    RIGHT_BOTTOM_CORNER_TAG,
    LEFT_LINE_MID_TAG,
    TOP_LINE_MID_TAG,
    RIGHT_LINE_MID_TAG,
    BOTTOM_LINE_MID_TAG,
};

@protocol CropAreaDelegate <NSObject>
- (void)cropAreaViewMove:(CornerLineViewTag)tag gesture:(UIPanGestureRecognizer *)gesture;
@end
@interface KSCCropAreaView : UIView
@property (nonatomic, assign) id<CropAreaDelegate> delegate;
@end
