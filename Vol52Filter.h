/*
 *  Vol52Filter.h
 *  Ellipsoid Volume Plugin
 *
 *  Created by Rafael Cruz on 15/12/13.
 *  Copyright (c) 2013, 2014 Rafael Cruz. All rights reserved.
 *
 *
 *  This file is part of Ellipsoid Volume, a OsiriX Plugin.
 *
 *  Ellipsoid Volume is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  Ellipsoid Volume is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with Ellipsoid Volume.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Foundation/Foundation.h>
#import <OsiriXAPI/PluginFilter.h>
#import "Vol52WindowController.h"
#import "Vol52RoiManager.h"

@interface Vol52Filter : PluginFilter {
    
}

- (long) filterImage:(NSString*) menuName;

@end
