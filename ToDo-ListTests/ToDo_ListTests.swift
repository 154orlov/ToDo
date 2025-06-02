//
//  ToDo_ListTests.swift
//  ToDo-ListTests
//
//  Created by ipv6 on 02.06.2025.
//

import Testing

import XCTest
@testable import ToDo_List
import CoreData

final class TaskModelTests: XCTestCase {

    func testTaskModelInitialization() {
        let now = Date()
        let task = TaskModel(title: "Купить хлеб", detail: "В пекарне", createdAt: now, isCompleted: false)

        XCTAssertEqual(task.title, "Купить хлеб")
        XCTAssertEqual(task.detail, "В пекарне")
        XCTAssertEqual(task.createdAt, now)
        XCTAssertFalse(task.isCompleted)
    }

    func testTaskCompletionToggle() {
        var task = TaskModel(title: "Погладить кота", detail: "", createdAt: Date(), isCompleted: false)
        task.isCompleted.toggle()
        XCTAssertTrue(task.isCompleted)
    }
}

final class FilterTests: XCTestCase {

    func testFilteringTasksByTitle() {
        let tasks = [
            TaskModel(title: "Купить хлеб", detail: "", createdAt: Date(), isCompleted: false),
            TaskModel(title: "Позвонить маме", detail: "", createdAt: Date(), isCompleted: false),
            TaskModel(title: "Сделать зарядку", detail: "", createdAt: Date(), isCompleted: false)
        ]

        let query = "купить"
        let filtered = tasks.filter { $0.title.lowercased().contains(query.lowercased()) }

        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.title, "Купить хлеб")
    }
}

final class CoreDataTests: XCTestCase {
    var persistentContainer: NSPersistentContainer!

    override func setUp() {
        super.setUp()
        persistentContainer = NSPersistentContainer(name: "TaskDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        persistentContainer.persistentStoreDescriptions = [description]
        persistentContainer.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }
    }

    func testCreateTaskEntity() {
        let context = persistentContainer.viewContext
        let task = TaskEntity(context: context)
        task.title = "Тестовая задача"
        task.detail = "Детали"
        task.createdAt = Date()
        task.isCompleted = false

        try? context.save()

        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let results = try? context.fetch(request)

        XCTAssertEqual(results?.count, 1)
        XCTAssertEqual(results?.first?.title, "Тестовая задача")
    }
}
