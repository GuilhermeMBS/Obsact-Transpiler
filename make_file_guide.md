# Makefile Automation Guide

This guide details how to use the automated testing and execution suite provided by the `Makefile`. The workspace is optimized for Windows environments running via PowerShell within a MinGW toolchain.

---

## 🚀 Core Targets

### 1. Build and Cleanup

* **Build the Transpiler:**
```bash
mingw32-make all
```

Generates the parser and scanner files (`syntax.tab.c`, `lex.yy.c`) and builds the main `transpiler` executable.

- Clean the Workspace:

```bash
mingw32-make clean
```
Deletes the main executable, core intermediate files, and purges all generated `.c` and `.exe` artifacts inside the `out/` folders, leaving the directory structure intact.

## 🧪 Testing Suites
The architecture separates the input suites into two independent output target folders under `out/` to ensure clean, readable logs.

### 2. Transpilation Stage (ObsAct -> C)
These commands parse your source .obsact code and generate valid C files inside the out/ directory structure. **If a file contains syntax errors, the transpilator aborts and prevents the corrupted C file from being generated.**

- Transpile Every Available Test Case:

```Bash
mingw32-make tests
```
Runs both the professor's examples and your custom tests sequentially.

- Transpile PDF Examples Only:

```Bash
mingw32-make test-examples
```
Processes all `.obsact` files from `tests/examples/` into `out/examples/`.

- Transpile Custom Test Cases Only:

```Bash
mingw32-make test-ours
```
Processes all `.obsact` files from `tests/our_tests/` into `out/our_tests/`.

### 3. Native Execution Stage (C -> Binary Output)
These targets capture the valid `.c` files produced by successful transpiles, compile them via `gcc` with all code emissions and unused variable warnings safely muted (`-w`), and execute them sequentially in your console.

- Compile and Execute Every Valid C File:

```Bash
mingw32-make run-tests
```

- Run Transpiled PDF Examples Only:

```Bash
mingw32-make run-examples
```

- Run Transpiled Custom Tests Only:

```Bash
mingw32-make run-ours
```

## 🔍 Single File Rapid Debugging
To test or debug a specific `.obsact` file without triggering the entire suite automation loop, use the `test-single` macro. This target **transpiles, compiles the native C code, and boots the binary executable** in a single seamless pipeline:

```Bash
mingw32-make test-single FILE=tests/our_tests/test_broadcast.obsact
```

### Executing a Single Generated C File

If you have already transpiled your code and just want to re-compile and execute a specific `.c` file (useful for testing C runtime behavior or debugging the state manager), use the `run-single` macro:

```bash
mingw32-make run-single FILE=out/our_tests/test_complex_logic.c
```

⚠️ **Note:** Always pass the correct relative path to the FILE macro when executing test-single.