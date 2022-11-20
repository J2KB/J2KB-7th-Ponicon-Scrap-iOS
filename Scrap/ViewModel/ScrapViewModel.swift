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
    @Published var dataList = DataResponse(code: 0, message: "", result: DataResponse.Result(links: [DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "")]))
    @Published var user = UserResponse(code: 0, message: "", result: UserResponse.Result(name: "", username: ""))
    @Published var categoryList = CategoryResponse(code: 0, message: "", result: CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "", numOfLink: 0, order: 0)]))
    var categoryID = 0
    @Published var isLoading : ServerState = .none //서버 통신 중
//    @Published var state : [ServerState] = [.none, .none, .none, .none] //아무것도 안한 상태
    //getcategory, getalldata, getdata, getMydata
    
    //======== 로컬 함수 ========
    //categoryList에 category 추가 함수 (카테고리 추가 기능)
    func appendCategory(newCategory: CategoryResponse.Category){
        categoryList.result.categories.append(newCategory)
    }
    
    //categoryList에 category 삭제 함수
    func removeCategory(index: Int){
        //order도 변경해줘야됨
        for i in 0..<categoryList.result.categories.count{
            if categoryList.result.categories[i].order == index {
                categoryList.result.categories.remove(at: i)
                return
            }
        }
    }
    
    //dataList에 data 삭제 함수
    func removeData(linkID: Int){ //더 효율적인 방법 찾아보기
        for i in 0..<dataList.result.links.count {
            if dataList.result.links[i].linkId == linkID {
                dataList.result.links.remove(at: i)
                return
            }
        }
    }

    //categoryList의 category 위치 이동
    func moveCategory(from oldIndex: Int, to newIndex: Int) {
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return categoryList.result.categories.swapAt(oldIndex, newIndex) }
        if newIndex >= categoryList.result.categories.count {
            categoryList.result.categories.append(categoryList.result.categories.remove(at: oldIndex)) //맨 뒤에 추가
            return
        }
        categoryList.result.categories.insert(categoryList.result.categories.remove(at: oldIndex), at: newIndex)
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

//    @MainActor
//    func whenMainHomeAppear(selected: Int, userIdx: Int) async {
//        isLoading = true
//        await getCategoryData(userID: userIdx) //카테고리 조회 통신 📡
//        await getMyPageData(userID: userIdx) //마이페이지 데이터 조회 통신 📡
//        if selected == 0 { await getAllData(userID: userIdx) } //자료 조회 통신 📡 case01
//        else { await getData(userID: userIdx, catID: selected, seq: "seq") } //자료 조회 통신 📡 case02
//        isLoading = false
//    }
//
//    @MainActor
//    func whenGetData(selected: Int, userIdx: Int) async{
//        isLoading = true
//        await getData(userID: userIdx, catID: selected, seq: "seq")
//        isLoading = false
//    }
    
    private let baseUrl = "https://scrap.hana-umc.shop"
    
    //=========GET=========
    //카테고리 전체 조회
    //query: user id
    func getCategoryData(userID: Int) {
        print("카테고리 조회")
        guard let url = URL(string: "\(baseUrl)/category/all?id=\(userID)") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            DispatchQueue.main.async {
                if let data = data {
                    guard let httpResponse = response as? HTTPURLResponse else {return}
                    print(httpResponse.statusCode)
                    if httpResponse.statusCode != 200 { //카테고리 조회 실패
                        do{
                            let decoder = JSONDecoder()
                            let failMessage = try decoder.decode(NoResultModel.self, from: data)
                            print(failMessage)
                        } catch let error {
                            print("fail error")
                            print(String(describing: error))
                        }
                    }else {
                        do{
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(CategoryResponse.self, from: data)
                            self.categoryList = result
                            print(result)
                        }catch (let error){
                            print("success error")
                            print(String(describing: error))
                        }
                    }
                }
            }
        }.resume()
    }
    
    //=========POST========
    //카테고리 추가
    //query: userId/newCatName
    //body: newCatName
    func addNewCategory(newCat: String, userID: Int){
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

        URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        }.resume()
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

        URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        }.resume()
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

        URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        }.resume()
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

        URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        }.resume()
    }
    
    //=======GET=======
    //자료 조회
    //query: user id, category id, seq
    func getData(userID: Int, catID: Int, seq: String) {
        print("자료 조회")
        guard let url = URL(string: "\(baseUrl)/auth/data?id=\(userID)&category=\(catID)&seq=\(seq)") else {
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
                            self.dataList = result
                            self.isLoading = .success
                            print(result)
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
    
    //========GET========
    //자료 전체 조회
    //query: user id
    func getAllData(userID: Int) {
        print("자료 전체 조회")
        guard let url = URL(string: "\(baseUrl)/auth/data/all?id=\(userID)") else {
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
                        do{
                            let decoder = JSONDecoder()
                            let result = try decoder.decode(DataResponse.self, from: data)
                            self.dataList = result
                            print(result)
                            self.isLoading = .success
                        }catch let error{
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
    
    //======DEL========
    //자료 삭제
    //query: user idx, link id
    func deleteData(userID: Int, linkID: Int) {
        guard let url = URL(string: "\(baseUrl)/auth/data/\(userID)?link_id=\(linkID)") else {
            print("invalid url")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        }.resume()
    }
    
    //======PATCH======
    //자료 수정
    //query: user idex, link id
    //body: category id
    func modifyDatasCategory(userID: Int, linkID: Int, categoryId: Int) {
        guard let url = URL(string: "\(baseUrl)/auth/data/\(userID)?link_id=\(linkID)") else {
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

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(DataResponse.self, from: data)
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }.resume()
    }
    
    //=======POST=======
    //자료 저장
    //query: category id, user id
    //body: url
    func addNewData(baseurl: String, catID: Int, userIdx: Int){
        guard let url = URL(string: "\(baseurl)/auth/data?id=\(userIdx)&category=\(catID)") else {
            print("invalid url")
            return
        }
        
        let baseURL = baseurl
        let body: [String: Any] = ["baseURL" : baseURL]
        let finalData = try! JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                print("error")
                print(String(describing: error))
            }
        }.resume()
    }
    
    //======GET=======
    //마이 페이지
    //query: user id
    func getMyPageData(userID: Int) {
        print("마이페이지 데이터 조회")
        guard let url = URL(string: "\(baseUrl)/auth/user/mypage?id=\(userID)") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(UserResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.user = result
                    }
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print("error")
                print(String(describing: error))
            }
        }.resume()
    }
    
}
