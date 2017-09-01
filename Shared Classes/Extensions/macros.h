//
//  macros.h
//  OxfordLetsGo
//
//  Created by Stefan Ueter on 08.07.13.
//  Copyright (c) 2013 Stefan Ueter. All rights reserved.
//

#ifndef OxfordLetsGo_macros_h
#define OxfordLetsGo_macros_h

#define MAIN_BUNDLE [NSBundle mainBundle]
#define CLEAR_COLOR [UIColor clearColor]
#define WHITE_COLOR [UIColor whiteColor]
#define BLACK_COLOR [UIColor blackColor]

#define color(pred, pgreen, pblue) [UIColor colorWithRed:pred/255.0 green:pgreen/255.0 blue:pblue/255.0 alpha:1]
#define colorWithAlpha(red, green, blue, alpha) [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha: 255.0]


#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#   define DLog(...)
#endif


#define createMutableArray(name) NSMutableArray* name = [NSMutableArray array]

#endif
