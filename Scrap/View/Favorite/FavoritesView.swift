//
//  FavoritesView.swift
//  Scrap
//
//  Created by 김영선 on 2023/02/23.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var scrapVM : ScrapViewModel
    @EnvironmentObject var userVM : UserViewModel
    
    @State private var isPresentingFavoriteBottomSheet = false
    @State private var detailData = DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "", bookmark: false)
    
    @Binding var isShowingFavoriteView : Bool
    
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationView {
            ZStack{
                SubFavoriteView(detailData: $detailData, datas: $scrapVM.favoriteList, isPresentFavoriteBottomSheet: $isPresentingFavoriteBottomSheet)
                    .toolbar{
                        ToolbarItem(placement: .navigationBarLeading){
                            HStack(spacing: 8){
                                Button(action: {
                                    withAnimation(.easeInOut.delay(0.3)){
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                }) {
                                    Image(systemName: "chevron.backward")
                                        .resizable()
                                        .frame(width: 10, height: 16)
                                        .foregroundColor(Color("basic_text"))
                                }
                                Text("즐겨찾기")
                                    .font(.system(size: 18, weight: .bold))
                                    .frame(width: 100, height: 20, alignment: .leading)
                                    .foregroundColor(Color("basic_text"))
                            }
                        }
                    }
                if self.isPresentingFavoriteBottomSheet {
                    Color(.black)
                        .opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            self.isPresentingFavoriteBottomSheet = false
                        }
                }
            }
        }
        .gesture(DragGesture().onEnded({
            if $0.translation.width > 100 {
                withAnimation(.easeInOut) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        }))
        .sheet(isPresented: $isPresentingFavoriteBottomSheet){
            HalfSheet {
                FavoriteSheetView(data: $detailData, isPresentFavoriteBottomSheet: $isPresentingFavoriteBottomSheet, currentCategoryId: .constant(-1))
            }
            .ignoresSafeArea()
        }
    }
}


struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView(isShowingFavoriteView: .constant(false))
            .environmentObject(ScrapViewModel())
    }
}
