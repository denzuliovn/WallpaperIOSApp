import UIKit
import Photos

class DetailViewController: UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var upBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var moveScrollView: UIScrollView!
    
    var imageURL: String?
    var isFullScreen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Đặt delegate và thiết lập min/max zoom
        moveScrollView.delegate = self
        moveScrollView.minimumZoomScale = 1.0
        moveScrollView.maximumZoomScale = 4.0
        
        // Tải ảnh
        if let urlString = imageURL, let url = URL(string: urlString) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async {
                        self.imageView.image = UIImage(data: data)
                        // Gọi updateImageFrame() sau khi ảnh đã được gán
                        self.updateImageFrame()
                    }
                }
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveImage(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status == .authorized {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
        } else if status == .denied || status == .restricted {
            showPermissionAlert()
        } else {
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
                    } else {
                        self.showPermissionAlert()
                    }
                }
            }
        }
    }

    @IBAction func shareImage(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true)
    }
    
    // Nút zoom: phóng to ảnh nếu đang ở mức 1.0, ngược lại trả về 1.0
    @IBAction func toggleFullscreen(_ sender: UIButton) {
        if moveScrollView.zoomScale == 1.0 {
            moveScrollView.setZoomScale(moveScrollView.maximumZoomScale, animated: true)
        } else {
            moveScrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
    
    func updateImageFrame() {
        guard let image = imageView.image else { return }
        
        let scrollSize = moveScrollView.bounds.size
        let imageSize = image.size
        let imageRatio = imageSize.width / imageSize.height
        
        let newWidth = scrollSize.width
        let newHeight = newWidth / imageRatio
        
        imageView.frame = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
        moveScrollView.contentSize = imageView.frame.size
        centerImage()
    }
    
    func centerImage() {
        let scrollSize = moveScrollView.bounds.size
        let imageFrame = imageView.frame
        
        let verticalInset = imageFrame.height < scrollSize.height
            ? (scrollSize.height - imageFrame.height) / 2
            : 0
        let horizontalInset = imageFrame.width < scrollSize.width
            ? (scrollSize.width - imageFrame.width) / 2
            : 0
        
        moveScrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    // Hàm xử lý kết quả lưu ảnh
    @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let alert = UIAlertController(
            title: error == nil ? "Thành công" : "Lỗi",
            message: error == nil ? "Hình ảnh đã được lưu vào thư viện." : "Không thể lưu hình ảnh.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // Hiển thị cảnh báo nếu quyền bị từ chối
    func showPermissionAlert() {
        let alert = UIAlertController(
            title: "Quyền bị từ chối",
            message: "Vui lòng cấp quyền truy cập thư viện ảnh trong Cài đặt.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Hủy", style: .cancel))
        alert.addAction(UIAlertAction(title: "Mở Cài Đặt", style: .default, handler: { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        }))
        present(alert, animated: true)
    }
}
