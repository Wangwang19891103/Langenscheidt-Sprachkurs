//
//  ScreenName.m
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 09.08.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import "ScreenName.h"
#import "PearlTitle.h"


NSString* const kScreenNameDelimiter = @"/";


@implementation ScreenName


+ (NSString*) nameForCourse:(Course *)course {
    
    return [NSString stringWithFormat:@"%@", course.title];
}


+ (NSString*) nameForLesson:(Lesson *)lesson {
    
    NSString* titlePath = [NSString stringWithFormat:@"%@%@%@",
                       lesson.course.title,
                       kScreenNameDelimiter,
                       lesson.title
                       ];
    
    return [NSString stringWithFormat:@"%@", titlePath];
}


+ (NSString*) nameForPearl:(Pearl *)pearl {
    
    NSString* pearlTitle = [PearlTitle titleForPearl:pearl];
    
    NSString* titlePath = [NSString stringWithFormat:@"%@%@%@%@%@",
                           pearl.lesson.course.title,
                           kScreenNameDelimiter,
                           pearl.lesson.title,
                           kScreenNameDelimiter,
                           pearlTitle
                           ];
    
    return [NSString stringWithFormat:@"%@", titlePath];
}

@end
