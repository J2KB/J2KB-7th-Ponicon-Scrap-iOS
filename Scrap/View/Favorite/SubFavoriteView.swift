//
//  SubFavoriteView.swift
//  Scrap
//
//  Created by 김영선 on 2023/03/27.
//

import SwiftUI

struct SubFavoriteView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    
    @State private var isOneColumnData = true           //1열인가?
    @State private var isDataRecentOrder = true         //최신순인가?
    
    @Binding var detailData: DataResponse.Datas
    @Binding var datas : DataResponse.Result            //선택한 카테고리에 따른 자료 배열
    @Binding var isPresentFavoriteBottomSheet : Bool    //Favorite 더보기 sheet가 열려있는지에 대한 상태 변수
    
    
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
                                self.isOneColumnData.toggle()
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
                                self.isDataRecentOrder.toggle()
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
                                    PageView(isPresentingBottomSheet: $isPresentFavoriteBottomSheet, data: info, detailData: $detailData, isOneColumnData: $isOneColumnData)
                                }
                            } else { //오래된순
                                ForEach($datas.links) { info in
                                    PageView(isPresentingBottomSheet: $isPresentFavoriteBottomSheet, data: info, detailData: $detailData, isOneColumnData: $isOneColumnData)
                                }
                            }
                        } //LAZYGRID
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        
                    }//ScrollView
                }//VStack
            } refreshable: {
                scrapVM.getAllData(userID: userVM.userIndex)
            }
        }
    }//body
}
