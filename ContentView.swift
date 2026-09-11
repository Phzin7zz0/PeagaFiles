import SwiftUI

struct ContentView: View {

    @State private var results: [AccessResult] = []
    @State private var testing = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {

                Image(systemName: "folder.badge.questionmark")
                    .font(.system(size: 55))
                    .foregroundStyle(.blue)

                Text("Peaga Files")
                    .font(.largeTitle.bold())

                Text("Teste de acesso ao Free Fire / Free Fire MAX")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Button {
                    runTest()
                } label: {
                    HStack {
                        if testing {
                            ProgressView()
                        } else {
                            Image(systemName: "magnifyingglass")
                        }

                        Text(testing ? "Testando..." : "Testar acesso")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .buttonStyle(.borderedProminent)
                .disabled(testing)

                if results.isEmpty {
                    Spacer()

                    Text("Nenhum teste realizado.")
                        .foregroundStyle(.secondary)

                    Spacer()
                } else {
                    List(results) { result in
                        VStack(alignment: .leading, spacing: 6) {

                            HStack {
                                Image(
                                    systemName: result.accessible
                                    ? "checkmark.circle.fill"
                                    : "xmark.circle.fill"
                                )
                                .foregroundStyle(
                                    result.accessible ? .green : .red
                                )

                                Text(
                                    result.accessible
                                    ? "ACESSÍVEL"
                                    : "BLOQUEADO"
                                )
                                .font(.headline)
                            }

                            Text(result.path)
                                .font(.caption)
                                .textSelection(.enabled)

                            Text(result.details)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(.plain)
                }
            }
            .padding()
            .navigationTitle("Access Test")
        }
    }

    private func runTest() {
        testing = true
        results = []

        DispatchQueue.global(qos: .userInitiated).async {
            let tester = AccessTester()
            let newResults = tester.testAccess()

            DispatchQueue.main.async {
                results = newResults
                testing = false
            }
        }
    }
}
