//
//  ReorderableViewProtocol.h
//  Langenscheidt-Sprachkurs
//
//  Created by Stefan Ueter on 14.12.15.
//  Copyright © 2015 mobilinga. All rights reserved.
//

#ifndef ReorderableViewProtocol_h
#define ReorderableViewProtocol_h

@protocol ReorderableViewProtocol <NSObject>

@required

- (void) setNormalAppearance;
- (void) setGhostAppearance;

@end

#endif /* ReorderableViewProtocol_h */
