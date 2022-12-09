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
    @Environment(\.colorScheme) var scheme              //Light/Dark mode
    @EnvironmentObject var vm : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    @State private var isShowMovingCategory = false     //카테고리 이동을 위해 view를 열었는지에 대한 상태 변수
    @State private var isOneCol = true                  //1열인가?
    @State private var isRecent = true                  //최신순인가?
    @Binding var datas : DataResponse.Result            //선택한 카테고리에 따른 자료 배열
    @Binding var isPresentHalfModal : Bool              //카테고리 더보기 sheet가 열려있는지에 대한 상태 변수
    @Binding var currentCategory : Int                  //현재 카테고리 id
    @Binding var currentCategoryOrder : Int             //현재 카테고리 order
    @State private var detailData = DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "")

    var body: some View {
        if vm.isLoading == .loading { //서버통신(로딩)중이면 progress view 등장(loading indicator)
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
                                if !isPresentHalfModal {       //카테고리더보기sheet가 열려있으면 배경 버튼 비활성화
                                    self.isOneCol.toggle()
                                }
                            }){
                                Image(systemName: isOneCol ? "square.grid.2x2.fill" : "line.3.horizontal")
                                    .resizable()
                                    .frame(width: 16, height: isOneCol ? 16 : 12)
                                    .foregroundColor(.gray)
                            }
                            Text(isRecent ? "최신순" : "오래된 순") //정렬 순서에 따라 달라짐 (최신순/오래된순)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            Button(action: {
                                if !isPresentHalfModal {      //카테고리더보기sheet가 열려있으면 배경 버튼 비활성화
                                    self.isRecent.toggle()
                                }
                            }){
                                Image(systemName: "arrow.up.arrow.down")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(width: UIScreen.main.bounds.width - 32, height: 40, alignment: .trailing)
                        LazyVGrid(columns: isOneCol ? [GridItem(.flexible())] : [GridItem(.adaptive(minimum: UIScreen.main.bounds.width / 2.8 ))], spacing: 10){
                            if isRecent { //최신순
                                ForEach($datas.links.reversed()) { info in
                                    PageView(isPresentHalfModal: $isPresentHalfModal, data: info, detailData: $detailData, isOneCol: $isOneCol, currentCategory: $currentCategory, currentCatOrder: $currentCategoryOrder)
                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                }
                            } else {      //오래된순
                                ForEach($datas.links) { info in
                                    PageView(isPresentHalfModal: $isPresentHalfModal, data: info, detailData: $detailData, isOneCol: $isOneCol, currentCategory: $currentCategory, currentCatOrder: $currentCategoryOrder)
                                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
                                }
                            }
                        } //LAZYGRID
                    }//ScrollView
                    NavigationLink(destination: MoveCategoryView(isShowMovingCategory: $isShowMovingCategory, categoryList: $vm.categoryList.result, data: $detailData, currentCategory: $currentCategory).navigationBarBackButtonHidden(true).navigationBarBackButtonHidden(true), isActive: $isShowMovingCategory) { EmptyView() }
                        .opacity(0)
                }//VStack
            } refreshable: {
                if currentCategoryOrder == 0 {
                    vm.inquiryAllData(userID: userVM.userIdx)
                }else {
                    vm.inquiryData(userID: userVM.userIdx, catID: currentCategory)
                }
            }//Refreshable
            .sheet(isPresented: $isPresentHalfModal){ //isPresentHalfModal == true일때 sheet 열림
                HalfSheet {
                    DataSheetView(isShowMovingCategory: $isShowMovingCategory, data: $detailData, isPresentHalfModal: $isPresentHalfModal, currentCatOrder: $currentCategoryOrder, currentCategory: $currentCategory)
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
            .preferredColorScheme(.dark)
    }
}
