//
//  SideMenuView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/08.
//

import SwiftUI
import Combine

struct SideMenuView: View {
    @State private var arr = ["category 1", "category 2", "category 3", "category 4"]
    @State private var allDoc = "모든 자료"
    @State private var notDi = "분류되지 않은 자료"
    @State private var newCat = "" //초기화해줘야 함
//    @Binding var isAddingCategory : Bool
    @State private var maxCatName = 20
    
    var body: some View {
//        HStack{
            VStack{
                HStack{
                    Text("카테고리 이름")
                        .font(.system(size: 24))
                        .fontWeight(.bold)
                    Spacer()
                    Button(action: {}){
                        Image(systemName: "pencil")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.black)
                    }
                    Button(action: {}){
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.black)
                    }
                }
                .padding(.leading, 6)
                .frame(width: UIScreen.main.bounds.width / 1.5, height: 48)
                HStack{
                    List{
                        HStack{
                            Text(allDoc)
                                .font(.system(size: 16))
                            Spacer()
                            Text("\(12)")
                                .font(.system(size: 16))
                        }
                        .frame(width: UIScreen.main.bounds.width / 1.5)
                        .padding(4)
                        HStack{
                            Text(notDi)
                                .font(.system(size: 16))
                            Spacer()
                            Text("\(100)")
                                .font(.system(size: 16))
                        }
                        .frame(width: UIScreen.main.bounds.width / 1.5)
                        .padding(4)
                        ForEach(arr, id: \.self) { ar in
                            HStack{
                                Text(ar)
                                    .font(.system(size: 16))
                                Spacer()
                                Text("\(14)")
                            }
                            .frame(width: UIScreen.main.bounds.width / 1.5)
                            .padding(4)
                        }
                    }
                    .listStyle(InsetListStyle())
                }
            }
            .frame(width: UIScreen.main.bounds.width / 1.3)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            HomeView()
            SideMenuView()
        }
    }
}
