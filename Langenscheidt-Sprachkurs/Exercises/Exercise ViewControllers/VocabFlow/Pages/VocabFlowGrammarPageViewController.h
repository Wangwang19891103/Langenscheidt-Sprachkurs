//
//  VocabFlowGrammarPageViewController.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 10.02.16.
//  Copyright © 2016 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VocabFlowPageViewController.h"

@interface VocabFlowGrammarPageViewController : VocabFlowPageViewController

@property (strong, nonatomic) IBOutlet UILabel *labelLang1;
@property (strong, nonatomic) IBOutlet UILabel *labelLang2;
//@property (strong, nonatomic) IBOutlet UILabel *aaa;
//@property (nonatomic, assign) uint a;


@property (nonatomic, strong) NSDictionary* dict;

@end
