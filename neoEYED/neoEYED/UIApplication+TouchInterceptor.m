//
//  UIApplication+TouchInterceptor.m
//  neoEYED
//

#import "UIApplication+TouchInterceptor.h"
#import <objc/runtime.h>

@implementation UIApplication (TouchInterceptor)

@dynamic startPoint, zoomGesture;

+ (void)load
{
    objc_setAssociatedObject(self, @selector(zoomGesture), [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
   
    Method eventMethod = class_getInstanceMethod(self, @selector(sendEvent:));
    Method interceptedEventMethod = class_getInstanceMethod(self, @selector(interceptAndSendEvent:));
    method_exchangeImplementations(eventMethod, interceptedEventMethod);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunchingWithOptionsNotification:)
                                                 name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActiveNotification:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForegroundNotification:)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterBackgroundNotification:)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminateNotification:)
                                                 name:UIApplicationWillTerminateNotification object:nil];
}

+ (void)applicationDidFinishLaunchingWithOptionsNotification:(NSNotification *)notification
{
    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"_applicationDidFinishLaunchingWithOptionsNotification", @"eventType",
                                           [NSDate date], @"timestamp", nil];
    NSLog(@"Event Data Received: %@", dataDictionary);
}

+ (void)applicationDidBecomeActiveNotification:(NSNotification *)notification
{
    NSMutableDictionary *dataDictionary = [NSMutableDictionary
                                           dictionaryWithObjectsAndKeys:@"_applicationDidBecomeActiveNotification", @"eventType",
                                           [NSDate date], @"timestamp", nil];
    NSLog(@"Event Data Received: %@", dataDictionary);
}

+ (void)applicationWillEnterForegroundNotification:(NSNotification *)notification
{
    NSMutableDictionary *dataDictionary = [NSMutableDictionary
                                           dictionaryWithObjectsAndKeys:@"_applicationWillEnterForegroundNotification", @"eventType",
                                           [NSDate date], @"timestamp", nil];
    NSLog(@"Event Data Received: %@", dataDictionary);
}

+ (void)applicationWillEnterBackgroundNotification:(NSNotification *)notification
{
    NSMutableDictionary *dataDictionary = [NSMutableDictionary
                                           dictionaryWithObjectsAndKeys:@"_applicationWillEnterBackgroundNotification", @"eventType",
                                           [NSDate date], @"timestamp", nil];
    NSLog(@"Event Data Received: %@", dataDictionary);
}

+ (void)applicationWillResignActiveNotification:(NSNotification *)notification
{
    NSMutableDictionary *dataDictionary = [NSMutableDictionary
                                           dictionaryWithObjectsAndKeys:@"_applicationWillResignActiveNotification", @"eventType",
                                           [NSDate date], @"timestamp", nil];
    NSLog(@"Event Data Received: %@", dataDictionary);
}


+ (void)applicationWillTerminateNotification:(NSNotification *)notification
{
    NSMutableDictionary *dataDictionary = [NSMutableDictionary
                                           dictionaryWithObjectsAndKeys:@"_applicationWillTerminateNotification", @"eventType",
                                           [NSDate date], @"timestamp", nil];
    NSLog(@"Event Data Received: %@", dataDictionary);
}


- (void)interceptAndSendEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        NSDictionary *dataDictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"_deviceShake", @"eventType",
                                    [NSDate date], @"timestamp", nil];
        NSLog(@"Event Data Received: %@", dataDictionary);
        return;
    }
    else {
        if(event.allTouches.count == 1) {
            UITouch *touch = [event.allTouches anyObject];
            if (touch.phase == UITouchPhaseBegan) {
                NSLog(@"Touch begin");
                CGPoint touchPoint = [touch locationInView:touch.gestureRecognizers.firstObject.view];
                NSDictionary *touchDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithFloat:touchPoint.x], @"x",
                                                 [NSNumber numberWithFloat:touchPoint.y], @"y", nil];
                objc_setAssociatedObject(self, @selector(startPoint), touchDictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
            else if (touch.phase == UITouchPhaseEnded) {
                NSLog(@"Touch end");
                CGPoint touchEndPoint = [touch previousLocationInView:touch.gestureRecognizers.firstObject.view];
                NSDictionary *endPointDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                    [NSNumber numberWithFloat:touchEndPoint.x], @"x",
                                                    [NSNumber numberWithFloat:touchEndPoint.y], @"y", nil];
                
                if (touch.tapCount == 1) {
                    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"_singleTap", @"eventType",
                                                           [NSDate date], @"timestamp", nil];
                    [dataDictionary setObject:endPointDictionary forKey:@"touch"];
                    NSLog(@"Event Data Received: %@", dataDictionary);
                }
                else if (touch.tapCount == 2) {
                    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"_doubleTap", @"eventType",
                                                           [NSDate date], @"timestamp", nil];
                    [dataDictionary setObject:endPointDictionary forKey:@"touch"];
                    NSLog(@"Event Data Received: %@", dataDictionary);
                }
                else {
                    BOOL isZoomGesture = [objc_getAssociatedObject(self, @selector(zoomGesture)) boolValue];
                    if (isZoomGesture) {
                        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"_twoFingerZoom", @"eventType", [NSDate date], @"timestamp", nil];
                        [dataDictionary setObject:endPointDictionary forKey:@"touch"];
                        NSLog(@"Event Data Received: %@", dataDictionary);
                        objc_setAssociatedObject(self, @selector(zoomGesture), [NSNumber numberWithBool:NO], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        return;
                    }
                    
                    NSDictionary *startPointDictionary = objc_getAssociatedObject(self, @selector(startPoint));
                    CGFloat distanceX = [[endPointDictionary objectForKey:@"x"] floatValue] - [[startPointDictionary objectForKey:@"x"] floatValue];
                    CGFloat distanceY = [[endPointDictionary objectForKey:@"y"] floatValue] - [[startPointDictionary objectForKey:@"y"] floatValue];
                    
                    NSString *eventType = @"";
                    if (fabs(distanceX) > fabs(distanceY)) {
                        if (distanceX > 0) {
                            eventType = @"_rightSwipe";
                        }
                        else {
                            eventType = @"_leftSwipe";
                        }
                    }
                    else {
                        if (distanceY > 0) {
                            eventType = @"_downSwipe";
                        }
                        else {
                            eventType = @"_upSwipe";
                        }
                    }
                    
                    NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:eventType, @"eventType",
                                                           [NSDate date], @"timestamp", nil];
                    [dataDictionary setObject:startPointDictionary forKey:@"touchBegin"];
                    [dataDictionary setObject:endPointDictionary forKey:@"touchEnd"];
                    NSLog(@"Event Data Received: %@", dataDictionary);
                }
            }
        }
        if(event.allTouches.count == 2) {
            objc_setAssociatedObject(self, @selector(zoomGesture), [NSNumber numberWithBool:YES], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    [self interceptAndSendEvent:event];
}

@end
