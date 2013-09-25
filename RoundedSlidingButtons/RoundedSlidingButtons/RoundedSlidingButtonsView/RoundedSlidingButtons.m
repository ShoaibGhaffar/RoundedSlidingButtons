//
//  SlideButtonsView.m
//  ButtonSlider
//
//  Created by Shoaib Mac Mini on 04/09/2013.
//  Copyright (c) 2013 Shoaib Mac Mini. All rights reserved.
//

#import "RoundedSlidingButtons.h"

/** @def CC_DEGREES_TO_RADIANS
 converts degrees to radians
 */
#define CC_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f) // PI / 180

/** @def CC_RADIANS_TO_DEGREES
 converts radians to degrees
 */
#define CC_RADIANS_TO_DEGREES(__ANGLE__) ((__ANGLE__) * 57.29577951f) // PI * 180


#pragma mark - SliderButton interface
@interface RoundedSliderButtonModel : NSObject
{
    int angleOn_, angleTemp_, angleCur_;
    UIButton* button_;
    CGPoint buttonPosition_;
}

@property (nonatomic) int angleOn;
@property (nonatomic) int angleCur;
@property (nonatomic) int angleTemp;
@property (nonatomic) CGPoint buttonPosition;
@property (nonatomic, assign) UIButton* button;

+(id) button:(UIButton*)btn;
+(id) button:(UIButton*)btn AngleOn:(int)angOn;
-(id) initWithButton:(UIButton*)btn AngleOn:(int)angOn;
@end

#pragma mark - SliderButton implementation
@implementation RoundedSliderButtonModel
@synthesize angleOn = angleOn_, angleCur = angleCur_, angleTemp = angleTemp_, button = button_ , buttonPosition = buttonPosition_;

+(id) button:(UIButton*)btn {
    return [self button:btn AngleOn:0];
} //F.E.

+(id) button:(UIButton*)btn AngleOn:(int)angOn {
    return [[[self alloc] initWithButton:btn AngleOn:angOn] autorelease];
} //F.E.

-(id) initWithButton:(UIButton*)btn AngleOn:(int)angOn {
    if (self = [super init]) {
        button_ = btn;
        angleOn_ = angOn;
        angleCur_ = -1;
        buttonPosition_ = CGPointMake(-1, -1);
    }
    return self;
} //F.E.

-(void) setButtonPosition:(CGPoint)newButtonPosition {
    if (CGPointEqualToPoint(newButtonPosition, buttonPosition_))
    {return;}
    //--
    buttonPosition_ = newButtonPosition;
    //--
    CGRect newFrame;
    newFrame.size = button_.frame.size;
    
    newFrame.origin.x = buttonPosition_.x - (newFrame.size.width/2);
    newFrame.origin.y = buttonPosition_.y - (newFrame.size.height/2);
    
    [button_ setFrame:newFrame];
} //F.E.

@end

#pragma mark - SlideButtonsView implementation
@implementation RoundedSlidingButtons
@synthesize on = on_, delegate = delegate_, tag = tag_;

#pragma mark - init
- (id)initWithDirection:(RoundedSliderDirection)sldDir Radius:(int)rad StartingDegree:(int)sDeg Spacing:(int)spac CenterPosition:(CGPoint)cPos ParentView:(UIView*)pView ButtonImageNames:(id)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [super init];
    
    if (self) {
        //Setting Slider Direction
        currRoundedSliderDirection_ = sldDir;
        radius_ = rad;
        startingDeg_ = sDeg;
        spacing_ = spac;
        origin_ = cPos;
        diff_ = spac * RND_SLIDING_SPEED;
        parentView_ = pView;
        
        //Extracting Image Names N Making Buttons
        NSMutableArray* arr = [NSMutableArray array];
        
        id eachObject;
        va_list argumentList;
        if (firstObj) // The first argument isn't part of the varargs list,
        {                                   // so we'll handle it separately.
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            [button setImage:[UIImage imageNamed:firstObj] forState:UIControlStateNormal];
            [arr addObject:button];
            va_start(argumentList, firstObj); // Start scanning for arguments after firstObject.
            while ((eachObject = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
            {
                UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setImage:[UIImage imageNamed:eachObject] forState:UIControlStateNormal];
                [arr addObject: button]; // that isn't nil, add it to self's contents.
            }
            va_end(argumentList);
            //--
            buttonSize_  =   ((UIButton*)[arr objectAtIndex:0]).imageView.image.size;
        }
        
        //Setting Slider Buttons
        [self setupSliderWithButtons:arr];
    }
    return self;
} //F.E.

