# Constituição do Projeto — Laboratório 404

Princípios inegociáveis. Nenhuma tarefa pode violá-los; em caso de conflito, registre em `STATUS.md`.

1. **Regra de Ouro.** Cada POC termina em versão executável e demonstrável. Não avance enquanto o POC atual não tiver caminho de teste reproduzível.

2. **Segurança da IA.** ARIA (LLM) só devolve texto e intenções estruturadas. Nunca executa comandos arbitrários, nunca controla física e nunca acessa o sistema operacional. O jogo valida toda ação.

3. **Intents restritas.** Apenas o conjunto cadastrado (`HINT`, `DIAGNOSE`, `LORE`, `STATUS`, `NONE`). Qualquer intent desconhecida é rejeitada ou convertida para `NONE`.

4. **Input semântico.** Todo gameplay usa ações do Input Map. Proibido `is_joy_button_pressed(n, b)` ou hardcode de índices, pois o adaptador PS1→USB varia por hardware.

5. **Escala e convenção Blender.** 1 unidade = 1 metro; aplicar transform antes de exportar; prefixos `ENV_`, `PROP_`, `INT_`, `COL_`, `FX_`, `NPC_`, `DEC_`; preferir GLB/glTF.

6. **Alvo de desempenho.** PC sem GPU dedicada: geometria simples, texturas moderadas, iluminação controlada, LLM pequena (`llama3.2:3b`).

7. **Não inventar dados.** Versões, configurações e resultados não confirmados devem ser marcados `A CONFIRMAR`. Nunca declarar produção validada apenas por teste local.

8. **Documentação é entregável.** `README.md`, `AGENTS.md`, `STATUS.md`, `TASKS.md` e `HANDOFF.md` refletem o comportamento real; documentação desatualizada é defeito.

9. **Incremento pequeno.** Uma issue/sistema por vez; implementar → testar → só então avançar (ver `scripts/README.md`).
