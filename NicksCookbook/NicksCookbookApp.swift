import SwiftUI

@main
struct NicksCookbookApp: App {
    @StateObject private var viewModel = RecipeViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
