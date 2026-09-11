import Foundation

struct AccessResult: Identifiable {
    let id = UUID()
    let path: String
    let accessible: Bool
    let details: String
}

struct GameAccessResult: Identifiable {
    let id = UUID()

    let gameName: String
    let bundleID: String
    let installedStatus: String
    let containerStatus: String
    let accessStatus: String
    let details: String
}

final class AccessTester {

    private let fileManager = FileManager.default

    func testGames() -> [GameAccessResult] {

        let games: [(name: String, bundleID: String)] = [
            (
                name: "Free Fire",
                bundleID: "com.dts.freefireth"
            ),
            (
                name: "Free Fire MAX",
                bundleID: "com.dts.freefiremax"
            )
        ]

        return games.map { game in
            testGame(
                name: game.name,
                bundleID: game.bundleID
            )
        }
    }

    private func testGame(
        name: String,
        bundleID: String
    ) -> GameAccessResult {

        let applicationRoot =
            "/var/mobile/Containers/Data/Application"

        do {

            let items = try fileManager.contentsOfDirectory(
                atPath: applicationRoot
            )

            return GameAccessResult(
                gameName: name,
                bundleID: bundleID,
                installedStatus:
                    "Não pode ser confirmado diretamente por API pública.",
                containerStatus:
                    "Diretório enumerado: \(items.count) item(ns)",
                accessStatus: "BLOQUEADO",
                details:
                    """
                    O Peaga Files conseguiu acessar o diretório geral,
                    mas uma IPA normal não possui uma API pública para
                    relacionar containers privados de outros apps ao Bundle ID.

                    Bundle ID analisado:
                    \(bundleID)
                    """
            )

        } catch {

            return GameAccessResult(
                gameName: name,
                bundleID: bundleID,
                installedStatus:
                    "Não pode ser confirmado diretamente por API pública.",
                containerStatus: "BLOQUEADO",
                accessStatus: "BLOQUEADO",
                details:
                    """
                    O iOS recusou o acesso ao diretório geral de containers.

                    Bundle ID analisado:
                    \(bundleID)

                    Erro retornado:
                    \(error.localizedDescription)

                    O sandbox impede que uma IPA normal enumere os
                    containers privados de outros aplicativos.
                    """
            )
        }
    }

    func testOwnSandbox() -> [AccessResult] {

        let paths: [(name: String, path: String?)] = [
            (
                name: "Documents",
                path: fileManager.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                ).first?.path
            ),
            (
                name: "Library",
                path: fileManager.urls(
                    for: .libraryDirectory,
                    in: .userDomainMask
                ).first?.path
            ),
            (
                name: "Caches",
                path: fileManager.urls(
                    for: .cachesDirectory,
                    in: .userDomainMask
                ).first?.path
            ),
            (
                name: "Temporary",
                path: NSTemporaryDirectory()
            )
        ]

        return paths.compactMap { item in

            guard let path = item.path else {
                return nil
            }

            do {

                let contents = try fileManager.contentsOfDirectory(
                    atPath: path
                )

                return AccessResult(
                    path: "\(item.name): \(path)",
                    accessible: true,
                    details:
                        "\(contents.count) item(ns) encontrado(s)."
                )

            } catch {

                return AccessResult(
                    path: "\(item.name): \(path)",
                    accessible: false,
                    details: error.localizedDescription
                )
            }
        }
    }

    func testKnownContainerPaths() -> [AccessResult] {

        let paths = [
            "/var/mobile/Containers/Data/Application",
            "/var/containers/Bundle/Application",
            "/var/mobile/Containers/Shared/AppGroup"
        ]

        return paths.map { path in

            do {

                let contents = try fileManager.contentsOfDirectory(
                    atPath: path
                )

                return AccessResult(
                    path: path,
                    accessible: true,
                    details:
                        "O sistema retornou \(contents.count) item(ns)."
                )

            } catch {

                return AccessResult(
                    path: path,
                    accessible: false,
                    details: error.localizedDescription
                )
            }
        }
    }
}
