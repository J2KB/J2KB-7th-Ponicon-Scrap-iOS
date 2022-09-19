//
//  SaveDataView.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/15.
//

import SwiftUI

struct SaveDataView: View {
    //임시 데이터 -> 나중엔 데이터 받아올 것
    let arr = ["모든 자료", "분류되지 않은 자료", "category 1", "category 2", "category 3", "category 4"]
    @State private var title = ""
    @State private var allDoc = "모든 자료"
    @State private var notDi = "분류되지 않은 자료"
    @State private var selection = 0
    
    var body: some View {
        NavigationView{
            Form{
                Section{
                    TextField("자료 제목", text: $title)
                }
                Section{
                    Picker("저장할 카테고리", selection: $selection) {
                        ForEach(0..<arr.count){
                            Text("\(self.arr[$0])")
                        }
                    }
                }
            }
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
}

struct SaveDataView_Previews: PreviewProvider {
    static var previews: some View {
        SaveDataView()
    }
}
