//
//  TestIDDuplication.swift
//  Scrap
//
//  Created by 김영선 on 2022/09/16.
//

import SwiftUI

//let getUrl = "https://hana-umc.shop/user/duplicate?id=test0303"

//model
struct Model: Decodable{
    struct Result: Decodable{
        let duplication: Bool
    }
    let code: Int
    let message: String
    let result: Result
}

//view model
class ViewModel: ObservableObject{
    @Published var items = [Model]()
    
    func loadData(id: String){
        guard let url = URL(string: "https://hana-umc.shop/user/duplicate?id=\(id)") else {
            print("invalid url")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(Model.self, from: data)
                    print(id)
                    print(result)
                } else {
                    print("no data")
                }
            }catch (let error){
                print(String(describing: error))
            }
        }.resume()
    }
    
//    func postData(){
//        guard let url = URL(string: getUrl) else {
//            print("invalid url")
//            return
//        }
//        let id = "test0303"
//        let body: [String: Any] = ["id": id]
//        let finalData = try! JSONSerialization.data(withJSONObject: body)
//
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.httpBody = finalData
//        request.setValue("", forHTTPHeaderField: "")
//
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            do{
//                if let data = data {
//                    let decoder = JSONDecoder()
//                    let result = try decoder.decode(Model.self, from: data)
//                    print(result)
//                } else {
//                    print("no data")
//                }
//            }catch (let error){
//                print(String(describing: error))
//            }
//        }.resume()
//    }
}

struct TestIDDuplication: View {
    @ObservedObject var vm = ViewModel()
    @State private var userid = ""
    
    var body: some View {
        NavigationView{
            VStack{
                TextField("userid", text: $userid)
                Button("click", action:{
                    vm.loadData(id: userid)
                })
            }
        }
    }
}

struct TestIDDuplication_Previews: PreviewProvider {
    static var previews: some View {
        TestIDDuplication()
    }
}
