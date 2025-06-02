//
//  ViewController.swift
//  ToDo-List
//
//  Created by ipv6 on 23.05.2025.
//

import UIKit
import CoreData

class ViewController: UIViewController, SaveTaskDelegate, UITableViewDelegate {
    
    func saveTask(task: TaskModel) {
        saveTaskToCoreData(task: task)
        loadTasksFromCoreData()
            tableView.reloadData()
    }

    var tasks: [TaskModel] = []
    
    let searchController = UISearchController(searchResultsController: nil)

    var filteredTasks: [TaskModel] = []
    
    var isSearchActive: Bool {
        return !searchController.searchBar.text!.isEmpty
    }

    @IBOutlet weak var tableView: UITableView!
    
//MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let nib = UINib(nibName: "TableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        

        if tasksFromCoreData().isEmpty {
            loadTasksFromNetwork()
        } else {
            loadTasksFromCoreData()
        }

        
        // Настройка поисковика
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Поиск задач"
            navigationItem.searchController = searchController
            definesPresentationContext = true
    }
    
// MARK: - Core Data
    
    func tasksFromCoreData() -> [TaskModel] {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        if let results = try? context.fetch(fetchRequest) {
            return results.map {
                TaskModel(
                    title: $0.title ?? "",
                    detail: $0.detail ?? "",
                    createdAt: $0.createdAt ?? Date(),
                    isCompleted: $0.isCompleted
                )
            }
        }
        return []
    }

    
    func saveTaskToCoreData(task: TaskModel) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = TaskEntity(context: context)
        entity.title = task.title
        entity.detail = task.detail
        entity.createdAt = task.createdAt
        entity.isCompleted = task.isCompleted

        do {
            try context.save()
        } catch {
            print("Ошибка сохранения: \(error)")
        }
    }



    func loadTasksFromCoreData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        if let results = try? context.fetch(fetchRequest) {
            self.tasks = results.map {
                TaskModel(
                    title: $0.title ?? "",
                    detail: $0.detail ?? "",
                    createdAt: $0.createdAt ?? Date(),
                    isCompleted: $0.isCompleted
                )
            }
            tableView.reloadData()
        }
    }

    
    func deleteTaskFromCoreData(at index: Int) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        if let results = try? context.fetch(fetchRequest), index < results.count {
            context.delete(results[index])
            try? context.save()
        }
    }


    
    //MARK: - Переход на другой ViewController
    
    @IBAction func showTaskVC(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let taskVC = storyboard.instantiateViewController(withIdentifier: "TaskVC") as! TaskVC
        taskVC.saveTaskDeleagate = self
        present(taskVC, animated: true, completion: nil)
        
    }
    
    //MARK: - DateFormatter
    
    let formatter: DateFormatter = {
            let f = DateFormatter()
            f.dateStyle = .short
            f.timeStyle = .short
            return f
        }()
    
    
    //MARK: - Загрузка из json
    
    func loadTasksFromNetwork() {
        guard let url = URL(string: "https://dummyjson.com/todos") else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let response = try decoder.decode(TaskResponse.self, from: data)
                    
                    let convertedTasks = response.todos.map {
                        TaskModel(
                            title: $0.todo,
                            detail: "",
                            createdAt: Date(),
                            isCompleted: $0.completed
                        )
                    }

                    DispatchQueue.main.async {
                        for task in convertedTasks {
                            self.saveTaskToCoreData(task: task)
                        }
                        self.loadTasksFromCoreData()
                    }

                } catch {
                    print("Ошибка при парсинге JSON: \(error)")
                }
            } else if let error = error {
                print("Ошибка сети: \(error)")
            }
        }.resume()
    }

}

// MARK: - DataSource

extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchActive ? filteredTasks.count : tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell else { return UITableViewCell() }
        let task = isSearchActive ? filteredTasks[indexPath.row] : tasks[indexPath.row]
        cell.header?.text = task.title
        cell.detail?.text = task.detail
        cell.detail?.numberOfLines = 2
        cell.createdAt?.text = "Создано: \(formatter.string(from: task.createdAt))"
        
        // Установка цвета кнопки чекбокса
        
        cell.checkmark.setImage(UIImage(systemName: "checkmark" ), for: .normal)
        cell.checkmark.tintColor = task.isCompleted ? .systemGreen : .lightGray
        
// MARK: - Логика cell удаление , редактирование и checkmark
        
            //  Нажал на галочку → isCompleted меняется в массиве
            cell.onToggleComplete = { [weak self] in
            guard let self = self else { return }

            self.tasks[indexPath.row].isCompleted.toggle()

            // Обновляем только одну строку
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }

            
            // Привязка действия удаления
            cell.onDelete = { [weak self] in
                guard let self = self else { return }
                self.deleteTaskFromCoreData(at: indexPath.row)
                self.loadTasksFromCoreData()
            }
            
            
            // Привязка действия редактирования
            cell.onEdit = { [weak self] in
                guard let self = self else { return }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let taskVC = storyboard.instantiateViewController(withIdentifier: "TaskVC") as! TaskVC
                
                // Передаём текущую задачу
                let task = self.tasks[indexPath.row]
                taskVC.existingTask = task
                
                // Заменяем задачу после редактирования
                taskVC.onSave = { [weak self] title, detail in
                    guard let self = self else { return }
                    self.tasks[indexPath.row].title = title
                    self.tasks[indexPath.row].detail = detail
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                
                self.present(taskVC, animated: true, completion: nil)
            }
            
            return cell
        }
        
        
    }

// MARK: - Search Controller
    
extension ViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterTasks(for: searchController.searchBar.text ?? "")
    }

    func filterTasks(for query: String) {
        filteredTasks = tasks.filter { $0.title.lowercased().contains(query.lowercased()) }
        tableView.reloadData()
    }
}
