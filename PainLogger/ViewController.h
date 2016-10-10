//
//  ViewController.h
//  PainLogger
//
//  Created by Liem Do on 11/15/15.
//  Copyright © 2015 Nhan Do. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
    <UIPickerViewDelegate, UIPickerViewDataSource>

@property (strong, nonatomic) NSArray *pain_values;

- (IBAction)SubmitValue:(id)sender;

- (IBAction)SendEmail:(id)sender;


@end

