//
//  CoffeePlace.h
//  CoffeeFinder
//
//  Created by Nathan Lanza on 11/11/15.
//  Copyright © 2015 Nathan Lanza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CoffeePlace : NSObject

@property MKMapItem *mapItem;
@property float milesDifference;

@end
