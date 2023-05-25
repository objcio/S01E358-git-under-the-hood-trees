import XCTest
@testable import PureSwiftGit

let fileURL = URL(fileURLWithPath: #file)
let repoURL = fileURL.deletingLastPathComponent().appendingPathComponent("../../Fixtures/sample-repo")
let repo = Repository(repoURL)

final class PureSwiftGitTests: XCTestCase {
    func testReadBlob() throws {
        let obj = try repo.readObject("a5c19667710254f835085b99726e523457150e03")
        let expected = Object.blob("Hello, world\n".data(using: .utf8)!)
        XCTAssertEqual(obj, expected)
    }

    func testReadTree() throws {
        let obj = try repo.readObject("c1be61088247955e5bda5984cbc675b7bd2751db")
        let expected = Object.tree([
            TreeItem(mode: "100644", name: "my-file", hash: "a5c19667710254f835085b99726e523457150e03"),
            TreeItem(mode: "40000", name: "nested", hash: "75b335a08dfaa6fe96127d63e514a1ea488ec5be")
        ])
        XCTAssertEqual(obj, expected)
    }
}
