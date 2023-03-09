//
//  ScrapViewModel.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/29.
//

import Foundation

class ScrapViewModel: ObservableObject{
    @Published var dataList = DataResponse.Result(links: [])
    @Published var favoriteList = DataResponse.Result(links: [])
    @Published var user = UserResponse.Result(name: "", username: "")
    @Published var categoryList = CategoryResponse(code: 0, message: "", result: CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "", numOfLink: 0, order: 0)]))
    @Published var isLoading = false //서버 통신 상태 변수
    let service = APIService()
    var categoryID = 0
    
    // MARK: - 카테고리 리스트 조회
    func getCategoryListData(userID: Int){
        let url = URL(string: "https://scrap.hana-umc.shop/category/all?id=\(userID)")
        service.fetchData(CategoryResponse.self, baseUrl: url) { [unowned self] result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    self.categoryList = result
                    print(self.categoryList)
                }
            }
        }
    }
    
    // MARK: - 즐겨찾기 자료 리스트 추출
    private func getFavorites() {
        favoriteList.links = dataList.links.filter{ $0.bookmark == true } //즐겨찾기인애들만 가져오기
        print("즐겨찾기 리스트🥕🥕🥕🥕🥕🥕🥕🥕🥕")
        print(favoriteList.links)
    }
    
    // MARK: - 전체 자료 조회
    func getAllData(userID: Int){
        isLoading = true
        let url = URL(string: "https://scrap.hana-umc.shop/auth/data/all?id=\(userID)")
        service.fetchData(DataResponse.self, baseUrl: url) { [unowned self] result in
            DispatchQueue.main.async {
                self.isLoading = false //서버 통신 완료
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    self.dataList = result.result
                    print(self.dataList)
                    self.getFavorites()
                }
            }
        }
    }
    
    // MARK: 카테고리별 자료 조회
    func getDataByCategory(userID: Int, categoryID: Int){
        isLoading = true
        let url = URL(string: "https://scrap.hana-umc.shop/auth/data?id=\(userID)&category=\(categoryID)")
        service.fetchData(DataResponse.self, baseUrl: url) { [unowned self] result in
            DispatchQueue.main.async {
                self.isLoading = false //서버 통신 완료
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    self.dataList = result.result
                    print(self.dataList)
                }
            }
        }
    }
    
    // MARK: 마이페이지 데이터 조회
    func getMyPageData(userID: Int){
        let url = URL(string: "https://scrap.hana-umc.shop/auth/user/mypage?id=\(userID)")
        service.fetchData(UserResponse.self, baseUrl: url) { [unowned self] result in
            DispatchQueue.main.async {
                self.isLoading = false //서버 통신 완료
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    self.user = result.result
                    print(self.user)
                }
            }
        }
    }
    
    // MARK: 새로운 카테고리 추가
    func addNewCategory(newCat: String, userID: Int) {
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/category?id=\(userID)") else {
            print("invalid url")
            return
        }
        let name = newCat
        let body: [String: Any] = ["name": name]
        let finalData = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        service.requestTask(CategoryModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    break
                }
            }
        }
    }
    
    // MARK: 카테고리 삭제
    func deleteCategory(categoryID: Int) {
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/category?category=\(categoryID)") else {
            print("invalid url")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        service.requestTask(NoResultModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    break
                }
            }
        }
    }
    
    // MARK: 자료 삭제
    func deleteData(userID: Int, linkID: Int) {
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/data/\(userID)?link_id=\(linkID)") else {
            print("invalid url")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        service.requestTask(NoResultModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    break
                }
            }
        }
    }
    
    // MARK: 카테고리 이름 수정
    func modifyCategoryName(categoryID: Int, categoryName: String){
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/category?category=\(categoryID)") else {
            print("invalid url")
            return
        }
        let name = categoryName
        let body: [String: Any] = ["name": name]
        let finalData = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        service.requestTask(CategoryModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    break
                }
            }
        }
    }
    
    // MARK: 카테고리 위치 이동
    func movingCategory(userID: Int, startIdx: Int, endIdx: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/category/all?id=\(userID)") else {
            print("invalid url")
            return
        }
        
        let startIdx = startIdx
        let endIdx = endIdx
        let body: [String: Any] = ["startIdx": startIdx, "endIdx": endIdx]
        let finalData = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        service.requestTask(NoResultModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    break
                }
            }
        }
    }
    
    // MARK: 자료의 카테고리 이동
    func modifyCategoryOfData(userID: Int, linkID: Int, categoryId: Int) {
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/data/\(userID)?link_id=\(linkID)") else {
            print("invalid url")
            return
        }
        let categoryIdx = categoryId
        let body: [String: Any] = ["categoryId": categoryIdx]
        let finalData = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        service.requestTask(MoveDataModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    break
                }
            }
        }
    }
    
    // MARK: - 자료 이름 수정
    func modifyDataName(dataID: Int, dataName: String, userIdx: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/data/\(userIdx)?link_id=\(dataID)") else {
            print("invalid url")
            return
        }
        let title = dataName
        let body: [String: Any] = ["title": title]
        let finalData = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        service.requestTask(NewDataModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    break
                }
            }
        }
    }
    
    // MARK: 즐겨찾기 추가 & 삭제
    func modifyFavoritesData(userID: Int, linkID: Int) {
        guard let url = URL(string: "https://scrap.hana-umc.shop/auth/data/bookmark/\(userID)?link_id=\(linkID)") else {
            print("invalid url")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        service.requestTask(FavoriteDataModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    break
                }
            }
        }
    }
    
    // MARK: - 자료 저장
    func addNewData(baseurl: String, title: String, imgUrl: String, catID: Int, userIdx: Int){
        print("⭐️⭐️⭐️⭐️⭐️⭐️자료 저장!!!!!⭐️⭐️⭐️⭐️⭐️⭐️")
        print(userIdx)
        print(catID)
        guard let url = URL(string: "https://scrap.hana-umc.shop/data?id=\(userIdx)&category=\(catID)") else { //auth 추가해도 될 듯
            print("invalid url")
            return
        }

        let link = baseurl
        let title = title
        let imgUrl = imgUrl
        let body: [String: Any] = ["link" : link, "title" : title, "imgUrl" : imgUrl]
        let finalData = try! JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        service.requestTask(NewDataModel.self, withRequest: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    print("post saving data : SUCCESS")
                    break
                }
            }
        }
    }
    
    // -------------------------------------------------------------------------------
    // ↓ local operation function
    // -------------------------------------------------------------------------------

    // MARK: - 새 카테고리 추가
    // - categoryList 맨 뒤에 newCategory를 추가
    func appendNewCategoryToCategoryList(new newCategory: CategoryResponse.Category){
        categoryList.result.categories.append(newCategory)
    }
    
    // MARK: - 카테고리 삭제
    // - categoryId를 통해 categoryList의 category 삭제 함수
    func removeCategoryFromCategoryList(categoryID id: Int) {
        categoryList.result.categories = categoryList.result.categories.filter{ $0.categoryId != id }
    }
    
    // MARK: - 자료 삭제
    // - 삭제할 자료id를 받아서 dataList의 data 삭제 함수
    func removeDataFromDataList(dataID dataId: Int, categoryID categoryId: Int) {
        dataList.links = dataList.links.filter { $0.linkId != dataId }
        //해당 카테고리의 numOfLink -= 1
        for i in 0..<categoryList.result.categories.count {
            if categoryList.result.categories[i].categoryId == categoryId {
                categoryList.result.categories[i].numOfLink -= 1
                return
            }
        }
    }
    
    // MARK: - 자료의 카테고리 이동
    // - data의 카테고리 이동 함수
    func moveDataToOtherCategory(_ data: DataResponse.Datas, from fromCategoryID: Int, to toCategoryID: Int) {
        //해당 자료를 to 카테고리에 넣기 -> 해당 카테고리를 클릭하면 어차피 데이터 통신이 진행되므로 할 필요 x, 해당 카테고리의 numOfLink += 1 -> 이것만 진행
        for i in 0..<categoryList.result.categories.count {
            if categoryList.result.categories[i].categoryId == toCategoryID {
                categoryList.result.categories[i].numOfLink += 1
                break
            }
        }
        removeDataFromDataList(dataID: data.linkId!, categoryID: fromCategoryID) //from 카테고리에서 해당 자료 제거
    }
    
    // MARK: - 카테고리 위치 이동
    // - categoryList의 category 위치 이동
    func moveCategoryRowInList(from oldIndex: Int, to newIndex: Int) {
        guard oldIndex != newIndex else { return }             //제자리 -> 연산 X, return
        guard abs(newIndex - oldIndex) != 1 else { return categoryList.result.categories.swapAt(oldIndex, newIndex) }
        if newIndex >= categoryList.result.categories.count { //맨 마지막으로 이동
            categoryList.result.categories.append(categoryList.result.categories.remove(at: oldIndex)) //맨 뒤에 추가
            return
        }
        categoryList.result.categories.insert(categoryList.result.categories.remove(at: oldIndex), at: oldIndex > newIndex ? newIndex : newIndex - 1)
    }
    
    // MARK: - 카테고리 이름 수정
    //- categoryList의 category 이름 수정
    func renameCategory(categoryID: Int, renamed rname: String){
        for i in 0..<categoryList.result.categories.count {
            if categoryList.result.categories[i].categoryId == categoryID {
                categoryList.result.categories[i].name = rname
                return
            }
        }
    }
    
    // MARK: - 자료 이름 수정
    //- dataList의 data 이름 수정
    //- 전체 자료의 data 이름이랑 현재 보이고 있는 카테고리의 data 이름을 변경해야 하는데,
    //어차피 지금 보이는 건,
    func renameData(dataID dataId: Int, renamed rname: String){
        for i in 0..<dataList.links.count {
            if dataList.links[i].linkId == dataId {
                dataList.links[i].title = rname
                return
            }
        }
    }
    
    // MARK: - 즐겨찾기 추가 / 해제
    func bookmark(dataID: Int, isBookmark: Bool) {
        //favoriteList에 추가 / 해제
        if isBookmark {
            for i in 0..<dataList.links.count {
                if dataList.links[i].linkId == dataID {
                    dataList.links[i].bookmark = true
                    favoriteList.links.append(dataList.links[i])
                    break
                }
            }
        }
        else { // 즐겨찾기 해제
            for i in 0..<dataList.links.count {
                if dataList.links[i].linkId == dataID {
                    dataList.links[i].bookmark = false
                    break
                }
            }
            for i in 0..<favoriteList.links.count {
                if favoriteList.links[i].linkId == dataID {
                    favoriteList.links.remove(at: i)
                    return
                }
            }
        }
    }
}
