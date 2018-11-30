//
//  ViewController.swift
//  CollectionView-Pagination
//
//  Created by Rajesh on 30/11/18.
//  Copyright © 2018 Rajesh. All rights reserved.
//

import UIKit
import SDWebImage
class ViewController: UIViewController {
    //MARK:- IBOutlet Properties
    @IBOutlet weak var collectionViewGrid: UICollectionView!
    
    //MARK:- CollectionView Attribute
    let leftAndRightPadding:CGFloat = 5.0
    var numberOfItemsPerRow:CGFloat = 2.0
    
    //MARK:- Pagination Properties
    var   collectionFooterView : LoadMoreCollectionReusableView?
    var isLoading: Bool = false
    var pageNumber = 1
    var hasMore :Bool?
    var elements = [Items]()
    
   //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpCollection()
    }
    
    //MARK: - Custom Action
    func setUpCollection(){
        collectionViewGrid.dataSource = self
        collectionViewGrid.delegate = self
        
        let collectionViewWidth = collectionViewGrid?.frame.width
        let itemWidth=(collectionViewWidth! - leftAndRightPadding*(numberOfItemsPerRow-1))/numberOfItemsPerRow
        
        let layout = collectionViewGrid?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = leftAndRightPadding
        layout.minimumInteritemSpacing = leftAndRightPadding
        
    }
    
    func getData(){
        let json_dict : [String: Any] = ["site": "stackoverflow", "page": "\(pageNumber)", "filter": "!-*jbN0CeyJHb", "sort": "reputation", "order": "desc"]
        ApiHelper.sharedApiHelper.createRequest(param: json_dict, strURL: "http://api.stackexchange.com/2.2/users/moderators", vc: self, type: "GetData", completion: parseData)
    }
    
    func parseData(data : Data){
        //CustomActivityIndicator.sharedInstance.hideActivityIndicator(uiView: self.view)
        //Implement JSON decoding and parsing
        do {
            //Decode retrived data with JSONDecoder and assing type of Article object
            let loginData = try JSONDecoder().decode(ResponseData.self, from: data)
            //Get back to the main queue
            DispatchQueue.main.async {
                self.checkResult(data: loginData, result: data)
            }
            
        } catch let jsonError {
            print(jsonError)
        }
    }
    
    func checkResult(data : ResponseData , result : Data){
        hasMore = data.has_more ?? true
        if let items = data.items{
            elements.append(contentsOf: items)
            collectionViewGrid.reloadData()
        }
        
        hideLoader()
    }
    
    func getNextPage() {
        showLoader()
        pageNumber = pageNumber + 1
        getData()
    }
    
    func showLoader(){
        isLoading = false
        collectionFooterView?.activityIndicaorView.startAnimating()
    }
    func hideLoader(){
        isLoading = true
        collectionFooterView?.activityIndicaorView.stopAnimating()
    }
}

//MARK: UICollectionViewDelegate
extension ViewController : UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Did select", indexPath.row)
    }
    
    // loads next page when at the bottom
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if hasMore == true{
            let contentLarger = (scrollView.contentSize.height > scrollView.frame.size.height)
            let viewableHeight = contentLarger ? scrollView.frame.size.height : scrollView.contentSize.height
            let atBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - viewableHeight + 50)
            if atBottom && isLoading {
                getNextPage()
            }
        }
    }
}
//MARK: UICollectionViewDataSource
extension ViewController : UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return elements.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
        
        cell.displayContent(row: indexPath.row, name: elements)
        return cell
    }
}
extension ViewController : UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return  CGSize(width: self.view.frame.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        collectionFooterView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath) as? LoadMoreCollectionReusableView
        if kind == UICollectionView.elementKindSectionFooter{
            return collectionFooterView!
        }
        // Normally should never get here
        return UICollectionReusableView()
    }
}

class GridCell : UICollectionViewCell{
    //MARK:- IBOutlet Properties
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageViewPhoto: UIImageView!
    //MARK:- Custom Action
    func displayContent(row : Int , name : [Items]) {
        let item = name[row] // name[row]
        label.text = item.display_name
        let strImageName = item.profile_image ?? ""
        let url = URL(string: strImageName)
        imageViewPhoto.sd_setShowActivityIndicatorView(true)
        imageViewPhoto.sd_setIndicatorStyle(.gray)
        imageViewPhoto.sd_setImage(with: url)
    }
}
