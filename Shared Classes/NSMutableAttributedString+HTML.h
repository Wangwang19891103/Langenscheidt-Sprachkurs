//
//  NSAttributedString+(HTML).h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 19.11.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;


@interface NSMutableAttributedString (HTML)

- (void) parseHTML;

- (void) parseHTMLWithCustomAttributesBlock:(NSDictionary* (^)(NSString* tagName)) customAttributesBlock;

@end
