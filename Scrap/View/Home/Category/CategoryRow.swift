//
//  CategoryRow.swift
//  Scrap
//
//  Created by 김영선 on 2022/10/23.
//

import SwiftUI


struct CategoryRow: View {
    @Environment(\.colorScheme) var scheme //Light/Dark mode
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    
    @State private var categoryName = "category"
    
    @Binding var category : CategoryResponse.Category
    @Binding var detailCategory : CategoryResponse.Category
    
    @Binding var isPresentCategoryBottomSheet : Bool    //카테고리바텀시트 onoff
    @Binding var isShowingCategorySideMenuView : Bool   //카테고리 뷰 onoff
    
    @Binding var selectedCategoryId : Int
    @Binding var selectedCategoryOrder : Int
    
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height
    
    var title: String {
        var cnt = 0
        var tmp = category.name
        while cnt <= Int(screenWidth / 1.35) {
            tmp += " "
            cnt += 1
        }
        return tmp
    }
    
    var body: some View {
        HStack(spacing: 0){
            HStack(spacing: 0){
                Spacer()
                    .frame(width: screenWidth / 24)
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(Color("basic_text"))
                    .frame(width: screenWidth / 1.35, alignment: .leading)
                Text("\(category.numOfLink)")
                    .font(.system(size: 16))
                    .foregroundColor(Color("basic_text"))
                    .frame(width: screenWidth / 11, alignment: .trailing)
            }
            .onTapGesture {
                withAnimation(.spring()){
                    isShowingCategorySideMenuView = false //카테고리뷰 off
                }
                selectedCategoryId = category.categoryId
                selectedCategoryOrder = category.order
                scrapVM.getDataByCategory(userID: userVM.userIndex, categoryID: selectedCategoryId)
            }
            //더보기 버튼 -> modal shet 등장
            Button(action:{
                selectedCategoryId = category.categoryId
                detailCategory = category
                isPresentCategoryBottomSheet = true //카테고리바텀시트 on
            }){
                ZStack{
                    Image(systemName: "ellipsis")
                        .foregroundColor(Color("option_button"))
                }
                .frame(width: 36, height: 36)
            }
            Spacer()
                .frame(width: screenWidth / 10 - 36)
        }
        .frame(width: screenWidth)
        .listRowBackground(selectedCategoryId == category.categoryId ? Color("selected_color"): .none)
        .onAppear{
            UITableView.appearance().backgroundColor = .clear
        }
    }
}

//struct CategoryRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ForEach(["iPhone 14 Pro", "iPhone 8", "iPhone 13 mini"], id: \.self) {
//            CategoryView(categoryList: .constant(CategoryResponse.Result(categories: [
//                CategoryResponse.Category(categoryId: 0, name: "전체 자료", numOfLink: 500, order: 0),
//                CategoryResponse.Category(categoryId: 1, name: "분류되지 않은 자료", numOfLink: 42, order: 1),
//                CategoryResponse.Category(categoryId: 2, name: "채용 공고 모음", numOfLink: 6, order: 2),
//                CategoryResponse.Category(categoryId: 3, name: "iOS 자료", numOfLink: 30, order: 3),
//                CategoryResponse.Category(categoryId: 4, name: "컴퓨터 사이언스 자료", numOfLink: 140, order: 4),
//                CategoryResponse.Category(categoryId: 5, name: "취준 팁 모음", numOfLink: 60, order: 5),
//                CategoryResponse.Category(categoryId: 6, name: "개발자 정보!", numOfLink: 20, order: 6),
//                CategoryResponse.Category(categoryId: 7, name: "iOS 자료", numOfLink: 60, order: 7),
//                CategoryResponse.Category(categoryId: 8, name: "iOS 자료", numOfLink: 60, order: 8),
//                CategoryResponse.Category(categoryId: 9, name: "iOS 자료", numOfLink: 60, order: 9),
//                CategoryResponse.Category(categoryId: 10, name: "iOS 자료", numOfLink: 60, order: 10),
//                CategoryResponse.Category(categoryId: 11, name: "iOS 자료", numOfLink: 60, order: 11),
//                CategoryResponse.Category(categoryId: 12, name: "iOS 자료", numOfLink: 60, order: 12),
//                CategoryResponse.Category(categoryId: 13, name: "iOS 자료", numOfLink: 60, order: 13),
//                CategoryResponse.Category(categoryId: 14, name: "iOS 자료", numOfLink: 60, order: 14),
//                CategoryResponse.Category(categoryId: 15, name: "iOS 자료", numOfLink: 60, order: 15),
//                CategoryResponse.Category(categoryId: 16, name: "iOS 자료", numOfLink: 60, order: 16),
//                CategoryResponse.Category(categoryId: 17, name: "iOS 자료", numOfLink: 60, order: 17),
//                CategoryResponse.Category(categoryId: 18, name: "iOS 자료", numOfLink: 60, order: 18),
//                CategoryResponse.Category(categoryId: 19, name: "iOS 자료", numOfLink: 60, order: 19),
//                CategoryResponse.Category(categoryId: 20, name: "iOS 자료", numOfLink: 60, order: 20),
//                CategoryResponse.Category(categoryId: 21, name: "iOS 자료", numOfLink: 60, order: 21),
//                CategoryResponse.Category(categoryId: 22, name: "iOS 자료", numOfLink: 60, order: 22)
//            ])), isShowingCategoryView: .constant(true), selectedCategoryId: .constant(0), selectedCategoryOrder: .constant(0))
//            .environmentObject(ScrapViewModel())
//            .previewDevice(PreviewDevice(rawValue: $0))
//            .previewDisplayName($0) //각 프리뷰 컨테이너 이름지정
//        }
//    }
//}
