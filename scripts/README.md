# Scripts

Estado: **POC 1 a POC 6 implementados** (ver `STATUS.md`).
Teste: `tests/run_all.sh`.

Convenções: GDScript com `class_name`, `@export`, sinais e indentação de 4 espaços; input apenas
por ações do Input Map (`config/input_map.md`); estado global no autoload `Lab404Game`.

Sugestão de workflow:

1. Abrir o projeto no VS Code.
2. Criar uma issue por sistema.
3. Pedir ao Copilot para implementar somente uma issue.
4. Rodar os testes.
5. Fazer commit.
6. Só então avançar.

Exemplo de prompt:

> Implemente somente o sistema de interação deste projeto. Use as ações do Input Map, não números de botões de joystick. Preserve a arquitetura existente e crie um teste simples.
