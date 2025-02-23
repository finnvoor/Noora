---
title: Text Styling
titleTemplate: ":title · Noora · Tuist"
description: Style terminal output with semantic formatting using TerminalText.
---

# Text Styling

`TerminalText` enables semantic text formatting in terminal output. It adapts to terminal capabilities and themes while maintaining readability.

## API

### Components

| Component | Description |
| --- | --- |
| `.raw(String)` | Text without special formatting |
| `.command(String)` | System commands (e.g. 'tuist generate') |
| `.primary(String)` | Text in theme's primary color |
| `.secondary(String)` | Text in theme's secondary color |
| `.muted(String)` | Text in theme's muted color |
| `.accent(String)` | Text in theme's accent color |
| `.danger(String)` | Text in theme's danger color |
| `.success(String)` | Text in theme's success color |

### Usage

Create styled text using string interpolation:

```swift
let text: TerminalText = """
Regular text and \(.command("commands"))
with \(.primary("primary")) and \(.secondary("secondary")) colors
"""

// Format the text for output
let noora = Noora()
let formattedText = noora.format(text)
```

## Examples

### Command Instructions

```swift
let instruction: TerminalText = "Run \(.command("tuist init")) to create a project"
```

### Status Messages

```swift
// Success
let success: TerminalText = "\(.success("✓")) Project \(.primary("MyApp")) created"

// Error
let error: TerminalText = "\(.danger("✗")) \(.command("generate")) failed"

// Prompt
let prompt: TerminalText = "Enter \(.accent("project name")): "
```