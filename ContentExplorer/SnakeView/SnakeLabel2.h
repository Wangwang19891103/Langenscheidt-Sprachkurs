//
//  SnakeLabel.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 22.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface SnakeLabel : UILabel {
    
    NSAttributedString* _normalString;
    NSAttributedString* _selectedString;
}

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, copy) NSString* string;

@end
