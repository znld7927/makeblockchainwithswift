struct makeblockchainwithswift {
    var text = "Hello, World!"
}

import Foundation

class Block {

    var index :Int = 0
    var dateCreated :String
    var previousHash :String!
    var hash :String!
    var nonce :Int
    var data :String

    var key :String {
        get {
            return String(self.index)
                + self.dateCreated
                + self.previousHash
                + self.data
                + String(self.nonce)
        }
    }

    init(data :String) {
        self.dateCreated = Date().toString()
        self.nonce = 0
        self.data = data
    }

}

// Date -> String 변환시켜주기 위한 Extension
extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: self)
    }
}


class Blockchain {

    private (set) var blocks :[Block] = [Block]()

    init(_ genesisBlock :Block) {

        addBlock(genesisBlock)
    }

    func addBlock(_ block :Block) {

        if self.blocks.isEmpty {
            // 제네시스 블록 추가하기
            // 첫 블록앞에는 블럭이 없다.
            block.previousHash = "0"
            block.hash = generateHash(for: block)
        } else {
            let previousBlock = getPreviousBlock()
            block.previousHash = previousBlock.hash
            block.index = self.blocks.count
            block.hash = generateHash(for: block)
        }

        self.blocks.append(block)
        displayBlock(block)
    }

    private func getPreviousBlock() -> Block {
        return self.blocks[self.blocks.count - 1]
    }

    private func displayBlock(_ block :Block) {
        print("------ Block \(block.index) ---------")
        print("Date Created : \(block.dateCreated) ")
        print("Data : \(block.data) ")
        print("Nonce : \(block.nonce) ")
        print("Previous Hash : \(block.previousHash!) ")
        print("Hash : \(block.hash!) ")

    }

    private func generateHash(for block: Block) -> String {

        var hash = block.key.sha1Hash()

        // 작업증명 세팅
        // "00" 으로 시작하는 것이 좋다. "0000" 으로 시작하면 너무 오래걸려서 플레이그라운드 크래시가 발생한다.
        while(!hash.hasPrefix("00")) {
            block.nonce += 1
            hash = block.key.sha1Hash()
//            print(hash)
        }

        return hash
    }

}

// sha1Hash 구현
extension String {

    func sha1Hash() -> String {

        let task = Process()
        task.launchPath = "/usr/bin/shasum"
        task.arguments = []

        let inputPipe = Pipe()

        inputPipe.fileHandleForWriting.write(self.data(using: String.Encoding.utf8)!)

        inputPipe.fileHandleForWriting.closeFile()

        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardInput = inputPipe
        task.launch()

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let hash = String(data: data, encoding: String.Encoding.utf8)!
        return hash.replacingOccurrences(of: "  -\n", with: "")
    }
}

let genesisBlock = Block(data: "genesis")
let blockChain = Blockchain(genesisBlock)

for index in 1...5 {
    let block = Block(data: "\(index)")
    blockChain.addBlock(block)
}

