//
//  ErrorViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "ErrorViewController.h"

@implementation ErrorViewController

@synthesize label;

- (void) setErrorDescription:(NSString*) description {
    
    self.label.text = description;
    
    [self.view setNeedsLayout];
}

@end
