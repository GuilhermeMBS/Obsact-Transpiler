# ObsAct Language Specification 📝

This document provides a structured specification of the **ObsAct** language, an automation and IoT domain-specific language. It catalogs the vocabulary (terminals), syntactic structures (non-terminals), structural production rules, runtime engine functions, and compiler assumptions.

---

## 1. Vocabulary & Alphabet

### 1.1 Terminal Symbols (Tokens)
Terminal symbols are the atomic units of the language captured by the lexical analyzer.

| Token / Pattern | Classification | Description | Restrictions / Requirements |
| :--- | :--- | :--- | :--- |
| `"dispositivo:"` | Keyword | Device declaration prefix | Must be written exactly as specified. |
| `"set"` | Keyword | Variable assignment prefix | Must be written exactly as specified. |
| `"se"` | Keyword | Conditional block opening | Introduces a logical evaluation. |
| `"entao"` | Keyword | Conditional true-block | Executes trailing commands if condition is true. |
| `"senao"` | Keyword | Conditional false-block | Executes trailing commands if condition is false. |
| `"enviar alerta"` | Keyword | Diagnostic notification | Triggers system alert routines. |
| `"para todos:"`| Keyword | Multi-device broadcast | Triggers broadcast alert sequencing. |
| `">"`, `"<"`, `">="`, `"<="`, `"=="`, `"!="` | Operator (`oplogic`) | Relational operators | Used strictly within logical sub-expressions. |
| `"&&"` | Operator | Logical AND connector | Evaluates conjunction between `OBS` blocks. |
| `"="` | Operator | Assignment operator | Binds a value or return status to an identifier. |
| `"."` | Punctuation | Command terminator | Marks the explicit end of `ATTRIB` and `OBSACT` statements. |
| `","` | Punctuation | Element separator | Separates parameter lists and device arrays. |
| `"{"`, `"}"` | Punctuation | Scope brackets | Encloses device contextual parameters. |
| `+` | Identifier (`namedevice`) | Device identifier | Must contain letters only; cannot be empty. |
| `*` | Identifier (`namesensor`/`observation`) | Sensor/Variable identifier | Must start with a letter, can include digits; cannot be empty. |
| `+` | Literal (`num`) | Numeric value | Must represent a non-negative integer. |
| `"TRUE"`, `"FALSE"` | Literal (`bool`) | Boolean constant | Case-sensitive logical boolean value. |
| `"(\|\\.)*"` | Literal (`msg`) | String literal | Text bounded by double quotes; cannot be empty. |

---

## 2. Syntax & Grammar Rules

### 2.1 Non-Terminal Symbols
Symbols representing structural components resolved by the syntactical parser.

* `PROGRAM`: The root structural entry point of the source file.
* `DEVICES`: A sequence listing one or multiple hardware declarations.
* `DEVICE`: An individual device structural initialization.
* `CMDS`: A structural block containing terminated executable instructions.
* `CMD`: An individual abstract statement mapped to structural logic.
* `ATTRIB`: An assignment operation affecting system variables.
* `OBSACT`: A conditional logical control structure.
* `OBS`: A relational boolean expression or combination of expressions.
* `VAR`: A placeholder resolving to numbers or booleans.
* `ACT`: An action macro translating to system functions or hardware toggles.
* `ACTEXECUTE`: A nested assignment fetching status from a target device.
* `ACTALERT`: An active call forwarding diagnostic notifications.
* `ACTION`: Core hardware instructions mapping to runtime toggles.

### 2.2 Context-Free Grammar Production Rules
The following table transcribes the production rules defined for the language engine:

