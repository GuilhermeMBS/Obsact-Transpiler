# ObsAct Grammar Flow

This document describes the grammatical architecture and the processing flow of programs written in the **ObsAct** language, detailing how the transpiler analyzes syntax from component initialization to the execution of logic actions.



---

## 1. General Program Structure

The execution flow of an `.obsact` file is strictly divided into two sequential macro phases:

1. **Initialization Phase (Devices):** Declaration and registration of all physical devices and their respective associated sensors.
2. **Execution Phase (Cmds):** Continuous block containing the control logic, sensor reading, and command issuance.

```text
+-----------------------------------------+
|      Phase 1: Devices Registration      |
+-----------------------------------------+
|      Phase 2: Commands Flux (Cmds)      |
+-----------------------------------------+
```

## 2. Command Units (`cmd`)
After defining the global scope of the devices, the transpiler processes a linear list of commands. Each standalone instruction must strictly fall into one of the three categories below:

### A. Assignments (`attrib`)
These allow for the modification of the state of an observation variable (sensor). An assignment follows the syntax `set <sensor> = <expression> .` and accepts two types of definitions:

- **Literal Values:** Direct configuration using unsigned integers (`unsigned int`) or boolean values (`true` / `false`).

- **Function Returns:** A sensor value can be defined dynamically based on the return of an action execution (verification or activation) on a device (`ligar`, `desligar`, or `verificar`).

### B. Conditionals (`obsact`)
Flow control structures based on logical states. They operate in the classical form:
`se <logical_operations> entao <command> senao <command>`

- **Logical Expressions:** Supports sensor evaluation using relational operators (`>`, `<`, `>=`, `<=`, `==`, `!=`) recursively chained by logical operators such as `&&` (*AND*).

- **Block Scope:** The delimiter for the end of the conditional structure is the period character (`.`) of the inner command, dispensing the need for braces or explicit block delimiters (such as `begin`/`end`).

### C. Simple Actions (`act`)
Direct instructions that interact with the device ecosystem or trigger runtime notifications:

- **Hardware Control:** Calls to turn on, turn off, or verify the structural integrity of a specific device.

- **Alert Dispatch:** Emission of text strings containing notification messages. It supports individual dispatch to a specific device or bulk dispatch using the Broadcast directive (`para todos:`).

## 3. Rigid Delimitation Rule
One of the most rigid grammatical constraints concerns the terminal **Period character (`.`):**

- **Assignment and Action Commands:** Require the explicit presence of the `.` immediately after the end of their arguments to signal the end of the instruction.

- **Conditional Commands (`se...entao`):** Do not demand an additional period, as the internal instruction contained within the body of the block already carries the period that terminates the entire conditional scope.
