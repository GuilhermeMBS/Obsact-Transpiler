# ObsAct Transpiler 🚀

A compiler pipeline built with **Flex** (Lexical Scanner) and **Bison** (Syntactical Parser) designed to compile and transpile the **ObsAct** domain-specific language (DSL) into standard C source code. 

The project features semantic memory validation, strict token boundary constraints, a decentralized modular C runtime architecture, and full automation via GNU Make.

---

## 📁 Repository Structure

```text
├── src/
│   ├── lexical/
│   │   └── lexical.l       # Flex lexical rules & max-length protection
│   ├── syntax/
│   │   └── syntax.y        # Bison grammar architecture & semantic validation
│   ├── includes/
│   │   ├── obsact_func.h   # Public API Runtime C headers (Doxygen documented)
│   │   └── aux_func.h      # Private State Manager C headers (Doxygen documented)
│   └── functions/
│       ├── obsact_func.c   # Support actions implementation (ligar/desligar/etc)
│       └── aux_func.c      # Persistence engine & runtime state tracker
├── tests/
│   ├── examples/           # Standard test files from SRS
│   └── our_tests/          # Custom edge-case test files
├── Makefile                # Cross-platform compilation automation scripts
├── makefile_guide.md       # Guide with Makefile commands
├── docs/
│   ├── SRS_PT.pdf         # Software Requirements Specification in Portuguese
│   ├── specifications.md   # Language specification
│   └── grammar_flow.md     # Architectural specification of the grammar
└── README.md               # Main repository documentation
```

## ⚙️ Key Architectural Features
- **Semantic Data Integrity:** Features on-the-fly character validation. While identifiers are extracted alphanumerically, device names (`namedevice`) containing digits are blocked at the compilation level (`YYABORT`).

- **Decoupled C Runtime Engine:** Built under the Separation of Concerns pattern. Device persistent tracking (up to 50 active items) is handled by a private state manager (`aux_func.c`), keeping the public engine completely lightweight.

- **String Protections:** Hard bounds of a maximum of 100 characters for message literals (`msg`) and variable identifiers are natively evaluated within the Lexer rules.

## 🚀 Getting Started
### Prerequisites
Ensure you have a C compiler (GCC) and the Windows port of Flex/Bison (`win_flex`, `win_bison`) configured in your System Environment Variables path.

### 1. Build the Transpiler Binary
Generate the compiler components and build the executable parser:

```Bash
mingw32-make all
```
### 2. Clean Generated Artifacts
Wipe out compiled binaries, generated scanner/parser C objects, and test output files:

```Bash
mingw32-make clean
```
## 🧪 Testing and Debugging Pipeline
This workflow includes highly automated testing routines via PowerShell scripts embedded in the Makefile:

### Transpile All Test Cases
Generates the output `.c` source files inside the `out/` directory for both example and custom suites:

```Bash
mingw32-make tests
```
### Execute Transpiled Binaries
Compiles the generated C artifacts together with the modular hardware runtime engine and prints execution results:

```Bash
mingw32-make run-tests
```
### Single File Rapid Debugging
To transpile and immediately execute an individual `.obsact` source on the fly:

```Bash
mingw32-make test-single FILE=tests/our_tests/test_complex_logic.obsact
```
To re-run a previously generated C target script:

```Bash
mingw32-make run-single FILE=out/our_tests/test_complex_logic.c
```
## 📝 Language Syntax Quick Reference
An instance of an ObsAct application must define components before firing commands:

```Plaintext
dispositivo : { Termometro , temperatura }
dispositivo : { MotorJanela }

set temperatura = 32 .

se temperatura >= 30 entao
    ligar MotorJanela .

enviar alerta ("Critical climate triggered") para todos: Termometro, MotorJanela .
```
