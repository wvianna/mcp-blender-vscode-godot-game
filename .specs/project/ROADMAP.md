# ROADMAP — Laboratório 404

Progressão incremental. Critério de avanço: POC atual executável e demonstrável.

> **Status (2026-09-10):** POC 1 a POC 6 implementados e cobertos por testes automatizados
> (`tests/run_all.sh`, tudo PASS). Pendências reais: validação em hardware (joystick PS1/mouse),
> Ollama com modelo instalado, empacotamento (`T-033`) e playthrough humano (CA-013).

## POC 1 — Fundação jogável
Sala cinza + personagem 3D que anda, gira a câmera e interage com uma área de teste. Teclado e joystick USB PS1; menu de pausa; HUD mínimo; `InputTest` de diagnóstico. **Aceite:** CA-001…CA-005.

## POC 2 — Laboratório funcional
Sala 3D no Blender (portas, painel, tanque, bomba, sensor, itens) exportada GLB. Interação por proximidade, retícula, inventário, portas, coleta, estados de equipamento, missão `RESTAURAR_COMUNICACAO` e feedback visual/sonoro. **Aceite:** CA-006…CA-008.

## POC 3 — ARIA + Ollama
Terminal de ARIA com LLM local. Fluxo Godot → HTTP local → adaptador Python → Ollama. Intents estruturadas e validadas; timeout e fallback. **Aceite:** CA-009, CA-010.

## POC 4 — Mundo inteligente
O laboratório reage: NPCs, memória de contexto, eventos, tom da ARIA, luzes e permissões. **Aceite:** CA-011.

## POC 5 — Laboratório procedural
Módulos (corredor, controle, bombas, baterias, sensores, arquivo, contenção) com entradas/saídas/sockets; geração determinística por seed com conectividade garantida. **Aceite:** CA-012.

## POC 6 — Vertical slice
Experiência de 10–20 min (chegada → tutorial → diagnóstico → conversa → exploração → recuperação → falha → redirecionamento → revelação → reinicialização → porta final → epílogo). Save/load, áudio, empacotamento e demonstração. **Aceite:** CA-013.
