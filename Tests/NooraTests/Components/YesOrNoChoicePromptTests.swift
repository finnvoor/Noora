import Testing

@testable import Noora

struct YesOrNoChoicePromptTests {
    var subject: YesOrNoChoicePrompt!
    let keyStrokeListener = MockKeyStrokeListener()
    let renderer = MockRenderer()
    var terminal = MockTerminal(isColored: false)

    @Test func renders_the_right_content() throws {
        // Given
        let subject = YesOrNoChoicePrompt(
            title: "Authentication",
            question: "Would you like to authenticate?",
            description: nil,
            theme: Theme.test(),
            terminal: terminal,
            collapseOnSelection: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            defaultAnswer: true
        )
        keyStrokeListener.keyPressStub = [.rightArrowKey, .leftArrowKey]

        // When
        _ = subject.run()

        // Then

        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == """
        ◉ Authentication
          Would you like to authenticate? [ Yes (y) ] /  No (n) 
          ←/→/h/l left/right • enter confirm
        """)
        #expect(renders.popLast() == """
        ◉ Authentication
          Would you like to authenticate?  Yes (y)  / [ No (n) ]
          ←/→/h/l left/right • enter confirm
        """)
        #expect(renders.popLast() == """
        ◉ Authentication
          Would you like to authenticate? [ Yes (y) ] /  No (n) 
          ←/→/h/l left/right • enter confirm
        """)
        #expect(renders.popLast() == """
        ✔︎ Authentication: Yes 
        """)
    }

    @Test func clicking_buttons_selects_correct_option() throws {
        // Given
        let subject = YesOrNoChoicePrompt(
            title: "Integration",
            question: "Would you like to integrate Tuist?",
            description: "Decide if you want to integrate with your project",
            theme: Theme.test(),
            terminal: terminal,
            collapseOnSelection: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            defaultAnswer: false
        )

        // Test clicking Yes
        terminal.setCursor(row: 3, column: 1) // Set cursor position before test
        keyStrokeListener.keyPressStub = [.leftMouseDown(position: TerminalPosition(row: 1, column: 42))]
        var result = subject.run()
        #expect(result)
        var renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == """
        ◉ Integration
          Would you like to integrate Tuist?  Yes (y)  / [ No (n) ]
          Decide if you want to integrate with your project
          ←/→/h/l left/right • enter confirm
        """)
        #expect(renders.popLast() == "✔︎ Integration: Yes ")

        // Reset renderer for next test
        renderer.renders = []

        // Test clicking No
        terminal.setCursor(row: 3, column: 1) // Set cursor position before test
        let subject2 = YesOrNoChoicePrompt(
            title: "Integration",
            question: "Would you like to integrate Tuist?",
            description: "Decide if you want to integrate with your project",
            theme: Theme.test(),
            terminal: terminal,
            collapseOnSelection: true,
            renderer: renderer,
            standardPipelines: StandardPipelines(),
            keyStrokeListener: keyStrokeListener,
            defaultAnswer: true
        )
        keyStrokeListener.keyPressStub = [.leftMouseDown(position: TerminalPosition(row: 1, column: 52))]
        result = subject2.run()
        #expect(!result)
        renders = Array(renderer.renders.reversed())
        #expect(renders.popLast() == """
        ◉ Integration
          Would you like to integrate Tuist? [ Yes (y) ] /  No (n) 
          Decide if you want to integrate with your project
          ←/→/h/l left/right • enter confirm
        """)
        #expect(renders.popLast() == "✔︎ Integration: No ")
    }
}
