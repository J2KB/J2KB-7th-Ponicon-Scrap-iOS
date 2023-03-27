//
//  FavoritesView.swift
//  Scrap
//
//  Created by 김영선 on 2023/02/23.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel //favorites Array 넘기기
    @EnvironmentObject var userVM : UserViewModel //favorites Array 넘기기

    @State private var isPresentingFavoriteBottomSheet = false
    @State private var detailData = DataResponse.Datas(linkId: 0, link: "", title: "", domain: "", imgUrl: "", bookmark: false)

    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        NavigationView {
            VStack{
                Text("즐겨찾기")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("basic_text"))
                    .frame(width: screenWidth, height: 40, alignment: .leading)
                    .padding(.leading, 24)
                SubFavoriteView(detailData: $detailData, datas: $scrapVM.favoriteList, isPresentFavoriteBottomSheet: $isPresentingFavoriteBottomSheet)
            }
            .bottomSheet(showSheet: $isPresentingFavoriteBottomSheet) {
                FavoriteSheetView(data: $detailData, isPresentFavoriteBottomSheet: $isPresentingFavoriteBottomSheet, currentCategoryId: .constant(-1))
                    .environmentObject(scrapVM)
                    .environmentObject(userVM)
            } onEnd: {
                isPresentingFavoriteBottomSheet = false
            }
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(ScrapViewModel())
    }
}
