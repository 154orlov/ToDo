//
//  NetworkTask.swift
//  ToDo-List
//
//  Created by ipv6 on 28.05.2025.
//
struct TaskResponse: Codable {
    let todos: [NetworkTask]
}
struct NetworkTask: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
