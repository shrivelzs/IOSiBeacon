//
//  ViewController.m
//  Gisdelab
//
//  Created by shuzhang2@clarku.edu on 9/4/2015.
//  Copyright (c) 2015 shuzhang2@clarku.edu. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()<ESTBeaconConnectionDelegate>
{
    BOOL isAnimated;
    
}
@property (strong, nonatomic) IBOutlet UILabel *temperatureLabel;

@property (strong, nonatomic) IBOutlet UILabel *activityLabel;

@property (nonatomic,strong) ESTBeaconConnection *beaconConnection;

@property (nonatomic, strong) NSTimer *readTemperatureWithInterval;
@end

@implementation ViewController

//-(instancetype)init
//{
//    self = [self init];
//    if (self) {
//        NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
//        
//        
//        self.beaconConnection = [ESTBeaconConnection  connectionWithProximityUUID:uuid major:30229 minor:30723 delegate:self] ;
//        
//    }return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSUUID *uuid = [[NSUUID alloc]initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
    
    
    self.beaconConnection = [ESTBeaconConnection  connectionWithProximityUUID:uuid major:30229 minor:30723 delegate:self] ;

    //[self.activityIndicator startAnimating];
    
    [self.beaconConnection startConnection];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (self.beaconConnection.connectionStatus == ESTConnectionStatusConnected || self.beaconConnection.connectionStatus == ESTConnectionStatusConnecting)
    {
        if (self.readTemperatureWithInterval)
        {
            [self.readTemperatureWithInterval invalidate];
            self.readTemperatureWithInterval = nil;
        }
        
        [self.beaconConnection cancelConnection];
    }
}

#pragma mark - Beacon Operations
- (void)readBeaconTemperature
{
    //Reading temperature is asynchronous task, so we need to wait for completion block to be called.
    [self.beaconConnection readTemperatureWithCompletion:^(NSNumber* value, NSError *error) {
        
        if (!error)
        {
            self.temperatureLabel.text = [NSString stringWithFormat:@"%.1f°C", [value floatValue]];
            //[self.activityIndicator stopAnimating];
        }
        else
        {
            self.activityLabel.text = [NSString stringWithFormat:@"Error:%@", [error localizedDescription]];
            self.activityLabel.textColor = [UIColor redColor];
        }
    }];
}

#pragma mark - ESTBeaconDelegate
- (void)beaconConnectionDidSucceed:(ESTBeaconConnection *)connection
{
    //[self.activityIndicator stopAnimating];
    //self.activityIndicator.alpha = 0.;
    self.activityLabel.text = @"Connected!";
    
    //After successful connection, we can start reading temperature.
    self.readTemperatureWithInterval = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                                        target:self
                                                                      selector:@selector(readBeaconTemperature)
                                                                      userInfo:nil repeats:YES];
    
    [self readBeaconTemperature];
}

- (void)beaconConnection:(ESTBeaconConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Something went wrong. Beacon connection Did Fail. Error: %@", error);
    
    //[self.activityIndicator stopAnimating];
    //self.activityIndicator.alpha = 0.;
    
    self.activityLabel.text = @"Connection failed";
    self.activityLabel.textColor = [UIColor redColor];
    
    UIAlertView* errorView = [[UIAlertView alloc] initWithTitle:@"Connection error"
                                                        message:error.localizedDescription
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    
    [errorView show];
}

@end
