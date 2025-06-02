//
//  TaskEntity.swift
//  ToDo-List
//
//  Created by ipv6 on 01.06.2025.
//

import Foundation
import CoreData

@objc(TaskEntity)
public class TaskEntity: NSManagedObject {}

extension TaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskEntity> {
        return NSFetchRequest<TaskEntity>(entityName: "TaskEntity")
    }

    @NSManaged public var title: String?
    @NSManaged public var detail: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var isCompleted: Bool
}
