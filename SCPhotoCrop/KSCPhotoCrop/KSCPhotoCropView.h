//
//  Created by KanSC on 2016/11/16.
//  Copyright © 2016年 KanSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSCPhotoCropView : UIView

/**
 初始化方法
 
 @param whetherCanChangeFrame 是否可以修改选择区域
 */
/* xib中默认为 YES, 如需要设置为 NO, 可以设置 whetherCanChangeArea 属性 */
- (instancetype)initWithWhetherCanChangeFrame:(BOOL)whetherCanChangeFrame;

/**
 初始化方法
 
 @param frame frame
 @param whetherCanChangeFrame 是否可以修改选择区域
 */
/* xib中默认为 YES, 如需要设置为 NO, 可以设置 whetherCanChangeArea 属性 */
- (instancetype)initWithFrame:(CGRect)frame
        whetherCanChangeFrame:(BOOL)whetherCanChangeFrame;

/**
 是否允许修改选择区域
 */
/* YES:可以自由修改选择区域, NO:不可修改选择区域 */
@property (nonatomic, assign) BOOL whetherCanChangeArea;

/**
 最小宽度
 */
/* minWidth 只在 whetherCanChangeArea 为 YES 时有效 */
@property (nonatomic, assign) CGFloat minWidth;

/**
 最小高度
 */
/* minWidth 只在 whetherCanChangeArea 为 YES 时有效 */
@property (nonatomic, assign) CGFloat minHeight;

/**
 默认选择区域
 */
/* initialFrame 不受限于最小宽高度 */
@property (nonatomic, assign) CGRect  initialFrame;

/**
 原始图片
 */
@property (nonatomic, strong) UIImage *originalImage;

/**
 裁剪图片
 */
@property (nonatomic, strong, readonly) UIImage *cutOutImage;

//@property (nonatomic, assign) CGRect cropAreaInitialFrame;

@end
