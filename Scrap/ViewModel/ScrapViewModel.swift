//
//  ScrapViewModel.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/29.
//

import Foundation

struct CategoryModel: Decodable{ //카테고리 추가 -> response 데이터로 받을 user id
    struct Result: Decodable {
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

struct MoveDataModel: Decodable {
    struct Result: Decodable {
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

struct NewDataModel: Decodable{ //자료 저장 -> response 데이터로 받을 link id
    struct Result: Decodable {
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

struct NoResultModel: Decodable {
    var code: Int
    var message: String
    init(code: Int, message: String){
        self.code = code
        self.message = message
    }
}

class ScrapViewModel: ObservableObject{ //감시할 data model
    //api 서버 통신을 통해 받아온 데이터를 아래의 객체에 담는다. Published 객체이므로 이 객체 데이터의 변동사항을 다른 view에서 동기적으로 업데이트한다.
    //카테고리 정보를 담은 categoryList 객체
    //카테고리에 따른 자료 정보를 담은 dataList 객체
    //사용자 정보를 담는 user 객체 -> 마이페이지에서 사용할 것
    @Published var dataList = DataResponse.Result(links: [])
    @Published var user = UserResponse.Result(name: "", username: "")
    @Published var categoryList = CategoryResponse(code: 0, message: "", result: CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "", numOfLink: 0, order: 0)]))
    var categoryID = 0
    @Published var isLoading : ServerState = .none //서버 통신 중
    
    //======== 로컬 함수 ========
    //카테고리 추가 기능: categoryList 맨 뒤에 newCategory를 추가
    func appendNewCategoryToCategoryList(new newCategory: CategoryResponse.Category){
        categoryList.result.categories.append(newCategory)
    }
    
    //카테고리 삭제 기능: categoryId를 통해 categoryList의 category 삭제 함수
    func removeCategoryFromCategoryList(categoryID id: Int) {
        categoryList.result.categories = categoryList.result.categories.filter{ $0.categoryId != id }
    }
    
    //자료 삭제 기능: 삭제할 자료id를 받아서 dataList의 data 삭제 함수
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
    
    //data의 카테고리 이동 함수
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
    
    //categoryList의 category 위치 이동
    func moveCategoryRowInList(from oldIndex: Int, to newIndex: Int) {
        guard oldIndex != newIndex else { return }             //제자리 -> return
        guard abs(newIndex - oldIndex) != 1 else { return categoryList.result.categories.swapAt(oldIndex, newIndex) } //바로 아래, 위면 swap
        if newIndex >= categoryList.result.categories.count { //맨 마지막으로 이동
            categoryList.result.categories.append(categoryList.result.categories.remove(at: oldIndex)) //맨 뒤에 추가
            return
        }
        categoryList.result.categories.insert(categoryList.result.categories.remove(at: oldIndex), at: oldIndex > newIndex ? newIndex : newIndex - 1)
    }
    
    //categoryList의 category 이름 수정
    func renameCategory(id categoryID: Int, renamed rname: String){
        for i in 0..<categoryList.result.categories.count {
            if categoryList.result.categories[i].categoryId == categoryID {
                categoryList.result.categories[i].name = rname
                return
            }
        }
    }
    
    private let baseUrl = "https://scrap.hana-umc.shop"
    
    private func fetchDataCompletionHandler(fromURL url: URL, completionHandler: @escaping (_ data: Data?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil, let response = response as? HTTPURLResponse else {
                completionHandler(nil, NetworkErrors.requestFailed)
                return
            }
            guard (200..<300) ~= response.statusCode else {
                completionHandler(nil, NetworkErrors.responseUnsuccessFul)
                return
            }
            completionHandler(data, nil)
        }.resume()
    }
    
    private func networkingServerCompletionHandler(withRequest request: URLRequest, completionHandler: @escaping (_ data: Data?, _ error: Error?) -> ()) {
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil, let response = response as? HTTPURLResponse else {
                completionHandler(nil, NetworkErrors.requestFailed)
                return
            }
            guard (200..<300) ~= response.statusCode else {
                print(response.statusCode)
                completionHandler(nil, NetworkErrors.responseUnsuccessFul)
                return
            }
            completionHandler(data, nil)
        }.resume()
    }
    
    func getCategoryData(userID: Int) async throws -> CategoryResponse {
        guard let url = URL(string: "\(baseUrl)/category/all?id=\(userID)") else {
            throw NetworkErrors.invalidURL
        }
        
        guard let (data, response) = try? await URLSession.shared.data(from: url) else {
            throw NetworkErrors.requestFailed
        }
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.responseUnsuccessFul
        }
        
        guard let result = try? JSONDecoder().decode(CategoryResponse.self, from: data) else {
            throw NetworkErrors.jsonParsingFailure
        }
        
        return result
//        guard let (data, response) = try await URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
//            if let data = data {
//                guard let result = try? JSONDecoder().decode(CategoryResponse.self, from: data) else { //jsonParsingError
//                    return
//                }
//                print(result)
//                DispatchQueue.main.async { [weak self] in
//                    self?.categoryList = result
//                }
//            }else{
//                print(String(describing: error?.localizedDescription))
//            }
//        })
    }
    
