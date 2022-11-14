//
//  SaveDataView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/15.
//

import SwiftUI

struct MoveCategoryView: View {
    @Binding var categoryList : CategoryResponse.Result
    @State private var selection = 0
    @Binding var data : DataResponse.Datas
    @Binding var currentCategory : Int //현재 카테고리id
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode> //pop
    
    //선택된 row는 색칠해줘야됨
    var body: some View {
        List{
            ForEach($categoryList.categories) { $category in
                Text(category.name)
                    .listRowBackground(self.selection == category.categoryId ? .gray_sub : Color(.white))
                    .onTapGesture { //클릭하면 현재 categoryID
                        self.selection = category.categoryId
                    }
            }
        }
        .listStyle(.inset)
        .onAppear {
            self.selection = currentCategory
        }
        .navigationBarTitle("카테고리 이동", displayMode: .inline)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss() //pop
                }){
                    Text("취소")
                        .fontWeight(.semibold)
                        .foregroundColor(.black_bold)
                }
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button(action: {
                    //📡 자료의 카테고리 이동 서버 통신
                    //로컬(프론트)에서는 현재 카테고리에서 삭제해야됨 (dataList에서 해당 자료 삭제)
                    vm.modifyDatasCategory(userID: userVM.userIdx, linkID: data.linkId!, categoryId: selection)
//                    vm.removeData(linkID: data.linkId!)
                    self.presentationMode.wrappedValue.dismiss() //pop
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
        MoveCategoryView(categoryList: .constant(CategoryResponse.Result(categories: [CategoryResponse.Category(categoryId: 0, name: "1", numOfLink: 1, order: 0),
            CategoryResponse.Category(categoryId: 1, name: "2", numOfLink: 1, order: 2),
            CategoryResponse.Category(categoryId: 2, name: "3", numOfLink: 1, order: 3)])), data: .constant(DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "")), currentCategory: .constant(0))
    }
}
