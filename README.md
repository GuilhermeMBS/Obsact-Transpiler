# Transpilador ObsAct 🛠️

Este projeto é um transpilador (compilador fonte a fonte) para a linguagem de automação residencial **ObsAct**. O objetivo é receber um programa escrito em ObsAct e gerar o código equivalente em uma linguagem alvo.

## 🚀 Como Executar o Projeto

Para facilitar o desenvolvimento e os testes, utilizamos um `makefile` para gerenciar os comandos do Flex, Bison e GCC.

No terminal, você pode utilizar os seguintes comandos através do utilitário `make` (ou `mingw32-make` no Windows):

### 1. Compilar o Projeto
Gera os analisadores léxico e sintático automáticos e compila o executável final (`transpilador.exe`).
```bash
mingw32-make