- (id)initWithDirection:(RoundedSliderDirection)sldDir Radius:(int)rad StartingDegree:(int)sDeg Spacing:(int)spac CenterPosition:(CGPoint)cPos ButtonSize:(CGSize)btnSize ParentView:(UIView*)pView Buttons:(UIButton*)firstObj, ... NS_REQUIRES_NIL_TERMINATION
{
    self = [super init];
    
    if (self) {
        //Setting Slider Direction
        currRoundedSliderDirection_ = sldDir;
        radius_ = rad;
        startingDeg_ = sDeg;
        spacing_ = spac;
        origin_ = cPos;
        diff_ = spac * RND_SLIDING_SPEED;
        parentView_ = pView;
        
        //Extracting Image Names
        NSMutableArray* arr = [NSMutableArray array];
        
        id eachObject;
        va_list argumentList;
        if (firstObj) // The first argument isn't part of the varargs list,
        {                                   // so we'll handle it separately.
            [arr addObject:firstObj];
            va_start(argumentList, firstObj); // Start scanning for arguments after firstObject.
            while ((eachObject = va_arg(argumentList, id))) // As many times as we can get an argument of type "id"
                [arr addObject: eachObject]; // that isn't nil, add it to self's contents.
            va_end(argumentList);
            //--
            buttonSize_  =   btnSize;
        }
        
        //Setting Slider Buttons
        [self setupSliderWithButtons:arr];
    }
    return self;
} //F.E.

-(void) setupSliderWithButtons:(NSMutableArray*)arrButtons {
    assert(arrButtons.count>1); // Buttons should not be less than 1
    
    arrSliderButtons_   =   [[NSMutableArray alloc] init];
    
    for (int i = 0; i < arrButtons.count; i++) {
        UIButton* button = [arrButtons objectAtIndex:i];
        button.tag = i;
        [button setFrame:CGRectMake(0, 0, buttonSize_.width, buttonSize_.height)];
        [button addTarget:self action:@selector(buttonsHandler:) forControlEvents:UIControlEventTouchUpInside];
        
        RoundedSliderButtonModel* sliderButtonModel = [RoundedSliderButtonModel button:button];
        [self updateButtonModel:sliderButtonModel NoOfItems:i];
        [arrSliderButtons_ addObject:sliderButtonModel];
    }
    //--
    [self addButtonsOnParentView];
} //F.E.

#pragma mark - Add Button
-(void) addButtonsOnParentView {
    assert(parentView_); // Parent View is not defined
    
    for (int i = arrSliderButtons_.count-1; i >= 0 ; i--) {
        RoundedSliderButtonModel* sliderButtonModel = (RoundedSliderButtonModel*)[arrSliderButtons_ objectAtIndex:i];
        [parentView_ addSubview:sliderButtonModel.button];
    }
} //F.E.

#pragma mark - Update Button Model
-(void) updateButtonModel:(RoundedSliderButtonModel*)sliderButtonModel NoOfItems:(int)noOfItems {
    
    int i = arrSliderButtons_.count;
    int angal;
    
    if (currRoundedSliderDirection_ == kRoundedSliderDirectionAntiClockWise)
    {angal = startingDeg_ + (spacing_ * i);}
    else
    {angal = startingDeg_ - (spacing_ * i);}
    
    sliderButtonModel.angleOn = angal;
    sliderButtonModel.angleTemp = startingDeg_;
    
    [self updateButtonPositionWithButtonModel:sliderButtonModel];
    //--
    if (i == 1)
    {refAng_ = angal;}
} //F.E.

#pragma mark - Update Button Position

-(void) updateButtonPositionWithButtonModel:(RoundedSliderButtonModel*)sliderButtonModel {
    [self updateButtonPositionWithButtonModel:sliderButtonModel Validate:YES];
} //F.E.

-(void) updateButtonPositionWithButtonModel:(RoundedSliderButtonModel*)sliderButtonModel Validate:(BOOL)validate {
    
    if (validate && (sliderButtonModel.angleCur ==  sliderButtonModel.angleTemp))
    {return;}
    
    sliderButtonModel.angleCur =  sliderButtonModel.angleTemp;
    //--
    CGPoint newPos = [self buttonPositionWithAngle:sliderButtonModel.angleCur];
    
    sliderButtonModel.buttonPosition = newPos;
} //F.E.

-(CGPoint) buttonPositionWithAngle:(float)angl {

    float radAngl = CC_DEGREES_TO_RADIANS(angl);
    CGPoint pos;
    
    pos.x = (radius_ * cosf(radAngl)) + origin_.x;
    pos.y = -(radius_ * sinf(radAngl)) + origin_.y;
    
    return pos;
} //F.#.

