# Project Roadmap: ObsAct Transpiler 🗺️

This document outlines the step-by-step development plan to construct the compiler/transpiler for the **ObsAct** language, bridging the theoretical concepts of Lexical and Syntactical analysis with practical code generation.

---

## 🛠️ Phase 1: Lexical Expansion (The Vocabulary)
**Goal:** Teach the Flex scanner (`lexical.l`) to recognize every individual word, operator, and symbol defined in the grammar and specifications.

-  **Define Identifiers (`namedevice` and `observation`):** - `namedevice` can only contain letters.
  - `namesensor`/`observation` can contain letters and numbers but must start with a letter.
-  **Add Fixed Keywords:** - Control structures: `"se"`, `"entao"`, `"senao"`.
  - Action commands: `"set"`, `"ligar"`, `"desligar"`, `"verificar"`, `"enviar"`, `"alerta"`, `"para"`, `"todos"`.
-  **Add Operators and Structural Constants:**
  - Logical connectors: `"&&"`.
  - Relational operators (`oplogic`): `">"`, `"<"`, `">="`, `"<="`, `"=="`, `"!="`.
  - End of command marker: `"."`.
-  **Match Literal Values:**
  - Non-negative integers (`num`).
  - Boolean constants (`bool`): `"TRUE"`, `"FALSE"`.
  - String messages inside quotation marks (`msg`).

---

## 📐 Phase 2: Core Grammar & Parsing (The Structure)
**Goal:** Implement the Context-Free Grammar (CFG) from section 1.1 inside Bison (`syntax.y`) to validate syntax.

-  **Map Rules to Bison Syntax:** Transcribe the rules from the document (e.g., `PROGRAM → DEVICES CMDS`) using Bison colon and semicolon styling.
-  **Refactor and Fix Ambiguities:**
  - Remove potential conflicts (like Shift/Reduce or Reduce/Reduce conflicts caused by left recursion or un-factored rules).
  - Establish operator precedence for `&&` and logical evaluations.
-  **Implement the Optional Else Statement:** Properly map the structure `se OBS entao CMDS senao CMDS`.

---

## 📢 Phase 3: Grammar Extensions (The Custom Adjustments)
**Goal:** Adapt and complete the language grammar according to the direct requirements listed by the professors.

-  **Implement Broadcast Messaging:** Create or modify syntax rules to accept the syntax: `enviar alerta (msg) para todos: dev1, dev2, ...`.
  - This requires a recursive sub-rule to process an arbitrary list of comma-separated `namedevice` identifiers.

---

## 💻 Phase 4: Target Language Setup (The Runtime Engine)
**Goal:** Write the pre-defined target platform functions that execute actions on simulated smart home components.

-  **Create a Runtime Library File:** Write a standalone file in your chosen language (e.g., `runtime.py` if translating to Python) containing the native implementation of:
  - `ligar(namedevice)`
  - `desligar(namedevice)`
  - `verificar(namedevice)`
  - `alerta(namedevice, msg)`
  - `alerta(namedevice, msg, var)`
-  **Format Output Behaviour:** Match exact requirements such as string space concatenation for alerts: `msg + " " + observation`.

---

## 🖨️ Phase 5: Semantic Actions & Code Generation (The Translation)
**Goal:** Inject C code within Bison's matching blocks to output valid instructions into the target source file.

-  **Track Variable Initialization:** Implement logic to set undefined sensors (`observation`) implicitly to zero.
-  **Print Targets Dynamic Content:** Use `yytext` data forwarded via `yylval` attributes to write clean output instructions, capturing explicit device names and numbers.
-  **Assemble the Transpiled Output:** Ensure the transpiled output structure automatically includes or imports the `runtime` template code so the file is ready to execute out of the box.

---

## 🧪 Phase 6: Testing & Evaluation
**Goal:** Test your transpilador comprehensively to ensure robustness for your report submission.

-  **Execute PDF Examples:** Ensure all snippet cases provided in section 1.2 compile cleanly.
-  **Build Edge-Case Suites:** Create custom script suites evaluating wrong syntax (expecting parsing errors) and correct scripts with extreme configurations.
