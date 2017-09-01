//
//  TypesViewControllers.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 24.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import "TypesViewControllers.h"
#import "CourseViewController.h"


@implementation TypesViewControllers

- (id) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    
    _types = [ExerciseTypes implementedTypes];
    
    return self;
}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"ShowCourses"]) {
        
        CourseViewController* controller = (CourseViewController*)segue.destinationViewController;
        TypesCell* cell = (TypesCell*)sender;
        controller.filterType = cell.type;
    }
}


- (void) viewDidLoad {
    
    [super viewDidLoad];
    
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _types.count;
}


- (UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TypesCell* cell = [tableView dequeueReusableCellWithIdentifier:@"TypesCell" forIndexPath:indexPath];
    
    ExerciseType type = [_types[indexPath.row] integerValue];
    cell.label.text = [ExerciseTypes stringForExerciseType:type];
    cell.type = type;
    
    return cell;
}



@end




@implementation TypesCell

@synthesize label;
@synthesize type;

@end