#pragma mark - buttons Handler
-(void) buttonsHandler:(id)sender {
    
    int indx = [sender tag];
    
    NSLog(@"i >> %d", indx);
    
    if (indx == 0)
    {self.on = !on_;}
    
    //Invoking funciton
    if ([delegate_ respondsToSelector:@selector(roundedSlidingButtonsHandler:button:buttonIndex:)]) {
        [delegate_ roundedSlidingButtonsHandler:self button:sender buttonIndex:indx];
    }
} //F.E.

#pragma mark - Overriden function for On/ Off
-(void) setOn:(BOOL)newOn {
    if (newOn == on_)
    {return;}
    //--
    on_ = newOn;
    [self startSliding];
}//F.E.

#pragma mark - Start Sliding
-(void) startSliding {
    
    if (timer_ && timer_.isValid) {
        return;
    }
    
    timer_ = nil;
    timer_ = [NSTimer scheduledTimerWithTimeInterval:0.05
                                              target:self
                                            selector:@selector(update:)
                                            userInfo:nil
                                             repeats:YES];
} //F.E.

#pragma mark - Updater
-(void) update:(NSTimer*)timer {
    
    int noOfBtnDoneAnim = 0;
    
    for (int i = arrSliderButtons_.count-1; i >0 ; i--) {
        
        //button instance from arr
        RoundedSliderButtonModel * buttonModel = ((RoundedSliderButtonModel*)[arrSliderButtons_ objectAtIndex:i]);
        
        
        int newAng = 0;
        int currAng = buttonModel.angleCur;
        int onAng = buttonModel.angleOn;
        //--
        int newDiff = diff_;
        
        int dif = (onAng > currAng)? (onAng - currAng) : (currAng - onAng);
        if (dif <= diff_) {newDiff = diff_ / 4;}
        
        if (on_)
        {
            BOOL wait = false;
            
            if (i < arrSliderButtons_.count-1) {
                wait = [self waitForPreviousButton:((RoundedSliderButtonModel*)[arrSliderButtons_ objectAtIndex:i+1])];
            }
            
            if (!wait) {
                switch (currRoundedSliderDirection_) {
                    case kRoundedSliderDirectionAntiClockWise:
                        newAng = MIN(currAng + newDiff, onAng);
                        break;

                    case kRoundedSliderDirectionClockWise:
                        newAng = MAX(currAng - newDiff, onAng);
                        break;
                        
                    default:
                        break;
                }
            }
            else {
                newAng = currAng;
            }
            
            if (newAng == onAng)
            {noOfBtnDoneAnim++;}
        }
        else
        {
            switch (currRoundedSliderDirection_) {
                case kRoundedSliderDirectionAntiClockWise:
                    newAng = MAX(currAng - newDiff, startingDeg_);
                    break;
                    
                case kRoundedSliderDirectionClockWise:
                    newAng = MIN(currAng + newDiff, startingDeg_);
                    break;
                    
                default:
                    break;
            }
            
            if (newAng == startingDeg_)
            {noOfBtnDoneAnim++;}
        }
        
        buttonModel.angleTemp = newAng;
        
        float totalLenth = (onAng > startingDeg_)?(onAng - startingDeg_):(startingDeg_ - onAng);
        float lenth = (startingDeg_ > newAng)?(startingDeg_ - newAng):(newAng - startingDeg_);
        //--
        float opacity =  lenth / totalLenth;
        
        [buttonModel.button setAlpha:opacity];
        
        [self updateButtonPositionWithButtonModel:buttonModel];
    }

    //--

    if (timer && noOfBtnDoneAnim>=(arrSliderButtons_.count-1) && timer.isValid)
    {
        [timer invalidate]; timer = nil; timer_ = nil;
    }
} //F.E.

#pragma mark - Waiting
-(BOOL) waitForPreviousButton:(RoundedSliderButtonModel*)previousButtonModel {
    
    int curAng = previousButtonModel.angleCur;
    
    switch (currRoundedSliderDirection_) {
        case kRoundedSliderDirectionAntiClockWise:
            return !(curAng > refAng_);
            break;
            
        case kRoundedSliderDirectionClockWise:
            return !(curAng < refAng_);
            break;
            
        default:
            break;
    }
    return true;
} //F.E.

#pragma mark - dealloc
-(void) dealloc {
    if (arrSliderButtons_) {
        [arrSliderButtons_ removeAllObjects];
        [arrSliderButtons_ release];
        arrSliderButtons_ = nil;
    }
    //--
    if (timer_) {
        if (timer_.isValid)
        {[timer_ invalidate];}
        //--
        timer_ = nil;
    }
    [super dealloc];
} //F.E.

@end
