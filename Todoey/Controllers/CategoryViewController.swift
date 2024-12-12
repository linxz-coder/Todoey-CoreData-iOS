import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    
    //MARK: - 全局变量
    var categoryArray = [CategoryTitle]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
    }
    
    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray[indexPath.row]
            
        }
        
        
    }
    
    
    //MARK: - Data Manipulation Methods
    func saveCategories(){
        do{
            try context.save()
        } catch {
            print("Error Saving Context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadCategories(_ request: NSFetchRequest<CategoryTitle> = CategoryTitle.fetchRequest()){
        do{
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context. \(error)")
        }
        
        tableView.reloadData()
    }
    
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default)
            { (action) in
                
                let newCategory = CategoryTitle(context: self.context)
                
                newCategory.name = textField.text!
                
                self.categoryArray.append(newCategory)
                
                self.saveCategories()
                
            }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
        
    }
    
    
    
    
    
    
}
