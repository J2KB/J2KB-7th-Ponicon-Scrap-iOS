//
//  SubHomeView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import UniformTypeIdentifiers

struct SubHomeView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    
    @State private var isOneColumnData = true           //1열인가?
    @State private var isDataRecentOrder = true         //최신순인가?
    
    @Binding var detailData: DataResponse.Datas
    @Binding var isShowMovingCategory: Bool             //자료의 카테고리 이동 onoff
    @Binding var datas : DataResponse.Result            //선택한 카테고리에 따른 자료 배열
    @Binding var isPresentDataBottomSheet : Bool        //데이터 바텀 시트 onoff
    @Binding var currentCategoryId : Int                //현재 카테고리 id
    @Binding var currentCategoryOrder : Int             //현재 카테고리 order
        
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
                        HStack(spacing: 2){
                            Button(action: {
                                if !isPresentDataBottomSheet { //카테고리 더보기 sheet가 열려있으면 배경 버튼 비활성화
                                    self.isOneColumnData.toggle()
                                }
                            }){
                                ZStack {
                                    Image(systemName: isOneColumnData ? "square.grid.2x2.fill" : "line.3.horizontal")
                                        .resizable()
                                        .frame(width: 16, height: isOneColumnData ? 16 : 12)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 24, height: 24)
                            }
                            Text(isDataRecentOrder ? "최신순" : "오래된 순") //정렬 순서에 따라 달라짐 (최신순/오래된순)
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            Button(action: {
                                if !isPresentDataBottomSheet { //카테고리더보기sheet가 열려있으면 배경 버튼 비활성화
                                    self.isDataRecentOrder.toggle()
                                }
                            }){
                                ZStack {
                                    Image(systemName: "arrow.up.arrow.down")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 24, height: 24)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width / 1.105, height: 30, alignment: .trailing)
                        
                        LazyVGrid(columns: isOneColumnData ? [GridItem(.flexible())] : [GridItem(.adaptive(minimum: UIScreen.main.bounds.width / 2.2))], spacing: 20){
                            if isDataRecentOrder { //최신순
                                ForEach($datas.links.reversed()) { info in
                                    PageView(isPresentingBottomSheet: $isPresentDataBottomSheet, data: info, detailData: $detailData, isOneColumnData: $isOneColumnData)
                                }
                            } else { //오래된순
                                ForEach($datas.links) { info in
                                    PageView(isPresentingBottomSheet: $isPresentDataBottomSheet, data: info, detailData: $detailData, isOneColumnData: $isOneColumnData)
                                }
                            }
                        } //LAZYGRID
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        
                    }//ScrollView
                    NavigationLink(destination: MoveCategoryView(isShowMovingCategoryView: $isShowMovingCategory, categoryList: $scrapVM.categoryList.result, data: $detailData, currentCategoryId: $currentCategoryId).navigationBarBackButtonHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowMovingCategory) { EmptyView() }
                        .opacity(0)
                }//VStack
            } refreshable: {
                if currentCategoryOrder == 0 { scrapVM.getAllData(userID: userVM.userIndex) }
                else { scrapVM.getDataByCategory(userID: userVM.userIndex, categoryID: currentCategoryId) }
            }
            .onChange(of: currentCategoryId, perform: { newValue in
                if currentCategoryOrder == 0 { scrapVM.getAllData(userID: userVM.userIndex) }
                else { scrapVM.getDataByCategory(userID: userVM.userIndex, categoryID: newValue) }
            }).sheet(isPresented: $isPresentDataBottomSheet){
                HalfSheet {
                    DataSheetView(isShowMovingCategoryView: $isShowMovingCategory, data: $detailData, isPresentDataModalSheet: $isPresentDataBottomSheet, currentCategoryOrder: $currentCategoryOrder, currentCategoryId: $currentCategoryId)
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
