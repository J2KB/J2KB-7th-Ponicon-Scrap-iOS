//
//  ScrapViewModel.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/29.
//

import Foundation

struct CategoryModel: Codable { //카테고리 추가 -> response 데이터로 받을 user id
    struct Result: Codable {
        var categoryId: Int
        
        init(categoryId: Int){
            self.categoryId = categoryId
        }
    }
    var code: Int
    var message: String
    var result: Result?
    init(code: Int, message: String, result: Result){
        self.code = code
        self.message = message
        self.result = result
    }
}

struct MoveDataModel: Codable {
    struct Result: Codable {
        var linkId: Int
        var categoryId: Int
        var url: String
        var title: String
        var imgUrl: String
        var domain: String
        
        init(linkId: Int, categoryId: Int, url: String, title: String, imgUrl: String, domain: String){
            self.linkId = linkId
            self.categoryId = categoryId
            self.url = url
            self.title = title
            self.imgUrl = imgUrl
            self.domain = domain
        }
    }
    var code: Int
    var message: String
    var result: Result?
    init(code: Int, message: String, result: Result){
        self.code = code
        self.message = message
        self.result = result
    }
}

struct NewDataModel: Codable { //자료 저장 -> response 데이터로 받을 link id
    struct Result: Codable {
        var linkId: Int
        
        init(linkId: Int){
            self.linkId = linkId
        }
    }
    var code: Int
    var message: String
    var result: Result
    init(code: Int, message: String, result: Result){
        self.code = code
        self.message = message
        self.result = result
    }
}

struct NoResultModel: Codable {
    var code: Int
    var message: String
    init(code: Int, message: String){
        self.code = code
        self.message = message
    }
}

class ScrapViewModel: ObservableObject{
    //api 서버 통신을 통해 받아온 데이터를 아래의 객체에 담는다. Published 객체이므로 이 객체 데이터의 변동사항을 다른 view에서 동기적으로 업데이트한다.
    //카테고리 정보를 담은 categoryList 객체
    //카테고리에 따른 자료 정보를 담은 dataList 객체
    //사용자 정보를 담는 user 객체 -> 마이페이지에서 사용할 것
    @Published var dataList = DataResponse.Result(links: [])
    @Published var user = UserResponse.Result(name: "", username: "")
    @Published var categoryList = CategoryResponse(code: 0, message: "", result: CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "", numOfLink: 0, order: 0)]))
    @Published var isLoading = false //서버 통신 상태 변수
    let service = APIService()
    var categoryID = 0
    
    
    // MARK: initial fetch data
    init(){
        let userID = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") ?? 0
        getCategoryListData(userID: userID)
        getAllData(userID: userID)
        getMyPageData(userID: userID)
    }
    
    // MARK: 카테고리 리스트 조회
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
    
    // MARK: 전체 자료 조회
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
    
    // -------------------------------------------------------------------------------
    // ↓ local operation function
    // -------------------------------------------------------------------------------

    // MARK: 카테고리 추가 기능: categoryList 맨 뒤에 newCategory를 추가
    func appendNewCategoryToCategoryList(new newCategory: CategoryResponse.Category){
        categoryList.result.categories.append(newCategory)
    }
    
    // MARK: 카테고리 삭제 기능: categoryId를 통해 categoryList의 category 삭제 함수
    func removeCategoryFromCategoryList(categoryID id: Int) {
        categoryList.result.categories = categoryList.result.categories.filter{ $0.categoryId != id }
    }
    
    // MARK: 자료 삭제 기능: 삭제할 자료id를 받아서 dataList의 data 삭제 함수
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
    
    // MARK: data의 카테고리 이동 함수
    func moveDataToOtherCategory(_ data: DataResponse.Datas, from fromCategoryID: Int, to toCategoryID: Int) { //이동할 자료id, 선택한 카테고리id, 이동될 카테고리id
        //해당 자료를 to 카테고리에 넣기 -> 해당 카테고리를 클릭하면 어차피 데이터 통신이 진행되므로 할 필요 x, 해당 카테고리의 numOfLink += 1 -> 이것만 진행
        for i in 0..<categoryList.result.categories.count {
            if categoryList.result.categories[i].categoryId == toCategoryID {
                categoryList.result.categories[i].numOfLink += 1
                break
            }
        }
        removeDataFromDataList(dataID: data.linkId!, categoryID: fromCategoryID) //from 카테고리에서 해당 자료 제거
    }
    
    // MARK: categoryList의 category 위치 이동
    func moveCategoryRowInList(from oldIndex: Int, to newIndex: Int) {
        guard oldIndex != newIndex else { return }             //제자리 -> return
        guard abs(newIndex - oldIndex) != 1 else { return categoryList.result.categories.swapAt(oldIndex, newIndex) } //바로 아래, 위면 swap
        if newIndex >= categoryList.result.categories.count { //맨 마지막으로 이동
            categoryList.result.categories.append(categoryList.result.categories.remove(at: oldIndex)) //맨 뒤에 추가
            return
        }
        categoryList.result.categories.insert(categoryList.result.categories.remove(at: oldIndex), at: oldIndex > newIndex ? newIndex : newIndex - 1)
    }
    
    // MARK: categoryList의 category 이름 수정
    func renameCategory(id categoryID: Int, renamed rname: String){
        for i in 0..<categoryList.result.categories.count {
            if categoryList.result.categories[i].categoryId == categoryID {
                categoryList.result.categories[i].name = rname
                return
            }
        }
    }
    
    
    //자료 저장
    //query: category id, user id
    //body: url
//    func addNewData(baseurl: String, title: String, imgUrl: String, catID: Int, userIdx: Int){
//        print("⭐️⭐️⭐️⭐️⭐️⭐️자료 저장!!!!!⭐️⭐️⭐️⭐️⭐️⭐️")
//        print(userIdx)
//        print(catID)
//        guard let url = URL(string: "https://scrap.hana-umc.shop/data?id=\(userIdx)&category=\(catID)") else { //auth 추가해도 될 듯
//            print("invalid url")
//            return
//        }
//
//        let link = baseurl
//        let title = title
//        let imgUrl = imgUrl
//        let body: [String: Any] = ["link" : link, "title" : title, "imgUrl" : imgUrl]
//        let finalData = try! JSONSerialization.data(withJSONObject: body)
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = finalData
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        networkingServerCompletionHandler(withRequest: request) { data, error in
//            do{
//                if let data = data {
//                    let decoder = JSONDecoder()
//                    let result = try decoder.decode(NewDataModel.self, from: data)
//                    print(result)
//                    print("post saving data : SUCCESS")
//                    print(catID)
//                } else {
//                    print("no data")
//                }
//            }catch (let error){
//                print(String(describing: error))
//            }
//        }
//    }
}
