import SwiftUI
import SwiftUISnackbar

struct ContentView: View {
    @StateObject var store = SnackbarStore()
    
    var body: some View {
        SnackbarNavigatior {
            MoodsList(viewModel: .init(
                snackbarStore: store,
                moodsRepository: MoodsRealmRepository()
            ))
        }
        .environmentObject(store)
    }
}

struct SnackbarNavigatior<Content: View>: View {
    @EnvironmentObject var store: SnackbarStore
    let content: Content
    
    init(
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
    }

    var body: some View {
        NavigationView {
            self.content
        }
        .snackbar(
            isShowing: $store.show,
            title: store.title,
            text: store.text,
            style: store.style,
            actionText: store.actionText,
            action: store.action
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
