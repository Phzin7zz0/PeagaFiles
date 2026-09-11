import SwiftUI

struct ContentView: View {

    @State private var games: [GameAccessResult] = []
    @State private var ownSandbox: [AccessResult] = []
    @State private var systemPaths: [AccessResult] = []

    @State private var testing = false

    var body: some View {

        NavigationStack {

            ScrollView {

                VStack(spacing: 20) {

                    Image(
                        systemName: "folder.badge.questionmark"
                    )
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                    .padding(.top, 20)

                    Text("Peaga Files")
                        .font(.largeTitle.bold())

                    Text("Advanced Access Test")
                        .font(.title3)
                        .foregroundStyle(.secondary)

                    Text(
                        "Diagnóstico de acesso ao Free Fire e Free Fire MAX"
                    )
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                    Button {
                        runTest()
                    } label: {

                        HStack {

                            if testing {
                                ProgressView()
                            } else {
                                Image(
                                    systemName: "magnifyingglass"
                                )
                            }

                            Text(
                                testing
                                ? "Testando..."
                                : "Testar acesso"
                            )
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(testing)

                    if !games.isEmpty {

                        sectionTitle(
                            "Free Fire / Free Fire MAX"
                        )

                        ForEach(games) { game in
                            gameCard(game)
                        }
                    }

                    if !systemPaths.isEmpty {

                        sectionTitle(
                            "Containers do sistema"
                        )

                        ForEach(systemPaths) { result in
                            accessCard(result)
                        }
                    }

                    if !ownSandbox.isEmpty {

                        sectionTitle(
                            "Sandbox do Peaga Files"
                        )

                        ForEach(ownSandbox) { result in
                            accessCard(result)
                        }
                    }

                    if !games.isEmpty {

                        VStack(
                            alignment: .leading,
                            spacing: 10
                        ) {

                            Text("Conclusão")
                                .font(.headline)

                            Text(conclusionText)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding()
                        .background(
                            Color.secondary.opacity(0.12)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 16
                            )
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Access Test")
        }
    }

    private func sectionTitle(
        _ title: String
    ) -> some View {

        HStack {

            Text(title)
                .font(.headline)

            Spacer()
        }
        .padding(.top, 10)
    }

    private func gameCard(
        _ game: GameAccessResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 12
        ) {

            HStack {

                Image(
                    systemName:
                        game.accessStatus == "ACESSÍVEL"
                        ? "checkmark.circle.fill"
                        : "xmark.circle.fill"
                )
                .foregroundStyle(
                    game.accessStatus == "ACESSÍVEL"
                    ? .green
                    : .red
                )

                Text(game.gameName)
                    .font(.headline)

                Spacer()
            }

            Divider()

            infoRow(
                title: "Bundle ID",
                value: game.bundleID
            )

            infoRow(
                title: "Instalação",
                value: game.installedStatus
            )

            infoRow(
                title: "Container",
                value: game.containerStatus
            )

            infoRow(
                title: "Acesso",
                value: game.accessStatus
            )

            Text(game.details)
                .font(.caption)
                .foregroundStyle(.secondary)
                .textSelection(.enabled)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(
            Color.secondary.opacity(0.12)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 16
            )
        )
    }

    private func accessCard(
        _ result: AccessResult
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 8
        ) {

            HStack {

                Image(
                    systemName:
                        result.accessible
                        ? "checkmark.circle.fill"
                        : "xmark.circle.fill"
                )
                .foregroundStyle(
                    result.accessible
                    ? .green
                    : .red
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
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding()
        .background(
            Color.secondary.opacity(0.08)
        )
        .clipShape(
            RoundedRectangle(
                cornerRadius: 14
            )
        )
    }

    private func infoRow(
        title: String,
        value: String
    ) -> some View {

        VStack(
            alignment: .leading,
            spacing: 3
        ) {

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .textSelection(.enabled)
        }
    }

    private var conclusionText: String {

        let allBlocked = games.allSatisfy {
            $0.accessStatus == "BLOQUEADO"
        }

        if allBlocked {

            return """
            Os containers privados dos jogos continuam inacessíveis.
            O motivo é o isolamento entre aplicativos imposto pelo
            sandbox do iOS.
            """
        }

        return """
        Algum caminho retornou um resultado diferente.
        O próximo passo é analisar exatamente qual diretório foi acessível.
        """
    }

    private func runTest() {

        testing = true

        DispatchQueue.global(
            qos: .userInitiated
        ).async {

            let tester = AccessTester()

            let gameResults =
                tester.testGames()

            let systemResults =
                tester.testKnownContainerPaths()

            let ownResults =
                tester.testOwnSandbox()

            DispatchQueue.main.async {

                games = gameResults
                systemPaths = systemResults
                ownSandbox = ownResults

                testing = false
            }
        }
    }
}
