//
//  ViewController.m
//  PDLocationService
//
//  Created by liang on 2018/3/1.
//  Copyright © 2018年 PipeDog. All rights reserved.
//

#import "ViewController.h"
#import "PDLocationService.h"

@interface ViewController () <PDLocationServiceProtocol>

@end

@implementation ViewController

- (void)dealloc {
    [PDLocationService.defaultService unbind:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [PDLocationService.defaultService bind:self];
}

- (IBAction)startLocation:(id)sender {
    [PDLocationService.defaultService startUpdatingLocation];
}

- (IBAction)startLocationWithCallback:(id)sender {
    [PDLocationService.defaultService startUpdatingLocation:^(CLLocation *location, NSError *error) {
        if (error) {
            NSLog(@"error = %@", error.localizedDescription);
        } else {
            CLLocationCoordinate2D coordinate = location.coordinate;
            NSLog(@"latitude = %lf, longitude = %lf", coordinate.latitude, coordinate. longitude);
        }
    }];
}

- (IBAction)stopLocation:(id)sender {
    [PDLocationService.defaultService stopUpdatingLocation];
}

#pragma mark - PDLocationServiceProtocol
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    NSLog(@"%s", __FUNCTION__);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    NSLog(@"%s", __FUNCTION__);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
}

@end
