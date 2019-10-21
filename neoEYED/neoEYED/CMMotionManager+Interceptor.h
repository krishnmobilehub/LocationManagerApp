//
//  CMMotionManager+Interceptor.h
//  neoEYED
//

#import <CoreMotion/CoreMotion.h>
#import <UIKit/UIKit.h>

@interface CMMotionManager (Interceptor)

@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;

@end
