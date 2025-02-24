import Foundation
import Rainbow

struct YesOrNoChoicePrompt {
    // MARK: - Attributes

    let title: TerminalText?
    let question: TerminalText
    let description: TerminalText?
    let theme: Theme
    let terminal: Terminaling
    let collapseOnSelection: Bool
    let renderer: Rendering
    let standardPipelines: StandardPipelines
    let keyStrokeListener: KeyStrokeListening
    let defaultAnswer: Bool

    func run() -> Bool {
        if !terminal.isInteractive {
            fatalError("'\(question)' can't be prompted in a non-interactive session.")
        }

        var answer: Bool = defaultAnswer
        var buttonRow: Int?
        var yesRange: Range<Int>?
        var noRange: Range<Int>?

        terminal.inRawMode {
            renderOptions(answer: answer, buttonRow: &buttonRow, yesRange: &yesRange, noRange: &noRange)
            keyStrokeListener.listen(terminal: terminal) { keyStroke in
                switch keyStroke {
                case let .leftMouseDown(position):
                    // Check if click is within button bounds
                    if let row = buttonRow, let yes = yesRange, position.row == row, yes.contains(position.column) {
                        answer = true
                        return .abort
                    }
                    if let row = buttonRow, let no = noRange, position.row == row, no.contains(position.column) {
                        answer = false
                        return .abort
                    }
                    return .continue
                case let .printable(character) where character == "y":
                    answer = true
                    return .abort
                case let .printable(character) where character == "n":
                    answer = false
                    return .abort
                case let .printable(character) where character == "l":
                    fallthrough
                case let .printable(character) where character == "h":
                    fallthrough
                case .leftArrowKey, .rightArrowKey:
                    answer = !answer
                    renderOptions(answer: answer, buttonRow: &buttonRow, yesRange: &yesRange, noRange: &noRange)
                    return .continue
                case let .printable(character) where character.isNewline:
                    return .abort
                default:
                    return .continue
                }
            }
        }

        if collapseOnSelection {
            renderResult(answer: answer)
        }

        return answer
    }

    // MARK: - Private

    private func renderResult(answer: Bool) {
        var content = if let title {
            "\(title.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        } else {
            "\(question.formatted(theme: theme, terminal: terminal)):".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }
        content += " \(answer ? "Yes" : "No")"

        renderer.render(
            ProgressStep.completionMessage(content, theme: theme, terminal: terminal),
            standardPipeline: standardPipelines.output
        )
    }

    private func renderOptions(answer: Bool, buttonRow: inout Int?, yesRange: inout Range<Int>?, noRange: inout Range<Int>?) {
        var content = ""
        if let title {
            content = "◉ \(title.formatted(theme: theme, terminal: terminal))".hexIfColoredTerminal(theme.primary, terminal)
                .boldIfColoredTerminal(terminal)
        }

        content += "\n"

        let formattedQuestion = "  \(question.formatted(theme: theme, terminal: terminal)) "
        content += formattedQuestion

        let yes = if answer {
            if terminal.isColored {
                " Yes (y) ".onHex(theme.muted)
            } else {
                "[ Yes (y) ]"
            }
        } else {
            " Yes (y) "
        }

        let no = if answer {
            " No (n) "
        } else {
            if terminal.isColored {
                " No (n) ".onHex(theme.muted)
            } else {
                "[ No (n) ]"
            }
        }

        content += "\(yes) / \(no)"

        if let description {
            content +=
                "\n  \(description.formatted(theme: theme, terminal: terminal).hexIfColoredTerminal(theme.muted, terminal))"
        }
        content += "\n  \("←/→/h/l left/right • enter confirm".hexIfColoredTerminal(theme.muted, terminal))"

        renderer.render(content, standardPipeline: standardPipelines.output)

        // Get final cursor position and calculate button positions relative to that
        let finalPos = terminal.cursorPosition()
        buttonRow = finalPos.row - 2
        let startColumn = formattedQuestion.raw.count + 1
        yesRange = startColumn ..< (startColumn + yes.raw.count)
        noRange = (startColumn + yes.raw.count + 3) ..< (startColumn + yes.raw.count + 3 + no.raw.count) // +3 for " / "
    }
}
