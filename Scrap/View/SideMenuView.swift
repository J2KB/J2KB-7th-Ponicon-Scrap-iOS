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
    @State private var maxCatName = 20
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @Binding var selected : Int
    let light_gray = Color(red: 217/255, green: 217/255, blue: 217/255)

    var body: some View {
//        HStack{
            VStack{
                HStack{
                    Text("카테고리") //리스트 선택 기능을 구현하고 이 기능을 추가하는 것으로!
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                    Spacer()
                    Button(action: {}){
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.black)
                    }
                    Button(action: {
                        self.isAddingCategory.toggle()
                    }){
                        Image(systemName: isAddingCategory ? "xmark" : "plus")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.black)
                    }
                }
                .padding(.leading, 14)
                .frame(width: UIScreen.main.bounds.width / 1.45, height: 48)
                VStack{
                    List{
                        ForEach($categoryList.categories) { $category in
                            HStack{
                                Text(category.name)
                                    .font(.system(size: 16))
                                Spacer()
                                Text("\(category.numOfLink)")
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .listRowBackground(self.selected == category.categoryId ? light_gray : Color(.white))
                            .frame(width: UIScreen.main.bounds.width / 1.55)
                            .padding(4)
                            .onTapGesture { //클릭하면 현재 categoryID
                                self.selected = category.categoryId
                                vm.getData(catID: selected)
                            }
                        }
                    }
//                    .refreshable{
//                        await vm.getCategoryData()
//                        print("refresh")
//                    }
                    .listStyle(InsetListStyle())
                    if isAddingCategory {
                        HStack{
                            Image(systemName: "square.and.pencil")
                            TextField("새로운 카테고리", text: $newCat,
                              onCommit: {
                                vm.addNewCategory(newCat: newCat)
                                let newCategory = CategoryResponse.Category(categoryId: vm.categoryID, name: newCat, numOfLink: 0, order: 0)
                                vm.appendCategory(newCategory: newCategory) //append 함수 구현하기
                                //post로 추가된 카테고리 이름 서버에 전송
                                //reload list - how can i do this?
                                newCat = ""
                                isAddingCategory = false
                              }
//                            엔터를 치면 post api로 카테고리 서버 저장 && list에 추가
                            )
                            .disableAutocorrection(true) //자동 수정 비활성화
                        }
                        .frame(width: UIScreen.main.bounds.width / 1.55)
                        .padding(10)
                        .background(Color(hue: 1.0, saturation: 0.0, brightness: 0.921))
                        .cornerRadius(10)
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width / 1.3)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainHomeView()
            .environmentObject(ScrapViewModel())
    }
}
