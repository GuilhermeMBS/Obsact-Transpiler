# ObsAct Language Specification 📝

This document provides a structured specification of the **ObsAct** language, an automation and IoT domain-specific language. It catalogs the vocabulary (terminals), syntactic structures (non-terminals), structural production rules, runtime engine functions, and compiler assumptions based on the implemented Flex/Bison architecture.

---

## 1. Vocabulary & Alphabet

### 1.1 Terminal Symbols (Tokens)
Terminal symbols are the atomic units of the language captured by the lexical analyzer.

| Token / Pattern | Classification | Description | Restrictions / Requirements |
| :--- | :--- | :--- | :--- |
| `"dispositivo"` | Keyword | Device declaration prefix | Must be written exactly as specified. |
| `"set"` | Keyword | Variable assignment prefix | Must be written exactly as specified. |
| `"se"` | Keyword | Conditional block opening | Introduces a logical evaluation. |
| `"entao"` | Keyword | Conditional true-block | Executes trailing commands if condition is true. |
| `"senao"` | Keyword | Conditional false-block | Executes trailing commands if condition is false. |
| `"enviar alerta"` | Keyword | Diagnostic notification | Triggers system alert routines. |
| `"para todos"`| Keyword | Multi-device broadcast | Triggers broadcast alert sequencing. |
| `">"`, `"<"`, `">="`, `"<="`, `"=="`, `"!="` | Operator (`oplogic`) | Relational operators | Used strictly within logical sub-expressions. |
| `"&&"` | Operator | Logical AND connector | Evaluates conjunction between `OBS` blocks. |
| `"="` | Operator | Assignment operator | Binds a value or return status to an identifier. |
| `"."` | Punctuation | Command terminator | Marks the explicit end of `ATTRIB` and `ACT` statements. |
| `":"` | Punctuation | Directive delimiter | Used after `dispositivo` and `para todos`. Allows preceding spaces. |
| `","` | Punctuation | Element separator | Separates parameters and broadcast lists. |
| `"{"`, `"}"` | Punctuation | Scope brackets | Encloses device contextual parameters. |
| `[a-zA-Z]+` | Identifier (`namedevice`) | Device identifier | **Semantically Enforced:** Letters only. Max 100 characters. |
| `[a-zA-Z][a-zA-Z0-9]*` | Identifier (`observation`) | Sensor/Variable identifier | Alphanumeric starting with a letter. Max 100 characters. |
| `[0-9]+` | Literal (`num`) | Numeric value | Must represent a non-negative integer. |
| `TRUE`, `FALSE` | Literal (`bool`) | Boolean constant | Case-insensitive logical boolean value (`true`/`TRUE`). |
| `"([^"\\]|\\.)*"` | Literal (`msg`) | String literal | Text bounded by double quotes. Max 100 characters. |

---

## 2. Syntax & Grammar Rules

### 2.1 Non-Terminal Symbols
Symbols representing structural components resolved by the syntactical parser.

* `PROGRAM`: The root structural entry point of the source file.
* `DEVICES`: A sequence listing one or multiple hardware declarations.
* `DEVICE`: An individual device structural initialization.
* `WITH_OBS`: An optional suffix resolving to a comma followed by a sensor identifier (or empty).
* `CMDS`: A structural block containing executable instructions.
* `CMD`: An individual statement mapped to structural logic.
* `ATTRIB`: An assignment operation affecting system variables.
* `OBSACT`: A conditional logical control structure.
* `OBS`: A relational boolean expression or combination of expressions.
* `EXP`: An expression resolving to a value or a device action.
* `VALUE`: A placeholder resolving to numeric or boolean primitives.
* `ACT`: An action macro translating to system functions or hardware toggles.
* `ACTEXECUTE`: Core hardware instructions mapping to runtime toggles.
* `ACTALERT`: An active call forwarding diagnostic notifications.
* `DEVICE_LIST`: A recursive comma-separated sequence of target devices.
* `ACTION`: Terminal operations (`ligar`, `desligar`, `verificar`).

### 2.2 Context-Free Grammar Production Rules
The following table transcribes the exact production rules defined in the Bison engine. The symbol **ε** represents an empty (epsilon) transition.

