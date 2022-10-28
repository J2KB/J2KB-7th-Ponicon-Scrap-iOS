//
//  ShareUIView.swift
//  Share
//
//  Created by 김영선 on 2022/10/09.
//

import SwiftUI
//import Scrap

struct CategoryResponseInShare: Decodable{
    struct Result: Decodable {
        var categories: [CategoryInShare]
        
        init(categories: [CategoryInShare]){
            self.categories = categories
        }
    }
    struct CategoryInShare: Decodable, Identifiable{
        let id = UUID()
        var categoryId: Int
        var name: String
        var numOfLink: Int
        var order: Int
        
        init(categoryId: Int, name: String, numOfLink: Int, order: Int){
            self.categoryId = categoryId
            self.name = name
            self.numOfLink = numOfLink
            self.order = order
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

//카테고리 조회하기 -> userdefaults에 저장된 idx로 조회해야됨
class CategoryViewModel: ObservableObject{ //감시할 data model
    @Published var categoryList = CategoryResponseInShare(code: 0, message: "",result: CategoryResponseInShare.Result(categories: [CategoryResponseInShare.CategoryInShare(categoryId: 0, name: "", numOfLink: 0, order: 0)]))
    
    func getCategoryDataInShare(userIdx: Int){
        print("user index : \(userIdx)")
        guard let url = URL(string: "https://scrap.hana-umc.shop/category/all?id=\(userIdx)") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                if let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                }
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(CategoryResponseInShare.self, from: data)
                    DispatchQueue.main.async {
                        self.categoryList = result
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

class CategoryIDDelegate: ObservableObject {
    @Published var categoryID: Int = 0
}

struct ShareUIView: View {
    @ObservedObject var delegate : CategoryIDDelegate
    @StateObject var vm = CategoryViewModel()
    let light_gray = Color(red: 217/255, green: 217/255, blue: 217/255)
    @State private var selected : Int = 0 //이 값을 ShareViewController로 넘겨줘야 한다.
    private let userIdx = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") //user id 가져오기

    var body: some View {
        if userIdx == 0 {
            Text("Scrap에 로그인해주세요.")
        } else { //사용자 로그인되어있는 상태라면
            List{
                ForEach($vm.categoryList.result.categories){ $category in
                    if category.order != 0 { //모든 자료는 제외
                        Text(category.name)
                        .listRowBackground(self.selected == category.categoryId ? light_gray : Color(.white))
                        .onTapGesture { //클릭하면 현재 categoryID
                            self.selected = category.categoryId
                            self.delegate.categoryID = category.categoryId
                        }
                    }
                }
            }
            .listStyle(InsetListStyle())
            .onAppear{
                print("user idx: \(self.userIdx!)")
                vm.getCategoryDataInShare(userIdx: self.userIdx!)
            }
        }
    }
}

struct ShareUIView_Previews: PreviewProvider {
    static var previews: some View {
        ShareUIView(delegate: CategoryIDDelegate())
    }
}
