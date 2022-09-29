//
//  HomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/05.
//


//로그인이 된 상태라면, 앱의 처음 시작은 HomeView
//사용자가 저장한 자료를 보거나 수정, 삭제할 수 있는 공간

import SwiftUI

//post model
struct NewCategoryModel: Decodable{
    //전송할 데이터 구조체 만들기
    var name: String //카테고리 이름
}

class ViewModel: ObservableObject{
    @Published var categoryList = CategoryResponse(code: 0, message: "", result: CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "", numOfLink: 0, order: 0)])) //초기화
    //categoryList에는 Category 값만 넣을 것..!
    @Published var dataList = DataResponse(code: 0, message: "", result: DataResponse.Result(links: [DataResponse.Datas(linkId: 0, link: "", title: "", imgUrl: "")]))
    
    @Published var user = UserResponse(code: 0, message: "", result: UserResponse.Result(name: "", username: ""))
    
    //카테고리 전체 조회
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
    
    //자료 조회 -> query: category id
    func getData(catID: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/data?id=2&category=\(catID)&seq=desc") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(DataResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.dataList = result
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
    
    //마이 페이지 -> query: user id
    func getMyData(userID: Int){
        guard let url = URL(string: "https://scrap.hana-umc.shop/user/mypage?id=\(userID)") else {
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
                } else {
                    print("no data")
                }
            }catch (let error){
                print("error")
                print(String(describing: error))
            }
        }.resume()
    }
    
    func addNewCategory(newCat: String){
        guard let url = URL(string: "https://scrap.hana-umc.shop/category?id=2") else {
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
                    let result = try decoder.decode(NewCategoryModel.self, from: data)
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }.resume()
    }
}

struct MainHomeView: View {
    @StateObject var vm = ViewModel()
    @State private var isShowingCategory = false
    @State private var isShowingMyPage = false
    @Binding var rootView : Bool
    @State private var selected : Int = 2
    var categoryTitle : String {
        return "\(vm.categoryList.result.categories[vm.categoryList.result.categories.firstIndex(where: {$0.categoryId == selected}) ?? 0].name)"
    }

    var body: some View {
        HStack(spacing: 0){
            //Drawer
            SideMenuView(categoryList: $vm.categoryList.result, vm: vm, categoryTitle: categoryTitle, selected: $selected)
            //Main Home
            NavigationView{
                SubHomeView(datas: $vm.dataList.result) //⭐️여기로 category 데이터 넘겨줘야 됨
                .navigationBarTitle("", displayMode: .inline)
                .toolbar{
                    ToolbarItem(placement: .navigationBarLeading){
                        HStack(spacing: 2){
                            Button(action: {
                                withAnimation(.easeInOut){
                                    self.isShowingCategory = true
                                }
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .frame(width: 20, height: 14)
                                    .foregroundColor(.black)
                            }
                            Text(categoryTitle)
                                .fontWeight(.bold)
                        }
                    }
                }
                .toolbar{
                    ToolbarItem(placement: .navigationBarTrailing){
                        VStack{
                            NavigationLink(destination: MyPageView(userData: $vm.user.result, rootView: $rootView), isActive: $isShowingMyPage) {
                                Button(action: {
                                    self.isShowingMyPage.toggle()
                                    vm.getMyData(userID: 9)
                                }) {
                                    Image(systemName: "person.circle")
                                        .foregroundColor(.black)
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width)
        }
        .frame(width: UIScreen.main.bounds.width)
        .offset(x: isShowingCategory ? UIScreen.main.bounds.width / 2.95 : -UIScreen.main.bounds.width / 2.6) //moving view
        .onAppear(perform: { //이 화면 등장하면 api 통신
            vm.getCategoryData()
        })
        .gesture(DragGesture().onEnded({
            if $0.translation.width < -100 {
                withAnimation(.easeInOut) {
                    self.isShowingCategory = false
                }
            }else if $0.translation.width > 100 {
                withAnimation(.easeInOut) {
                    self.isShowingCategory = true
                }
            }
        }))
    }
}

struct MainHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainHomeView(rootView: .constant(true))
//        LoginView()
    }
}
