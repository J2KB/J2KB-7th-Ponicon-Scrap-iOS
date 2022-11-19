//
//  CategoryRow.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/23.
//

import SwiftUI

enum Field: Hashable {
   case categoryName
 }

struct CategoryRow: View {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @EnvironmentObject var vm : ScrapViewModel //여기서 카테고리 추가 post api 보내야되니까 필요
    @EnvironmentObject var userVM : UserViewModel //여기서 로그아웃
    @Binding var category : CategoryResponse.Category
    @State private var categoryName = "category"
    @Binding var isShowingCateogry : Bool
    @Binding var selected : Int
    @State private var isChangeRow = true
    @State private var isPresentHalfModal = false
    @State private var isDelete = false
    @State private var isEditingName = false
    @Binding var isAddingCategory : Bool
    @Binding var selectedOrder : Int
    @FocusState private var focusField: Field?
    
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
                if !isAddingCategory {
                    self.selected = category.categoryId
                    self.selectedOrder = category.order
                    self.isChangeRow = true
                    UserDefaults(suiteName: "group.com.thk.Scrap")?.set(selected, forKey: "lastCategory") //마지막 카테고리 id 저장
                    print("\(selected) is selected category id")
                    vm.getData(userID: userVM.userIdx, catID: selected, seq: "seq")
                    withAnimation(.easeInOut.delay(0.3)){
                        isShowingCateogry = false
                    }
                }
            }
            //modal shet 등장
            Button(action:{
                if !isAddingCategory && !isPresentHalfModal {
                    self.isPresentHalfModal = true //half-modal view 등장
                    self.selected = category.categoryId
                }
            }){
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray_bold)
            }
            .frame(width: 24, height: 32)
        }
        .padding(.leading, 10)
        .listRowBackground(self.selected == category.categoryId ? (scheme == .light ? .gray_sub : .black_accent) : scheme == .light ? Color(.white) : .black_bg)
        .sheet(isPresented: $isPresentHalfModal){
            HalfSheet {
                VStack{
                    if isEditingName {
//                        ZStack{
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(scheme == .light ? Color("gray_sub") : Color("black_bold"))
//                                .opacity(0.4)
//                                .frame(width: UIScreen.main.bounds.width - 30, height: 40, alignment: .leading)
                        TextField("카테고리 이름", text: $category.name)
                            .focused($focusField, equals: .categoryName)
                            .frame(width: UIScreen.main.bounds.width - 50, alignment: .leading)
                            .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
//                            .onSubmit{ //return 시 -> 서버 통신
//                                📡 카테고리 이름 수정 서버 통신
//                                vm.modifyCategory(categoryID: userVM.userIdx, categoryName: category.name)
                            //modify category name in local category list
//                                vm.renameCategory(id: category.categoryId, renamed: c)
//                            }
//                        }
                    } else {
                        Text(category.name)
                            .frame(width: UIScreen.main.bounds.width - 50, alignment: .leading)
                            .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                    }
                    
                    List {
                        Section {
                            Button(action:{
                                if !isEditingName { //이름 수정하지 않을 때만 활성화
                                    print("renamed category title")
                                    self.isEditingName = true
                                    focusField = .categoryName //user name TextField에 커서 올라가고, 키보드 등장
                                    print(isEditingName)
                                }
                            }){
                                Label("이름 수정", systemImage: "pencil")
                                    .foregroundColor(scheme == .light ? .black_bold : .gray_sub)
                            }
                            Button(action:{
                                if !isEditingName { //이름 수정하지 않을 때만 활성화
                                    self.isDelete = true
                                }
                            }){
                                Label("삭제", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                            .foregroundColor(.red)
                        }
                        .listRowBackground(scheme == .light ? Color(.white) : .black_bold)
                    }
                    .background(scheme == .light ? Color("background") : .black_bg)
                }
                .padding(.top, 48)
                .background(scheme == .light ? Color("background") : .black_bg)
            }
            .ignoresSafeArea()
        }
//        .alert("정말 삭제하시겠습니까?", isPresented: $isDelete, actions: {
//            Button("취소", role: .cancel) {}
//            Button("삭제", role: .destructive) {
//                //📡 카테고리 삭제 서버 통신
////                vm.deleteCategory(categoryID: category.categoryId) //📡 카테고리 삭제 통신
////                vm.removeCategory(index: category.order) //선택한 카테고리의 인덱스
////                self.isPresentHalfModal = false
//                isDelete = false
//                print("delete category")
//            }
//        }/*, message: {
//            Text("삭제한 카테고리는 복구할 수 없습니다")
//        }*/)
        .onAppear{
            UITableView.appearance().backgroundColor = .clear
        }
    }
}

struct CategoryRow_Previews: PreviewProvider {
    static var previews: some View {
        CategoryRow(category: .constant(CategoryResponse.Category(categoryId: 0, name: "name", numOfLink: 10, order: 1)), isShowingCateogry: .constant(true), selected: .constant(0), isAddingCategory: .constant(true), selectedOrder: .constant(0))
            .preferredColorScheme(.dark)
    }
}
