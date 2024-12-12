import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    //MARK: - 全局变量
    var itemArray = [Item]()
    
    var selectedCategory : CategoryTitle? {
        didSet{
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        searchBar.delegate = self
        
        //连接手机的Documents文件夹
        let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
        print(dataFilePath!)
        
//        loadItems()
    }
    
    //每个分区section有多少行row
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    //用哪个cell；indexPath即对应上面的row
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //选择cell会发生的事情
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //反向勾选
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //删除数据（需要按照顺序）
//        context.delete(itemArray[indexPath.row]) //从数据库删除
//        itemArray.remove(at: indexPath.row) //从视图删除
        
        // 刷新当前行
//        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        saveItems()
        
        //选择后背景色会消失
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - add new items
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default)
            { (action) in
                
                let newItem = Item(context: self.context)
                
                newItem.title = textField.text!
                newItem.done = false
                newItem.parentCategory = self.selectedCategory
                
                self.itemArray.append(newItem)
                
                self.saveItems()
                
                //重新渲染tableView
                self.tableView.reloadData()
            }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    //MARK: - Model Manipulation Methods
    
    func saveItems(){
        
        do{
            try context.save()
        } catch {
            print("Error Saving Context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadItems(_ request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil){
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        do{
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context. \(error)")
        }
        
        tableView.reloadData()
    }
    

    
}

//MARK: - Search Bar
extension TodoListViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        
        //[cd]指对大小写Capital和变音diacritic不敏感
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)] //只有一个rule
        
        loadItems(request, predicate: predicate)
    }
    
    //当searchBar里面文字变动时唤起
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //当searchBar没有文字，即清空时回到初始界面
        if searchBar.text?.count == 0{
            loadItems()
            //光标和键盘消失
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