| Non-Terminal | Production Rules | Semantic Intent / Context |
| :--- | :--- | :--- |
| **PROGRAM** | `→ DEVICES CMDS` <br> `\| DEVICES CMDS .` | Valid file needs device declarations followed by commands. Optionally absorbs a trailing file period. |
| **DEVICES** | `→ DEVICES DEVICE`<br><code>\| DEVICE</code> | Handles recursive list generation for system components. |
| **DEVICE** | `→ dispositivo : { namedevice WITH_OBS }` | Registers a device. Sensor binding is handled by the optional suffix. |
| **WITH_OBS** | `→ , observation`<br><code>\| `ε`</code> | Factored rule to absorb optional sensor bindings or alert variables safely. |
| **CMDS** | `→ CMDS CMD`<br><code>\| `CMD`</code> | A recursive list of executable actions. |
| **CMD** | `→ ATTRIB .`<br><code>\| `ACT .`<br><code>\| `OBSACT`</code> | Statement wrapper. Enforces the terminal `.` for assignments and actions, but explicitly excludes it for conditionals. |
| **ATTRIB** | `→ set observation = EXP` | Sets standard variables or saves device query status. |
| **EXP** | `→ VALUE`<br><code>\| `ACTEXECUTE`</code> | Evaluates standard primitives or queries a device. |
| **VALUE** | `→ num`<br><code>\| `bool`</code> | Resolves primitives to standard strings/integers. |
| **OBSACT** | `→ se OBS entao CMD`<br><code>\| `se OBS entao CMD senao CMD`</code> | Maps conditional blocks. Note: The block scope is terminated by the internal `CMD`'s period. |
| **OBS** | `→ observation oplogic VALUE`<br><code>\| `OBS && OBS`</code> | Evaluates active state matching and chains logical expressions. |
| **ACT** | `→ ACTEXECUTE`<br><code>\| `ACTALERT`</code> | Evaluates direct device actuation or string alerts. |
| **ACTEXECUTE** | `→ ACTION namedevice` | Executes `ligar`, `desligar` or `verificar` on a specific device. |
| **ACTALERT** | `→ enviar alerta ( msg WITH_OBS ) namedevice`<br><code>\| `enviar alerta ( msg WITH_OBS ) para todos : DEVICE_LIST` | Triggers targeted standard notifications or multi-device broadcasts. Resolves variables via `WITH_OBS`. |
| **DEVICE_LIST** | `→ namedevice`<br><code>\| `DEVICE_LIST , namedevice` | Builds the target list for broadcast macros. |
| **ACTION** | `→ ligar`<br><code>\| `desligar`<br><code>\| `verificar` | Hardware commands mapped to identifiers. |

---

## 3. Core Constraints & Compiler Assumptions

### 3.1 Type System & Content Bounds
* **Numerical Constraints:** All numerical variables handle non-negative integers only (`unsigned int`).
* **Memory Protections:** `msg` literals, `namedevice`, and `observation` identifiers are strictly bounded to a maximum length of **100 characters** enforced by the Lexical Scanner.
* **Semantic Validation:** While identifiers are lexically matched as alphanumeric, the parser engine semantically blocks the compilation (`YYABORT`) if a `namedevice` contains numerical digits.

### 3.2 Semantic Rules & Initialization
* **Implicit Variable Initialization:** Any sensor identifier (`observation`) declared alongside a device must be implicitly initialized to zero (`0`) in the generated C target code.
* **Memory State Persistence:** The target environment tracks the ON/OFF state of devices persistently during runtime to ensure `verificar` accurately reflects historical commands.

---

## 4. Target C Runtime Environment

The transpiler relies on a modular, decoupled C runtime architecture divided into two modules: a **Private State Manager** and a **Public API**.

### 4.1 Private State Manager (`aux_func.h`)
Handles the hidden memory allocation, state tracking (up to 50 active devices), and hardware index matching safely without polluting the main output.
* `_get_device_index(namedevice)`
* `_update_device(namedevice, state)`
* `_get_device_state(namedevice)`

### 4.2 Public Command API (`obsact_func.h`)
Injected directly into the `output.c` artifact, delegating state changes to the private manager while providing the exact output structure required by the specification.

```c
#include <stdio.h>
#include "aux_func.h"

// Activates a target device state (Sets to 1)
int ligar(const char* namedevice);

// Deactivates a target device state (Sets to 0)
int desligar(const char* namedevice);

// Queries the operating state (1 or 0) and formats output
int verificar(const char* namedevice);

// Outputs a standard string notification alert to a specific device
void alerta_sem_var(const char* namedevice, const char* msg);

// Outputs a hybrid text/variable notification alert to a specific device
void alerta_com_var(const char* namedevice, const char* msg, int var);
```
