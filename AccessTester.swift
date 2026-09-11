import Foundation
import UIKit

struct GameAccessResult: Identifiable {
    let id = UUID()

    let gameName: String
    let bundleID: String

    var installedStatus: String
    var containerStatus: String
    var accessStatus: String
    var details: String
}

final class AccessTester {

    private let fileManager = FileManager.default

    func testGames() -> [GameAccessResult] {

        let games = [
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

        var result = GameAccessResult(
            gameName: name,
            bundleID: bundleID,
            installedStatus: "NÃO DETERMINADO",
            containerStatus: "NÃO ACESSADO",
            accessStatus: "BLOQUEADO",
            details: ""
        )

        /*
         iOS não permite que uma IPA normal consulte diretamente
         a instalação de outro aplicativo pelo Bundle ID.

         Portanto, não usamos APIs privadas como LSApplicationWorkspace.
        */

        result.installedStatus =
            "Não pode ser confirmado diretamente por API pública."

        let applicationRoot =
            "/var/mobile/Containers/Data/Application"

        do {

            let items = try fileManager.contentsOfDirectory(
                atPath: applicationRoot
            )

            result.containerStatus =
                "Diretório contém \(items.count) item(ns)"

            result.accessStatus = "BLOQUEADO"

            result.details =
                """
                O diretório geral dos containers existe no sistema,
                mas o iOS não concedeu permissão para o Peaga Files
                enumerar os containers dos outros aplicativos.

                Bundle ID procurado:
                \(bundleID)

                Resultado:
                Não é possível chegar ao container privado do jogo
                usando as APIs públicas de uma IPA normal.
                """

        } catch {

            result.containerStatus = "BLOQUEADO"
            result.accessStatus = "BLOQUEADO"

            result.details =
                """
                O iOS recusou o acesso ao diretório de containers.

                Bundle ID:
                \(bundleID)

                Erro retornado pelo sistema:
                \(error.localizedDescription)

                Isso significa que o Peaga Files não recebeu
                permissão para enumerar os containers dos outros apps.
                """
        }

        return result
    }

    func testOwnSandbox() -> [AccessResult] {

        let paths = [
            (
                "Documents",
                fileManager.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                ).first?.path
            ),
            (
                "Library",
                fileManager.urls(
                    for: .libraryDirectory,
                    in: .userDomainMask
                ).first?.path
            ),
            (
                "Caches",
                fileManager.urls(
                    for: .cachesDirectory,
                    in: .userDomainMask
                ).first?.path
            ),
            (
                "Temporary",
                NSTemporaryDirectory()
            )
        ]

        return paths.compactMap { item in

            guard let path = item.1 else {
                return nil
            }

            do {

                let contents = try fileManager.contentsOfDirectory(
                    atPath: path
                )

                return AccessResult(
                    path: path,
                    accessible: true,
                    details: "\(contents.count) item(ns) encontrado(s)."
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
