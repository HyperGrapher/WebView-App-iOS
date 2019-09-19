//
//  Widget+CoreDataProperties.swift
//  
//
//  Created by burak mestan on 19.09.2019.
//
//

import Foundation
import CoreData


extension Widget {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Widget> {
        return NSFetchRequest<Widget>(entityName: "Widget")
    }

    @NSManaged public var name: String?
    @NSManaged public var url: String?

}
