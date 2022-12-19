//
//  MainHomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import UniformTypeIdentifiers

struct RefreshableScrollView<Content: View> : View {
    var content : Content
    var refreshable: () -> Void
    
    init(content: @escaping () -> Content, refreshable: @escaping () -> Void) {
        self.content = content()
        self.refreshable = refreshable
    }
    
    var body: some View {
        List {
            content
                .listRowSeparatorTint(.clear)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        .listStyle(.plain)
        .refreshable {
            refreshable()
        }
    }
}

struct SubHomeView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    
    @State private var detailData = DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "")
    @State private var isShowMovingCategory = false     //카테고리 이동을 위해 view를 열었는지에 대한 상태 변수
    @State private var isOneColumnData = true           //1열인가?
    @State private var isDataRecentOrder = true         //최신순인가?
    
    @Binding var datas : DataResponse.Result            //선택한 카테고리에 따른 자료 배열
    @Binding var isPresentDataModalSheet : Bool         //카테고리 더보기 sheet가 열려있는지에 대한 상태 변수
    @Binding var currentCategoryId : Int                //현재 카테고리 id
    @Binding var currentCategoryOrder : Int             //현재 카테고리 order
    
    var newDataArray = [NewData]()
    
    var body: some View {
        if scrapVM.isLoading {
            ProgressView()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .progressViewStyle(CircularProgressViewStyle(tint: Color.gray))
                .ignoresSafeArea()
        }else {
            RefreshableScrollView {
                VStack{
                    ScrollView(.vertical, showsIndicators: false){
                        HStack{
                            Button(action: {
                                if !isPresentDataModalSheet { //카테고리 더보기 sheet가 열려있으면 배경 버튼 비활성화
                                    self.isOneColumnData.toggle()
                                }
                            }){
                                Image(systemName: isOneColumnData ? "square.grid.2x2.fill" : "line.3.horizontal")
                                    .resizable()
                                    .frame(width: 16, height: isOneColumnData ? 16 : 12)
                                    .foregroundColor(.gray)
                            }
                            Text(isDataRecentOrder ? "최신순" : "오래된 순") //정렬 순서에 따라 달라짐 (최신순/오래된순)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Button(action: {
                                if !isPresentDataModalSheet { //카테고리더보기sheet가 열려있으면 배경 버튼 비활성화
                                    self.isDataRecentOrder.toggle()
                                }
                            }){
                                Image(systemName: "arrow.up.arrow.down")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 32, height: 40, alignment: .trailing)
                        LazyVGrid(columns: isOneColumnData ? [GridItem(.flexible())] : [GridItem(.adaptive(minimum: UIScreen.main.bounds.width / 2.8 ))], spacing: 10){
                            if isDataRecentOrder { //최신순
                                ForEach($datas.links.reversed()) { info in
                                    PageView(isPresentDataModalSheet: $isPresentDataModalSheet, data: info, detailData: $detailData, isOneColumnData: $isOneColumnData, currentCategoryId: $currentCategoryId, currentCategoryOrder: $currentCategoryOrder)
                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                }
                            } else { //오래된순
                                ForEach($datas.links) { info in
                                    PageView(isPresentDataModalSheet: $isPresentDataModalSheet, data: info, detailData: $detailData, isOneColumnData: $isOneColumnData, currentCategoryId: $currentCategoryId, currentCategoryOrder: $currentCategoryOrder)
                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                }
                            }
                        } //LAZYGRID
                    }//ScrollView
                    NavigationLink(destination: MoveCategoryView(isShowMovingCategoryView: $isShowMovingCategory, categoryList: $scrapVM.categoryList.result, data: $detailData, currentCategoryId: $currentCategoryId).navigationBarBackButtonHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowMovingCategory) { EmptyView() }
                        .opacity(0)
                }//VStack
            } refreshable: {
//                if let data = UserDefaults(suiteName: "group.com.thk.Scrap")?.value(forKey: "NewData") as? Data {
//                    let newDataArray = try? PropertyListDecoder().decode(NewData.self,from: data)
//                    if newDataArray != nil { //안에 값이 있다면
//                        print(newDataArray!)
////                        vm.addNewData(baseurl: newDataArray?.url ?? "", title: newDataArray?.title ?? "", imgUrl: newDataArray?.imageUrl ?? "", catID: newDataArray?.categoryID ?? 0, userIdx: userVM.userIdx)
//                        UserDefaults(suiteName: "group.com.thk.Scrap")?.removeObject(forKey: "NewData")
//                    }
//                }
                if currentCategoryOrder == 0 { scrapVM.getAllData(userID: userVM.userIndex) }
                else { scrapVM.getDataByCategory(userID: userVM.userIndex, categoryID: currentCategoryId) }
            }//Refreshable
            .sheet(isPresented: $isPresentDataModalSheet){
                HalfSheet {
                    DataSheetView(isShowMovingCategoryView: $isShowMovingCategory, data: $detailData, isPresentDataModalSheet: $isPresentDataModalSheet, currentCategoryOrder: $currentCategoryOrder, currentCategoryId: $currentCategoryId)
                }
                .ignoresSafeArea()
            }
        }
    }//body
}

struct SubHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainHomeView()
            .environmentObject(ScrapViewModel())
            .environmentObject(UserViewModel())
    }
}
