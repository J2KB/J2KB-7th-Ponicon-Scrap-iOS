//
//  ShareUIView.swift
//  Share
//
//  Created by 김영선 on 2022/10/09.
//

import SwiftUI

struct CategoryResponse: Decodable{
    struct Result: Decodable {
        var categories: [Category]
        
        init(categories: [Category]){
            self.categories = categories
        }
    }
    struct Category: Decodable, Identifiable{
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

class CategoryViewModel: ObservableObject{ //감시할 data model
    @Published var categoryList = CategoryResponse(code: 0, message: "", result: CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "", numOfLink: 0, order: 0)]))  //초기화
    
    func getCategoryData(){
        guard let url = URL(string: "https://scrap.hana-umc.shop/category/all?id=2") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(CategoryResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.categoryList = result
                    }
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


struct ShareUIView: View {
    let vm = CategoryViewModel()
    let light_gray = Color(red: 217/255, green: 217/255, blue: 217/255)
    @State private var selected : Int = 0 //이 값을 ShareViewController로 넘겨줘야 한다.
    let arr = ["분류되지 않은 자료", "category 1", "category 2", "category 3", "category 4"]

    var body: some View {
            List{
                ForEach(arr, id: \.self){ category in
                    Text(category)
//                ForEach(vm.categoryList.result.categories){ category in
//                    Text(category.name)
//                    .listRowBackground(self.selected == category.categoryId ? light_gray : Color(.white))
//                    .onTapGesture { //클릭하면 현재 categoryID
//                        self.selected = category.categoryId
//                    }
                }
            }
            .listStyle(InsetListStyle())
            .toolbar{
//                ToolbarItem(placement: .navigationBarLeading){
//                    Button("취소", action: {
//
//                    })
//                }
//            }
//            .toolbar{
//                ToolbarItem(placement: .navigationBarTrailing){
//                    Button("저장", action: {
//
//                    })
//                }
//            }
            }
        
    }
}

struct ShareUIView_Previews: PreviewProvider {
    static var previews: some View {
        ShareUIView()
    }
}
