import UIKit
import DribbbleSwift
import SDWebImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var viewFrame: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userLocation: UILabel!
    @IBOutlet weak var userBio: UILabel!
    @IBOutlet weak var userPRO: UIButton!
    @IBOutlet weak var viewTitle: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selecter: UISegmentedControl!
    @IBAction func selecterAction(_ sender: UISegmentedControl) {
        segmentalFlag = selecter.selectedSegmentIndex
        tableView.reloadData()
    }

    var arrayOfFollowersData: [DribbbleSwift.FollowersDS] = []
    var arrayOfLikesData : [DribbbleSwift.UserLikesDS] = []
    var userNickname = String()
    var segmentalFlag = 0
    var loadMoreFollowersStatus = false
    var followersPageNum = 1
    var loadMoreLikesStatus = false
    var likesPageNum = 1
    
    

    fileprivate struct Const {
        static let identifierFollowers = "followersId"
        static let xibNameFollowers = "FollowersCell"
        static let identifierLikes = "likesId"
        static let xibNameLikes = "LikesCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        tableView.delegate = self
        tableView.dataSource = self

        let nib = UINib(nibName: Const.xibNameFollowers, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Const.identifierFollowers)

        let nib2 = UINib(nibName: Const.xibNameLikes, bundle: nil)
        tableView.register(nib2, forCellReuseIdentifier: Const.identifierLikes)

        ConfigDS.setAccessToken(Config.ACCESS_TOKEN)

        userNickname = buffer.shared.userNickname
        viewAppearance()
        updateDataBio()
        fetchFollowers(userNick: userNickname, page: followersPageNum)
        fetchLikes(userNick: userNickname, page: likesPageNum)
    }




    
    
  

     func scrollViewDidScroll(_ scrollView: UIScrollView) {

        let currentOffset = tableView.contentOffset.y
        let maximumOffset = tableView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        if deltaOffset <= scrollView.frame.size.height * 2 {
            
            segmentalFlag == 0 ? fetchFollowers(userNick: userNickname, page: followersPageNum) : fetchLikes(userNick: userNickname, page: likesPageNum)
            
        }

    }

    func updateDataBio() {

        UserDS.getUser(userNickname) {[weak self] _, user in
            guard let `self` = self else { return }
            
            self.userName.text = user?.name
            self.userLocation.text = user?.location
            self.userBio.text = (user?.bio).map(removeHtmlTags)
            self.userAvatar.sd_setImage(with: URL(string: (user?.avatar_url!)!))
            self.userPRO.isHidden = (user?.pro)! ? false : true
            
           
            let bioSize = CGSize(width: self.userBio.bounds.width, height: CGFloat.greatestFiniteMagnitude)
            if let bio = user?.bio {
                
                let resaultSize = (bio as NSString).boundingRect(with: bioSize, options: [.usesLineFragmentOrigin], attributes: nil, context: nil)
                let height = resaultSize.height * 2  + 300
                let width = self.viewFrame.frame.width
                self.viewFrame.frame = CGRect(x: 0, y: 0, width: width, height: height)

              
            }
            
        }

    }

   

  private  func viewAppearance() {

        if (userAvatar) != nil {
            let minSide = min(userAvatar.bounds.width, userAvatar.bounds.height)
            userAvatar.layer.cornerRadius = minSide/2
            userAvatar.clipsToBounds = true
        }

        viewTitle.layer.cornerRadius = 10
        userPRO.layer.cornerRadius = 5

    }
    
    func fetchFollowers(userNick: String, page: Int) {
        
        if !loadMoreFollowersStatus {
            loadMoreFollowersStatus = true
            followersPageNum += 1
            
            UserDS.getFollowers(userNick, perPage: 20, page: page) {
                _, followers in
                self.arrayOfFollowersData += followers!
                self.tableView.reloadData()
                self.loadMoreFollowersStatus = false
            }
            
        }
    }
    
    func fetchLikes(userNick: String, page: Int) {
        
        if !loadMoreLikesStatus {
            loadMoreLikesStatus = true
            likesPageNum += 1
            
            UserDS.getLikes(userNick, perPage: 20, page: page) {
                
                _, likes in
                self.arrayOfLikesData += likes!
                self.tableView.reloadData()
                self.loadMoreLikesStatus = false
            }
            
        }
    }

}

//MARK:  Table View Delegate

extension ProfileViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
  
}


//MARK: Table View DataSoure


extension ProfileViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return segmentalFlag == 0 ?  arrayOfFollowersData.count : arrayOfLikesData.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if segmentalFlag == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Const.identifierFollowers, for: indexPath) as! FollowersCell
            let dataItem = arrayOfFollowersData[indexPath.row]
            cell.setData(dataItem)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Const.identifierLikes, for: indexPath) as! LikesCell
            let dataItem = arrayOfLikesData[indexPath.row]
            cell.setData(dataItem)
            return cell
        }
    }
}
