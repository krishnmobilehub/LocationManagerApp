//
//  CMMotionManager+Interceptor.m
//  neoEYED
//

#import "CMMotionManager+Interceptor.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation CMMotionManager (Interceptor)

@dynamic deviceOrientation;

+ (void)load
{
    objc_setAssociatedObject(self, @selector(deviceOrientation),
                            [NSNumber numberWithInt:UIDeviceOrientationPortrait],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    Method updateMethod = class_getInstanceMethod(self, @selector(startAccelerometerUpdatesToQueue:withHandler:));
    Method interceptedUpdateMethod = class_getInstanceMethod(self, @selector(interceptAndStartAccelerometerUpdatesToQueue:withHandler:));
    method_exchangeImplementations(updateMethod, interceptedUpdateMethod);
}

- (void)interceptAndStartAccelerometerUpdatesToQueue:(NSOperationQueue *)queue withHandler:(CMAccelerometerHandler)handler
{
    Method oldMethod = class_getInstanceMethod([CMMotionManager class], @selector(startAccelerometerUpdatesToQueue:withHandler:));
    Method newMethod = class_getInstanceMethod([CMMotionManager class], @selector(interceptAndStartAccelerometerUpdatesToQueue:withHandler:));
    method_exchangeImplementations(newMethod, oldMethod);
    
    [self interceptAndStartAccelerometerUpdatesToQueue:queue withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
        [self procesAccelertionData:accelerometerData.acceleration];
        handler(accelerometerData, error);
        if(error) {
            NSLog(@"%@", error);
        }
    }];
}

- (void)procesAccelertionData:(CMAcceleration)acceleration
{
    UIDeviceOrientation currentDeviceOrientation;
    
    if (acceleration.x >= 0.75) {
        currentDeviceOrientation = UIDeviceOrientationLandscapeLeft;
    }
    else if (acceleration.x <= -0.75) {
        currentDeviceOrientation = UIDeviceOrientationLandscapeRight;
    }
    else if (acceleration.y <= -0.75) {
        currentDeviceOrientation = UIDeviceOrientationPortrait;
    }
    else if (acceleration.y >= 0.75) {
        currentDeviceOrientation = UIDeviceOrientationPortraitUpsideDown;
    }
    else if (acceleration.z <= -0.75) {
        currentDeviceOrientation = UIDeviceOrientationFaceUp;
    }
    else if (acceleration.z >= 0.75) {
        currentDeviceOrientation = UIDeviceOrientationFaceDown;
    }
    else {
        return;
    }
    
    NSNumber *lastOrientation = objc_getAssociatedObject(self, @selector(deviceOrientation));
    
    if ([lastOrientation integerValue] != currentDeviceOrientation) {
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"_deviceOrientation", @"eventType",
                                               [NSDate date], @"timestamp", nil];
        [dataDictionary setObject:[NSNumber numberWithInt:currentDeviceOrientation] forKey:@"orientation"];
        NSLog(@"Event Data Received: %@", dataDictionary);

        objc_setAssociatedObject(self, @selector(deviceOrientation),
                                 [NSNumber numberWithInt:currentDeviceOrientation],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

@end
