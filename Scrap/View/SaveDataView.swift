//
//  SaveDataView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/15.
//

import SwiftUI

struct SaveDataView: View {
    //임시 데이터 -> 나중엔 데이터 받아올 것
    @State private var arr = ["category 1", "category 2", "category 3", "category 4"]
    @State private var allDoc = "모든 자료"
    @State private var notDi = "분류되지 않은 자료"
    
    var body: some View {
        VStack{
            Button(action:{
                //저장 기능
                //앱 종료
            }){
                Text("저장")
                    .frame(width: UIScreen.main.bounds.width/2, height: 32, alignment: .center)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    .padding(10)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.bottom, 32)
            CategoryRowView(text: $allDoc) //모든 자료
                .padding(.vertical, 2)
            CategoryRowView(text: $notDi)  //분류되지 않은 자료
                .padding(.vertical, 2)
            ForEach($arr, id: \.self) { i in
                CategoryRowView(text: i) //button으로 변경하기
                    .padding(.vertical, 2)
            }
        }.padding(.top, -UIScreen.main.bounds.height/5)
    }
}

struct SaveDataView_Previews: PreviewProvider {
    static var previews: some View {
        SaveDataView()
    }
}