    //=========GET=========
    //카테고리 전체 조회
    //query: user id
    func inquiryCategoryData(userID: Int) async {
        guard let data = try? await getCategoryData(userID: userID) else {
            print("async/await inquiring data error")
            return
        }
        DispatchQueue.main.async {
            self.categoryList = data
        }
//        fetchDataCompletionHandler(fromURL: url) { (data, error) in
//            if let data = data {
//                guard let result = try? JSONDecoder().decode(CategoryResponse.self, from: data) else { //jsonParsingError
//                    return
//                }
//                print(result)
//                DispatchQueue.main.async { [weak self] in
//                    self?.categoryList = result
//                }
//            }else{
//                print(String(describing: error?.localizedDescription))
//            }
//        }
    }
    
    //자료 조회
    //query: user id, category id
    func inquiryData(userID: Int, catID: Int) {
        print("⭐️⭐️⭐️선택한 카테고리 id: \(catID)")
        guard let url = URL(string: "\(baseUrl)/auth/data?id=\(userID)&category=\(catID)") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data {
                    guard let httpResponse = response as? HTTPURLResponse else {return}
                    
                    if httpResponse.statusCode != 200 {
                        do{
                            let decoder = JSONDecoder()
                            let failMessage = try decoder.decode(NoResultModel.self, from: data)
                            print(failMessage)
                            self.isLoading = .failure
                        } catch let error {
                            print("fail error")
                            print(String(describing: error))
                        }
                    }else{
                        do {
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(DataResponse.self, from: data)
                            self.dataList = result.result
                            self.isLoading = .success
//                            print(result)
                        } catch let error {
                            print("error")
                            print(String(describing: error))
                        }
                    }
                }else if let error = error {
                    print("error")
                    print(String(describing: error))
                }
            }
        }.resume()
    }
    
    //자료 전체 조회
    //query: user id
    func inquiryAllData(userID: Int) {
        print("⭐️⭐️⭐️자료 전체 조회")
        guard let url = URL(string: "\(baseUrl)/auth/data/all?id=\(userID)") else {
            print("invalid url")
            return
        }
        fetchDataCompletionHandler(fromURL: url) { (data, error) in
            if let data = data {
                guard let result = try? JSONDecoder().decode(DataResponse.self, from: data) else { //jsonParsingError
                    return
                }
                print(result)

                DispatchQueue.main.async { [weak self] in
                    self?.dataList = result.result
                }
            }else{
                print(String(describing: error?.localizedDescription))
            }
        }
    }
    
    //마이 페이지
    //query: user id
    func inquiryUserData(userID: Int) {
        guard let url = URL(string: "\(baseUrl)/auth/user/mypage?id=\(userID)") else {
            print("invalid url")
            return
        }
        fetchDataCompletionHandler(fromURL: url) { (data, error) in
            if let data = data {
                guard let result = try? JSONDecoder().decode(UserResponse.self, from: data) else { //jsonParsingError
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    self?.user = result.result
                }
            }else{
                print(String(describing: error?.localizedDescription))
            }
        }
    }
    
    //=========POST========
    //카테고리 추가
    //query: userId/newCatName
    //body: newCatName
    func addNewCategory(newCat: String, userID: Int) {
        guard let url = URL(string: "\(baseUrl)/auth/category?id=\(userID)") else {
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
        
        networkingServerCompletionHandler(withRequest: request) { data, error in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(CategoryModel.self, from: data)
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }
    }
    
    //자료 저장
    //query: category id, user id
    //body: url
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
        
        networkingServerCompletionHandler(withRequest: request) { data, error in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(NewDataModel.self, from: data)
                    print(result)
                    print("post saving data : SUCCESS")
                    print(catID)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }
    }
    
    //=========DELETE========
    //카테고리 삭제
    //query: category id
    func deleteCategory(categoryID: Int) {
        print(categoryID)
        guard let url = URL(string: "\(baseUrl)/auth/category?category=\(categoryID)") else {
            print("invalid url")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        networkingServerCompletionHandler(withRequest: request) { data, error in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(NoResultModel.self, from: data)
                    print(result)
                    print(categoryID)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }
    }
    
    //자료 삭제
    //query: user idx, link id
    func deleteData(userID: Int, linkID: Int) {
        guard let url = URL(string: "\(baseUrl)/auth/data/\(userID)?link_id=\(linkID)") else {
            print("invalid url")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        networkingServerCompletionHandler(withRequest: request) { data, error in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(NoResultModel.self, from: data)
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }
    }
    
    //==========PUT=========
    //카테고리 수정
    //query: category id
    //body: category name
    func modifyCategory(categoryID: Int, categoryName: String){
        guard let url = URL(string: "\(baseUrl)/auth/category?category=\(categoryID)") else {
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
        
        networkingServerCompletionHandler(withRequest: request) { data, error in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(CategoryModel.self, from: data)
                    print(result)
                    print(categoryID)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }
    }
    
    //카테고리 순서 수정
    //query: user id
    //body: from, to
    func movingCategory(userID: Int, startIdx: Int, endIdx: Int){
        guard let url = URL(string: "\(baseUrl)/auth/category/all?id=\(userID)") else {
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
        
        networkingServerCompletionHandler(withRequest: request) { data, error in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(NoResultModel.self, from: data)
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }
        
    }
    
    //======PATCH======
    //자료 수정
    //query: user idex, link id
    //body: category id
    func modifyDatasCategory(userID: Int, linkID: Int, categoryId: Int) {
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
        networkingServerCompletionHandler(withRequest: request) { data, error in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(MoveDataModel.self, from: data)
                    print(result)
                    print("자료의 카테고리 이동 완료")
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }
    }
    
}
