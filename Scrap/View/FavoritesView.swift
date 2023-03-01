//
//  FavoritesView.swift
//  Scrap
//
//  Created by 김영선 on 2023/02/23.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var scrapVM : ScrapViewModel //favorites Array 넘기기
    @State private var isPresentFavDataModalSheet = false
    
    private let screenHeight = UIScreen.main.bounds.height
    private let screenWidth = UIScreen.main.bounds.width
    
    var body: some View {
        VStack{
            Text("즐겨찾기")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color("basic_text"))
                .frame(width: screenWidth, height: 40, alignment: .leading)
                .padding(.leading, 24)
            SubHomeView(datas: $scrapVM.dataList, isPresentDataModalSheet: $isPresentFavDataModalSheet, currentCategoryId: .constant(-1), currentCategoryOrder: .constant(-1))
                .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
            .environmentObject(ScrapViewModel())
    }
}
