//
//  FavoritesView.swift
//  Scrap
//
//  Created by 김영선 on 2023/02/23.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel //favorites Array 넘기기
    
    @State private var isPresentFavoriteDataModalSheet = false
    @State private var detailData = DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "", bookmark: false)

    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        VStack{
            Text("즐겨찾기")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("basic_text"))
                .frame(width: screenWidth, height: 40, alignment: .leading)
                .padding(.leading, 24)
            SubHomeView(detailData: $detailData, isShowMovingCategory: .constant(false), datas: $scrapVM.favoriteList, isPresentDataModalSheet: $isPresentFavoriteDataModalSheet, currentCategoryId: .constant(-1), currentCategoryOrder: .constant(-1))
                .navigationBarTitle("", displayMode: .inline)
        }
        .bottomSheet(showSheet: $isPresentFavoriteDataModalSheet) {
            DataSheetView(isShowMovingCategoryView: .constant(false), data: $detailData, isPresentDataModalSheet: $isPresentFavoriteDataModalSheet,  currentCategoryOrder: .constant(-1), currentCategoryId: .constant(-1))
                .environmentObject(scrapVM)
        } onEnd: {
            print("dismissed")
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(ScrapViewModel())
    }
}
