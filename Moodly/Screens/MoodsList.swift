import SwiftUI
import Combine
import SwiftUISnackbar

class MoodsListViewModel: ObservableObject {
    var snackbarStore: SnackbarStore
    let moodsRepository: MoodsRepositoryProtocol
    @Published var moods: [MoodEntry] = []
    @Published var isAdd: Bool = false

    private var cancelBag = Set<AnyCancellable>()

    init(
        snackbarStore: SnackbarStore,
        moodsRepository: MoodsRepositoryProtocol
    ) {
        self.snackbarStore = snackbarStore
        self.moodsRepository = moodsRepository

        self.moodsRepository.getMoods()
            .sink(
                receiveCompletion: {_ in},
                receiveValue: { moods in
                    self.moods = moods
                }
            )
            .store(in: &cancelBag)
    }
    
    var sortedMoods: [MoodEntry] {
        moods.sorted(by: { $0.createdAt > $1.createdAt })
    }

    func didTapAdd() {
        self.isAdd = true
    }
}

struct MoodsList: View {
    @StateObject var viewModel: MoodsListViewModel

    var body: some View {
        moodsList
            .navigationTitle("Your Moods")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: viewModel.didTapAdd) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.isAdd) {
                AddMood(viewModel: .init(
                    snackbarStore: viewModel.snackbarStore,
                    moodsRepository: viewModel.moodsRepository,
                    moods: $viewModel.moods,
                    modalOpen: $viewModel.isAdd
                ))
            }
    }

    private var moodsList: some View {
        List {
            if viewModel.moods.count == 0 {
                noMoodsButton
            } else {
                ForEach(viewModel.sortedMoods, id: \.self) { entry in
                    entryRow(entry)
                }
            }
        }
    }
    
    private var noMoodsButton: some View {
        Button(action: viewModel.didTapAdd) {
            HStack {
                Text("No moods yet")
                Spacer()
                Image(systemName: "plus")
                Text("add one")
            }
        }
    }

    private func entryRow(_ entry: MoodEntry) -> some View {
        HStack {
            Text(entry.mood.emojii)
                .font(.largeTitle)
            VStack(alignment: .leading) {
                Text(entry.createdAt.formatted())
                    .font(.caption)
                    .foregroundColor(.gray)
                if !entry.notes.isEmpty {
                    Text(entry.notes)
                }
            }
        }
    }
}

struct MoodsList_Previews: PreviewProvider {
    static var previews: some View {
        MoodsList(viewModel: .init(
            snackbarStore: SnackbarStore(),
            moodsRepository: FakeMoodsRepository()
        ))
    }
}
