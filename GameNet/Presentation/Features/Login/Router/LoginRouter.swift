//
//  LoginRouter.swift
//  GameNet
//
//  Created by Alliston Aleixo on 30/07/22.
//

import SwiftUI

enum LoginRouter {
    static func makeHomeView() -> some View {
        let homeViewModel = HomeViewModel()
        let dashboardViewModel = DashboardViewModel()

        return HomeView(
            homeViewModel: homeViewModel,
            dashboardViewModel: dashboardViewModel
        )
    }
//    static func makeHomeView() -> some View {
//        let viewModel = HomeViewModel()
//        return HomeView(viewModel: viewModel)
//    }
//
//    static func makeSignUpView(publisher: PassthroughSubject<Bool, Never>) -> some View {
//        let viewModel = SignUpViewModel()
//        viewModel.publisher = publisher
//        return SignUpView(viewModel: viewModel)
//    }
}
