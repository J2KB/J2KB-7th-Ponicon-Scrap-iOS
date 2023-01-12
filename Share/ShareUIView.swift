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
    private var service = APIService()
    @Published var categoryList = CategoryResponseInShare(code: 0, message: "",result: CategoryResponseInShare.Result(categories: [CategoryResponseInShare.CategoryInShare(categoryId: 0, name: "", numOfLink: 0, order: 0)]))
    
    func getCategoryDataInShare(userIndex: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/category/all?id=\(userIndex)") else {
            print("invalid url")
            return
        }
        service.getCategoryListCompletionHandler(baseUrl: url) { result in
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let result):
                    print(result)
                    self.categoryList = result
                    break
                }
            }
        }
    }
}

class CategoryIDDelegate: ObservableObject {
    @Published var categoryID: Int = 0
    @Published var isChangedId: Bool = false
}

struct ShareUIView: View {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @StateObject var delegate : CategoryIDDelegate
    @StateObject var vm = CategoryViewModel()
    let selectedColor_dark = Color(red: 32/255, green: 32/255, blue: 32/255)
    let selectedColor_light = Color(red: 217/255, green: 217/255, blue: 217/255)

    @State private var selected : Int = 0 //이 값을 ShareViewController로 넘겨줘야 한다.
    private let userIndex = UserDefaults(suiteName: "group.com.thk.Scrap")?.integer(forKey: "ID") //user id 가져오기

    var body: some View {
        if userIndex == 0 { //로그인 안되어있으면
            VStack{
                Image("scrap")
                    .cornerRadius(14)
                    .padding(12)
                Text("Scrap 에 로그인 해주세요!")
                Divider()
                    .frame(width: UIScreen.main.bounds.width / 2)
                    .padding(.bottom, 10)
                Text("로그인 후 링크를 저장하실 수 있습니다.")
                    .font(.caption)
            }
            .padding(.bottom, 60)
        } else {
            List{
                ForEach($vm.categoryList.result.categories){ $category in
                    if category.order != 0 { //모든 자료는 제외
                        ZStack{
                            Text(category.name)
                                .foregroundColor(scheme == .light ? .black : .white)
                                .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                            Button(action: {
                                self.selected = category.categoryId
                                self.delegate.categoryID = category.categoryId
                                self.delegate.isChangedId = true
                            }) {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width - 20)
                                    .opacity(0)
                            }
                        }
                        .listRowBackground(self.selected == category.categoryId ? scheme == .light ? selectedColor_light : selectedColor_dark : .none)
                    }
                }
            }
            .listStyle(InsetListStyle())
            .onAppear{
                print("user idx: \(self.userIndex!)")
                vm.getCategoryDataInShare(userIndex: self.userIndex!)
            }
        }
    }
}

struct ShareUIView_Previews: PreviewProvider {
    static var previews: some View {
        ShareUIView(delegate: CategoryIDDelegate())
    }
}
