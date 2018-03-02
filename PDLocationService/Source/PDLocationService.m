//
//  PDLocationService.m
//  PDLocationService
//
//  Created by liang on 2018/3/1.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "PDLocationService.h"

@interface PDLocationService () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, copy) PDLocaionBlock updateLocationBlock;
@property (nonatomic, strong) NSHashTable<id<PDLocationServiceProtocol>> *delegates;

@end

@implementation PDLocationService

+ (PDLocationService *)defaultService {
    static PDLocationService *service;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[PDLocationService alloc] init];
    });
    return service;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.locationManager.delegate = self;

        // Add NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription into info.plist.
        if (@available(iOS 8, *)) {
            // requestAlwaysAuthorization
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    return self;
}

- (void)startUpdatingLocation:(PDLocaionBlock)completion {
    if ([CLLocationManager locationServicesEnabled] == NO) {
        if (completion) {
            NSError *error = [NSError errorWithDomain:@"PDLocationServiceNoPermissions" code:103 userInfo:@{@"description": @"[CLLocationManager locationServicesEnabled] == NO"}];
            completion(nil, error);
        }
        return;
    }
    self.updateLocationBlock = completion;
    [self.locationManager stopUpdatingLocation]; // Stop last location.
    [self.locationManager startUpdatingLocation];
}

- (void)startUpdatingLocation {
    if ([CLLocationManager locationServicesEnabled] == NO) {
        return;
    }
    [self.locationManager stopUpdatingLocation]; // Stop last location.
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingLocation {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *location = locations.lastObject;
    if (self.updateLocationBlock) self.updateLocationBlock(location, nil);
    
    for (id<PDLocationServiceProtocol> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
            [delegate locationManager:manager didUpdateLocations:locations];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    for (id<PDLocationServiceProtocol> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
            [delegate locationManager:manager didUpdateHeading:newHeading];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.updateLocationBlock) self.updateLocationBlock(nil, error);
    
    for (id<PDLocationServiceProtocol> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
            [delegate locationManager:manager didFailWithError:error];
        }
    }
}

#pragma mark - Delegate Methods
- (void)bind:(id<PDLocationServiceProtocol>)delegate {
    if (![delegate conformsToProtocol:@protocol(PDLocationServiceProtocol)]) return;
    if ([self.delegates containsObject:delegate]) return;
    
    [self.delegates addObject:delegate];
}

- (void)unbind:(id<PDLocationServiceProtocol>)delegate {
    if (delegate) [self.delegates removeObject:delegate];
}

#pragma mark - Getter Methods
- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 10;
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc] init];
    }
    return _geocoder;
}

- (CLLocation *)location {
    return self.locationManager.location;
}

- (NSHashTable<id<PDLocationServiceProtocol>> *)delegates {
    if (!_delegates) {
        _delegates = [NSHashTable weakObjectsHashTable];
    }
    return _delegates;
}

@end
