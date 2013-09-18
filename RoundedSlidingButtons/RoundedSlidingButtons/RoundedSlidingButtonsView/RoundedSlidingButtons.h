//
//  SlideButtonsView.h
//  ButtonSlider
//
//  Created by Shoaib Mac Mini on 04/09/2013.
//  Copyright (c) 2013 Shoaib Mac Mini. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RND_SLIDING_SPEED 0.5f  // Range 0 to 1

@class RoundedSlidingButtons;

@protocol RoundedSlidingButtonsDelegate <NSObject>

@optional
-(void) roundedSlidingButtonsHandler:(RoundedSlidingButtons*)slidingButtonsView button:(id)button buttonIndex:(int)buttonIndex;

@end

typedef enum {
    kRoundedSliderDirectionClockWise,
    kRoundedSliderDirectionAntiClockWise,
} RoundedSliderDirection;

@interface RoundedSlidingButtons: NSObject {
    
    NSInteger tag_;
    UIView* parentView_;
    
    RoundedSliderDirection currRoundedSliderDirection_;
    
    NSMutableArray* arrSliderButtons_;
    NSTimer* timer_;
    
    BOOL on_;
    
//    CGPoint centPos_; // ON the Parent View
    CGPoint origin_; // Current View
    
    CGSize  buttonSize_;
    CGPoint buttonPos_;

    
    int radius_;
    int startingDeg_;
    int spacing_;
    
    int diff_;
    int refAng_;
    
    id <RoundedSlidingButtonsDelegate>delegate_;
}

@property (nonatomic,getter=isOn)    BOOL on;
@property (nonatomic, assign)       id <RoundedSlidingButtonsDelegate>delegate;
@property (nonatomic)                NSInteger tag; // default is 0

- (id)initWithDirection:(RoundedSliderDirection)sldDir Radius:(int)rad StartingDegree:(int)sDeg Spacing:(int)spac CenterPosition:(CGPoint)cPos ParentView:(UIView*)pView ButtonImageNames:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

- (id)initWithDirection:(RoundedSliderDirection)sldDir Radius:(int)rad StartingDegree:(int)sDeg Spacing:(int)spac CenterPosition:(CGPoint)cPos ButtonSize:(CGSize)btnSize ParentView:(UIView*)pView Buttons:(UIButton*)firstObj, ... NS_REQUIRES_NIL_TERMINATION;

@end
