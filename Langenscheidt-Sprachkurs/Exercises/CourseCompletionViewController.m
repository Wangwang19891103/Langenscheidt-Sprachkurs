//
//  CourseCompletionViewController.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 05.06.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "CourseCompletionViewController.h"

@implementation CourseCompletionViewController


- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    return self;
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    self.titleLabel.text = self.title;
}


- (BOOL) prefersStatusBarHidden {
    
    return YES;
}


- (void) fadeOut {
    
    [UIView animateWithDuration:0.3 animations:^{
        
        _contentView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
    }];
}


- (IBAction)actionButton:(id)sender {
    
    _nextBlock();
}





@end