| Non-Terminal | Production Rules | Semantic Intent / Context |
| :--- | :--- | :--- |
| **PROGRAM** | `→ DEVICES CMDS` | A valid file requires device declarations followed by commands. |
| **DEVICES** | `→ DEVICE DEVICES`<br><code>\| DEVICE</code> | Handles recursive list generation for system components. |
| **DEVICE** | `→ dispositivo: { namedevice }`<br><code>\| dispositivo: { namedevice , observation }</code> | Registers a device standalone or binds it to an explicit sensor. |
| **CMDS** | `→ CMD . CMDS`<br><code>\| CMD .</code> | A list of executable actions separated by a period marker. |
| **CMD** | `→ ATTRIB`<br><code>\| OBSACT</code><br><code>\| ACT</code> | Statement classification wrapper. |
| **ATTRIB** | `→ set observation = VAR`<br><code>\| set observation = ACTEXECUTE</code> | Sets standard variables or saves device query status. |
| **OBSACT** | `→ se OBS entao CMDS`<br><code>\| se OBS entao CMDS senao CMDS</code> | Maps standard conditional blocks or complete if-else branches. |
| **OBS** | `→ observation oplogic VAR`<br><code>\| observation oplogic VAR && OBS</code> | Evaluates active state matching or chains logical expressions. |
| **VAR** | `→ num`<br><code>\| bool</code> | Resolves values to primitive types. |
| **ACT** | `→ ACTEXECUTE`<br><code>\| ACTALERT</code><br><code>\| ACTION namedevice</code> | Triggers active operations or executes device workflows. |
| **ACTEXECUTE** | `→ verificar ( namedevice )` | Interrogates device operating parameters. |
| **ACTALERT** | `→ enviar alerta ( msg ) namedevice`<br><code>\| enviar alerta ( msg , observation ) namedevice</code><br><code>\| enviar alerta ( msg ) para todos: BROADCAST_LIST</code> | Triggers targeted standard notifications or multi-device broadcasts. |
| **ACTION** | `→ ligar`<br><code>\| desligar</code> | Maps explicit system state adjustments. |

> *Note: The rule block `BROADCAST_LIST` must be appended to the grammar definition to handle commas recursively (`namedevice, namedevice, ...`) to process the required broadcast logic.*

---

## 3. Core Constraints & Compiler Assumptions

### 3.1 Type System & Content Bounds
* **Numerical Constraints:** All numerical variables handle non-negative integers only.
* **String Constraints:** Literal contents mapped to variables `msg` and identifiers `namedevice` are restricted to a maximum length of 100 characters.
* **Integrity Constraints:** Structural terminals (`num`, `namedevice`, `namesensor`, `msg`) cannot be empty strings or null structures.

### 3.2 Semantic Rules & Initialization
* **Implicit Variable Initialization:** Any sensor identifier (`observation`) declared or evaluated that has not been explicitly assigned an initialization value via a `set` assignment must be implicitly initialized to zero (`0`) by the compiler runtime engine.
* **Alert Text Concatenation:** Calls resolving an alert tracking an observation parameter (`enviar alerta(msg, observation)`) must evaluate to a singular concatenated string following the layout: `msg + " " + observation`.

---

## 4. Target C Runtime Environment

The transpilador must generate or link an environment implementing the following 5 target core operations rewritten into standard C architecture:

```c
#include <stdio.h>

// Activates a target device state
int ligar(const char* namedevice) {
    printf("%s ligado!\n", namedevice);
    return 1;
}

// Deactivates a target device state
int desligar(const char* namedevice) {
    printf("%s desligado!\n", namedevice);
    return 0;
}

// Queries the operating state of a target device
int verificar(const char* namedevice) {
    // Simulated state tracking (can return 1 or 0 based on global application context)
    printf("%s esta ligado.\n", namedevice);
    return 1; 
}

// Outputs a standard string notification alert to a specific device
void alerta_simples(const char* namedevice, const char* msg) {
    printf("%s recebeu o alerta: \n", namedevice);
    printf("%s\n", msg);
}

// Outputs a hybrid text/variable notification alert to a specific device
void alerta_com_variavel(const char* namedevice, const char* msg, int var) {
    printf("%s recebeu o alerta:\n", namedevice);
    printf("%s %d\n", msg, var);
}
```
