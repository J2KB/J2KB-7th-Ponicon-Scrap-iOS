//
//  SaveDataView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/15.
//

import SwiftUI

struct MoveCategoryView: View {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @Binding var isShowMovingCategory : Bool     //카테고리 이동을 위해 view를 열었는지에 대한 상태 변수
    @Binding var categoryList : CategoryResponse.Result
    @State private var selection = 0
    @Binding var data : DataResponse.Datas
    @Binding var currentCategory : Int //현재 카테고리id
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    
    //선택된 row는 색칠해줘야됨
    var body: some View {
        ZStack{
            List{
                ForEach($categoryList.categories) { $category in
                    if category.order != 0 {
                        ZStack{
                            Text(category.name)
                                .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                            Button(action: {
                                self.selection = category.categoryId
                            }) {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width - 20)
                                    .opacity(0)
                            }
                        }
                        .listRowBackground(self.selection == category.categoryId ? Color("selected_color") : Color("background"))
                    }
                }
            }
            .listStyle(PlainListStyle())
            .onAppear {
                self.selection = currentCategory
            }
        }
        .background(Color("background"))
        .navigationBarTitle("카테고리 이동", displayMode: .inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    isShowMovingCategory.toggle()
                }){
                    Text("취소")
                        .fontWeight(.semibold)
                        .foregroundColor(Color("basic_text"))
                }
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: {
                    //📡 자료의 카테고리 이동 서버 통신
                    //로컬(프론트)에서는 현재 카테고리에서 삭제해야됨 (dataList에서 해당 자료 삭제)
                    vm.modifyDatasCategory(userID: userVM.userIdx, linkID: data.linkId!, categoryId: selection)
//                    vm.movingData(linkID: data.link!, categoryID: selection)
                    isShowMovingCategory.toggle()
                }) {
                    Text("저장")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue_bold)
                }
            }
        }
    }
}

struct MoveCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        MoveCategoryView(
            isShowMovingCategory: .constant(true),
            categoryList: .constant(CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "1", numOfLink: 1, order: 0), CategoryResponse.Category(categoryId: 1, name: "2", numOfLink: 1, order: 2), CategoryResponse.Category(categoryId: 2, name: "3", numOfLink: 1, order: 3)])),
            data: .constant(DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "")),
            currentCategory: .constant(0)
        )
        .preferredColorScheme(.dark)
    }
}
