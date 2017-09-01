//
//  TypesViewControllers.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 24.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;
#import "ExerciseTypes.h"

@interface TypesViewControllers : UITableViewController {
    
    NSArray* _types;
}


@end



@interface TypesCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* label;

@property (nonatomic, assign) ExerciseType type;

@end