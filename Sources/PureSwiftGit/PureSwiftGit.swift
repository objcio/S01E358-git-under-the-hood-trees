import Foundation

public struct TreeItem: Hashable {
    var mode: String
    var name: String
    var hash: String
}

public enum Object: Hashable {
    case blob(Data)
    case commit
    case tree([TreeItem])
}

extension Data {
    mutating func parseTreeItems() throws -> [TreeItem] {
        var result: [TreeItem] = []
        while !isEmpty {
            try result.append(parseTreeItem())
        }
        return result
    }

    mutating func parseTreeItem() throws -> TreeItem {
        let mode = String(decoding: remove(upTo: 0x20), as: UTF8.self)
        let name = String(decoding: remove(upTo: 0), as: UTF8.self)
        let hashData = prefix(20)
        removeFirst(20)
        let hash = hashData.map { byte in
            let result = String(byte, radix: 16)
            return result.count == 1 ? "0\(result)" : result
        }.joined()
        return TreeItem(mode: mode, name: name, hash: hash)
    }
}

public struct Repository {
    var url: URL
    init(_ url: URL) {
        self.url = url
    }

    var gitURL: URL {
        url.appendingPathComponent(".git")
    }

    func readObject(_ hash: String) throws -> Object {
        // todo verify that this is an actual hash
        let objectPath = "\(hash.prefix(2))/\(hash.dropFirst(2))"
        let data = try Data(contentsOf: gitURL.appendingPathComponent("objects/\(objectPath)")).decompressed
        var remainder = data
        let typeStr = String(decoding: remainder.remove(upTo: 0x20), as: UTF8.self)
        remainder.remove(upTo: 0)
        switch typeStr {
        case "blob": return .blob(remainder)
        case "tree": return try .tree(remainder.parseTreeItems())
        default: fatalError()
        }
    }
}

extension Data {
    @discardableResult
    mutating func remove(upTo separator: Element) -> Data {
        let part = prefix(while: { $0 != separator })
        removeFirst(part.count)
        _ = popFirst()
        return part
    }
}
