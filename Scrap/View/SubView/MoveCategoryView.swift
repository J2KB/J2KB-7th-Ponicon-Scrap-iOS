//
//  SaveDataView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/15.
//

import SwiftUI

struct MoveCategoryView: View {
    //임시 데이터 -> 나중엔 데이터 받아올 것
    let arr = ["분류되지 않은 자료", "category 1", "category 2", "category 3", "category 4"]
    @State private var selection = 0
    
    //선택된 row는 색칠해줘야됨
    
    var body: some View {
        List{
            ForEach(arr, id: \.self){ category in
                Text(category)
            }
        }.listStyle(.inset)
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading){
                Button("취소", action: {

                })
            }
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing){
                Button("저장", action: {

                })
            }
        }
    }
}

struct MoveCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        MoveCategoryView()
    }
}
