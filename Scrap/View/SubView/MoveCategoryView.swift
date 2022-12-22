//
//  SaveDataView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/15.
//

import SwiftUI

struct MoveCategoryView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    
    @State private var wantedToMoveCategoryId = 0
    
    @Binding var isShowMovingCategoryView : Bool     //카테고리 이동을 위해 view를 열었는지에 대한 상태 변수
    @Binding var categoryList : CategoryResponse.Result
    @Binding var data : DataResponse.Datas
    @Binding var currentCategoryId : Int //현재 카테고리id
    
    var body: some View {
        ZStack{
            List{
                ForEach($categoryList.categories) { $category in
                    if category.order != 0 {
                        ZStack{
                            Text(category.name)
                                .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
                            Button(action: {
                                self.wantedToMoveCategoryId = category.categoryId
                            }) {
                                Rectangle()
                                    .frame(width: UIScreen.main.bounds.width - 20)
                                    .opacity(0)
                            }
                        }
                        .listRowBackground(self.wantedToMoveCategoryId == category.categoryId ? Color("selected_color") : .none)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .onAppear {
                self.wantedToMoveCategoryId = currentCategoryId
            }
        }
        .navigationBarTitle("카테고리 이동", displayMode: .inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    isShowMovingCategoryView.toggle()
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
                    scrapVM.moveDataToOtherCategory(data, from: currentCategoryId, to: wantedToMoveCategoryId)
                    scrapVM.modifyCategoryOfData(userID: userVM.userIndex, linkID: data.linkId!, categoryId: wantedToMoveCategoryId) //📡 자료의 카테고리 이동 서버 통신
                    isShowMovingCategoryView.toggle()
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
            isShowMovingCategoryView: .constant(true),
            categoryList: .constant(CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "1", numOfLink: 1, order: 0), CategoryResponse.Category(categoryId: 1, name: "2", numOfLink: 1, order: 2), CategoryResponse.Category(categoryId: 2, name: "3", numOfLink: 1, order: 3)])),
            data: .constant(DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "")),
            currentCategoryId: .constant(0)
        )
    }
}
