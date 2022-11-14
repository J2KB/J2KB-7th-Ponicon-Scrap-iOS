//
//  CategoryRow.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/23.
//

import SwiftUI

struct CategoryRow: View {
    @Binding var category : CategoryResponse.Category
    @State private var isEditing = false
    @State private var categoryName = "category"
    @Binding var isShowingCateogry : Bool
    @Binding var selected : Int
    @State private var isChangeRow = true
    @State private var isPresentHalfModal = false
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel //여기서 로그아웃
    @Environment(\.colorScheme) var scheme //Light/Dark mode

    var title: String {
        var cnt = 0
        var tmp = category.name
        while cnt <= Int(UIScreen.main.bounds.width - 120) {
            tmp += " "
            cnt += 1
        }
        return tmp
    }
    
    var body: some View {
        HStack{
            HStack{
                Text(title)
                    .font(.system(size: 16))
                    .frame(width: UIScreen.main.bounds.width - 120, alignment: .leading)
                Text("\(category.numOfLink)")
                    .font(.system(size: 16))
                    .frame(width: 30, alignment: .trailing)
            }
            .onTapGesture {
                self.selected = category.categoryId
                self.isEditing = false //edit mode 아님
                self.isChangeRow = true
                UserDefaults(suiteName: "group.com.thk.Scrap")?.set(selected, forKey: "lastCategory") //마지막 카테고리 id 저장
                print("\(selected) is selected category id")
                vm.getData(userID: userVM.userIdx, catID: selected, seq: "seq")
                withAnimation(.easeInOut.delay(0.3)){
                    isShowingCateogry = false
                }
            }
            //modal shet 등장
            Button(action:{
                self.isPresentHalfModal = true //half-modal view 등장
                self.selected = category.categoryId
                print("click option button")
            }){
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray_bold)
            }
            .frame(width: 24, height: 32)
        }
        .padding(.leading, 10)
        .listRowBackground(self.selected == category.categoryId ? (scheme == .light ? .gray_sub : .black_accent) : scheme == .light ? Color(.white) : .black_bg)
//        .alert("카테고리 이름 수정", isPresented: $isPresentHalfModal, actions: {
//            TextField("수정할 카테고리 이름", text: $category.name)
//            Button("취소", role: .cancel) {}
//            Button("수정") {
//                //📡 카테고리 이름 수정 서버 통신
////                vm.modifyCategory(categoryID: userVM.userIdx, categoryName: category.name)
//                //modify category name in local category list
////                vm.renameCategory(id: category.categoryId, renamed: c)
//                print("renamed category title")
//            }
//        })
//        .sheet(isPresented: $isPresentHalfModal){
//            HalfSheet {
//                VStack{
//                    Text(category.name)
//                        .frame(width: UIScreen.main.bounds.width - 40, alignment: .leading)
//                    List {
//                        Section {
//                            Button(action:{
////                                    vm.deleteData(userID: userVM.userIdx, linkID: data.linkId!)
////                                    vm.removeData(linkID: data.linkId!)
//                                self.isPresentHalfModal = false
//                            }){
//                                Label("삭제", systemImage: "trash")
//                                    .foregroundColor(.red)
//                            }
//                            .foregroundColor(.red)
//                        }
//                    }
//                    .background(Color("background"))
//                }
//                .padding(.top, 48)
//                .background(Color("background"))
//            }
//            .ignoresSafeArea()
//        }
//        .onAppear{
//            UITableView.appearance().backgroundColor = .clear
//        }
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRow(category: .constant(CategoryResponse.Category(categoryId: 0, name: "name", numOfLink: 10, order: 1)), isShowingCateogry: .constant(true), selected: .constant(0))
//            .preferredColorScheme(.dark)
    }
}
