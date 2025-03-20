import UIKit
import Alamofire
import SDWebImage

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var mySearchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var images: [(url: String, height: CGFloat)] = [] // Lưu URL và chiều cao ảnh
    var page = 1
    var currentQuery = "nature"
    let apiKey = "49399959-0b902b0ed34d00610bbeb69b9"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        mySearchBar.delegate = self
        
        fetchImages(query: currentQuery)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ImageCell")
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshImages), for: .valueChanged)
        tableView.refreshControl = refreshControl

        tableView.separatorStyle = .none
    }
    
    func fetchImages(query: String) {
        let url = "https://pixabay.com/api/?key=\(apiKey)&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&image_type=photo&page=\(page)"
        
        AF.request(url).responseJSON { response in
            guard let data = response.data else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let hits = json?["hits"] as? [[String: Any]] {
                    var newImages: [(String, CGFloat)] = []
                    
                    for hit in hits {
                        if let url = hit["webformatURL"] as? String,
                           let width = hit["imageWidth"] as? CGFloat,
                           let height = hit["imageHeight"] as? CGFloat {
                            
                            // Tính chiều cao dựa vào chiều rộng màn hình và tỷ lệ ảnh
                            let screenWidth = self.tableView.frame.width
                            let aspectRatio = height / width
                            let calculatedHeight = screenWidth * aspectRatio
                            
                            newImages.append((url, calculatedHeight))
                        }
                    }
                    
                    if self.page == 1 {
                        self.images = newImages
                    } else {
                        self.images.insert(contentsOf: newImages, at: 0)
                    }
                    self.tableView.reloadData()
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    @objc func refreshImages() {
        page += 1
        fetchImages(query: currentQuery)
        tableView.refreshControl?.endRefreshing()
    }

    // MARK: - UITableView Data Source
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return images[indexPath.row].height
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath)
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        let imageHeight = images[indexPath.row].height
        let imageView = UIImageView(frame: CGRect(
            x: 0,
            y: 0,
            width: tableView.frame.width,
            height: imageHeight
        ))
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true  // Cho phép nhận sự kiện nhấn vào ảnh

        if let url = URL(string: images[indexPath.row].url) {
            imageView.sd_setImage(with: url, completed: nil)
        }

        // **Thêm gesture recognizer để mở DetailViewController**
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
        imageView.tag = indexPath.row  // Lưu index ảnh để lấy URL sau này

        cell.contentView.addSubview(imageView)
        
        return cell
    }

    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        guard let imageView = sender.view else { return }
        let index = imageView.tag  // Lấy index của ảnh được nhấn
        
        if let detailVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailVC.imageURL = images[index].url
            detailVC.modalPresentationStyle = .fullScreen  // Hiển thị toàn màn hình
            present(detailVC, animated: true, completion: nil) // Thay thế pushViewController
            print("Image tapped!")
        }
    }

    // MARK: - Search from Pixabay API
    func searchBarSearchButtonClicked(_ mySearchBar: UISearchBar) {
        if let text = mySearchBar.text, !text.isEmpty {
            images.removeAll()
            page = 1
            currentQuery = text
            fetchImages(query: text)
        }
        mySearchBar.resignFirstResponder()
    }
}
