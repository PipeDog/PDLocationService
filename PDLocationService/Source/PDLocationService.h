//
//  PDLocationService.h
//  PDLocationService
//
//  Created by liang on 2018/3/1.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^PDLocaionBlock)(CLLocation *location, NSError *error);
typedef void (^PDPlacemarkBlock)(CLPlacemark *placemark, NSError *error);

@protocol PDLocationServiceProtocol <NSObject>

@optional
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations;
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;

@end

@interface PDLocationService : NSObject

@property (class, strong, readonly) PDLocationService *defaultService;

// The functions provided by the system are convenient enough to not be processed.
@property (nonatomic, strong, readonly) CLGeocoder *geocoder;

- (void)startUpdatingLocation:(PDLocaionBlock)completion;

- (void)startUpdatingLocation;

- (void)stopUpdatingLocation;

- (void)bind:(id <PDLocationServiceProtocol>)delegate;

- (void)unbind:(id <PDLocationServiceProtocol>)delegate;

@end
