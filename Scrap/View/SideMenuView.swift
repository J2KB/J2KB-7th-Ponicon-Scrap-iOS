//
//  SideMenuView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import Combine

struct SideMenuView: View {
    @Binding var categoryList : CategoryResponse.Result
    @State private var newCat = "" //초기화해줘야 함
    @State private var isAddingCategory = false
    @Binding var isShowingCateogry : Bool
    @State private var maxCatName = 20
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel //ScrapApp에서 연결받은 EnvironmentObject
    @Binding var selected : Int
    let light_gray = Color(red: 217/255, green: 217/255, blue: 217/255)

    var body: some View {
        VStack(spacing: 20){
            //HEADER
            HStack{
                HStack(spacing: 12){
                    Button(action: {
                        withAnimation(.easeInOut){
                            isShowingCateogry = false
                        }
                    }){
                        Image(systemName: "chevron.backward")
                            .resizable()
                            .frame(width: 10, height: 16)
                            .foregroundColor(.black)
                    }
                    Text("카테고리")
                        .font(.system(size: 18, weight: .semibold))
                        .frame(width: 70, height: 20, alignment: .leading)
                }
                Spacer()
                Button(action: {
                    self.isAddingCategory.toggle()
                }){
                    Image(systemName: isAddingCategory ? "xmark" : "plus")
                        .resizable()
                        .frame(width: 16, height: 16)
                        .foregroundColor(.black)
                }
            }
            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 4) - 16)
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            .background(.white)
            //Category LIST
            VStack{
                List{
                    ForEach($categoryList.categories) { $category in
                        HStack{
                            Text(category.name)
                                .font(.system(size: 16))
                                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 2.4), alignment: .leading)
                            Text("\(category.numOfLink)")
                                .font(.system(size: 16))
                                .frame(width: 30, alignment: .trailing)
                        }
                        .listRowBackground(self.selected == category.categoryId ? light_gray : Color(.white))
                        .onTapGesture { //클릭하면 현재 categoryID
                            self.selected = category.categoryId
                            vm.getData(userID: 2, catID: selected, seq: "desc")
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 4))
                .listStyle(InsetListStyle())
//                if isAddingCategory {
//                    HStack{
//                        Image(systemName: "square.and.pencil")
//                        TextField("새로운 카테고리", text: $newCat,
//                          onCommit: {
//                            vm.addNewCategory(newCat: newCat, userID: 2)
//                            let newCategory = CategoryResponse.Category(categoryId: vm.categoryID, name: newCat, numOfLink: 0, order: 0)
//                            vm.appendCategory(newCategory: newCategory) //append 함수 구현하기
//                            //post로 추가된 카테고리 이름 서버에 전송
//                            newCat = ""
//                            isAddingCategory = false
//                          }
//                        )
//                        .disableAutocorrection(true) //자동 수정 비활성화
//                    }
//                    .frame(width: UIScreen.main.bounds.width / 1.55)
//                    .padding(10)
//                    .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.921))
//                    .cornerRadius(10)
//                }
            }
        }
//            .frame(width: UIScreen.main.bounds.width / 1.35)
            .frame(width: UIScreen.main.bounds.width - (UIScreen.main.bounds.width / 4))
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
//        MainHomeView(popRootView: .constant(true))
//                .environmentObject(ScrapViewModel())
        SideMenuView(categoryList: .constant(CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "1", numOfLink: 1, order: 1)])), isShowingCateogry: .constant(true), selected: .constant(1))
            .environmentObject(ScrapViewModel())
        }
    }
}
