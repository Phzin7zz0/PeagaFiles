import Foundation

struct AccessResult: Identifiable {
    let id = UUID()
    let path: String
    let accessible: Bool
    let details: String
}

final class AccessTester {

    func testAccess() -> [AccessResult] {
        let paths = [
            "/var/mobile/Containers/Data/Application",
            "/var/containers/Bundle/Application",
            "/var/mobile/Containers/Shared/AppGroup",
            NSHomeDirectory(),
            FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first?.path ?? "",
            FileManager.default.urls(
                for: .libraryDirectory,
                in: .userDomainMask
            ).first?.path ?? "",
            FileManager.default.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            ).first?.path ?? ""
        ]

        return paths.map { test(path: $0) }
    }

    private func test(path: String) -> AccessResult {
        guard !path.isEmpty else {
            return AccessResult(
                path: "(caminho vazio)",
                accessible: false,
                details: "Caminho não disponível."
            )
        }

        let fileManager = FileManager.default

        do {
            let exists = fileManager.fileExists(atPath: path)

            guard exists else {
                return AccessResult(
                    path: path,
                    accessible: false,
                    details: "Não existe ou não está visível para o aplicativo."
                )
            }

            let contents = try fileManager.contentsOfDirectory(atPath: path)

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
