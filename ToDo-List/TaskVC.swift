//
//  TaskVC.swift
//  ToDo-List
//
//  Created by ipv6 on 24.05.2025.
//

import UIKit

protocol SaveTaskDelegate: AnyObject {
    func saveTask(task: TaskModel)
}
 
class TaskVC: UIViewController {
    
    @IBOutlet weak var taskField: UITextField!
    
    @IBOutlet weak var taskView: UITextView!
    
    @IBOutlet weak var saveTask: UIButton!
    
    
    weak var saveTaskDeleagate: SaveTaskDelegate?
    
    var onSave: ((_ title: String, _ detail: String) -> Void)?
    
    var existingTask: TaskModel?
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let task = existingTask {
            taskField.text = task.title
            taskView.text = task.detail
        }
    }
    
    // MARK: - saveTaskBtn
    
    @IBAction func saveTaskBtnPressed(_ sender: Any) {
        
        guard let title = taskField.text, !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите заголовок задачи.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ок", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let detail = taskView.text ?? ""
        
        if let _ = existingTask {
            onSave?(title, detail)
        } else {
            let task = TaskModel(title: title, detail: detail, createdAt: Date(), isCompleted: false)
            saveTaskDeleagate?.saveTask(task: task)
        }
        
        dismiss(animated: true, completion: nil)
    }
}
