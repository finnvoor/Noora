import Noora

class MockTerminal: Terminaling {
    var isInteractive: Bool = true
    var isColored: Bool = true
    var size: TerminalSize? = nil
    private var currentRow: Int = 1
    private var currentColumn: Int = 1

    init(
        isInteractive: Bool = true,
        isColored: Bool = true,
        size: TerminalSize? = nil
    ) {
        self.isInteractive = isInteractive
        self.isColored = isColored
        self.size = size
    }

    func inRawMode(_ body: @escaping () throws -> Void) rethrows {
        try body()
    }

    func withoutCursor(_ body: () throws -> Void) rethrows {
        try body()
    }

    func withMouseTracking(_ body: () throws -> Void) rethrows {
        try body()
    }

    var characters: [Character] = []
    func readCharacter() -> Character? {
        characters.removeFirst()
    }

    func readCharacterNonBlocking() -> Character? {
        nil
    }

    func cursorPosition() -> TerminalPosition {
        TerminalPosition(row: currentRow, column: currentColumn)
    }

    // For tests to set cursor position
    func setCursor(row: Int, column: Int) {
        currentRow = row
        currentColumn = column
    }
}
