//
//  CGExtensions.h
//  Sprachenraetsel
//
//  Created by Stefan Ueter on 09.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

@import Foundation;
@import UIKit;



CGSize CGSizeScaleToSize(CGSize oldSize, CGSize newSize, BOOL upscale);

CGPoint CGSizeCenterInSize(CGSize size, CGSize parentSize);

CGRect CGRectCenterXInRect(CGRect rect, CGRect parentRect);

CGRect CGRectCenterYInRect(CGRect rect, CGRect parentRect);

CGRect CGRectCenterOverPoint(CGRect rect, CGPoint point);

CGRect CGRectCopy(CGRect rect);

CGSize CGSizeScaleByFactor(CGSize size, float factor);

CGPoint CGPointScaleByFactor(CGPoint point, float factor);

CGRect CGRectScaleByFactor(CGRect rect, float factor);

CGRect CGSizeCenterInRect(CGSize size, CGRect rect);

CGRect CGRectCenterInRect(CGRect rect, CGRect parentRect);

CGRect CGRectWithSize(CGSize size);

CGPoint CGPointRelativeToCGRect(CGPoint point, CGRect rect);

CGPoint CGPointAddPointTranslation(CGPoint point, CGPoint translation);
                                   
CGRect CGRectInset2(CGRect rect, UIEdgeInsets insets);

CGSize CGSizeOutset(CGSize size, UIEdgeInsets insets);

CGRect CGRectOutset(CGRect rect, UIEdgeInsets insets);

CGSize CGSizeMax(CGSize size1, CGSize size2);