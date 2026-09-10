# MONOGRAFIA_RASTREABILIDADE.md — Matrizes de rastreabilidade

Atualizado em 2026-09-10.

## 1) Objetivo específico → método → evidência → resultado → status

| Objetivo específico | Método | Evidência | Resultado | Status |
|---|---|---|---|---|
| OE1. Especificar requisitos, critérios de aceitação e matriz de rastreabilidade | Escrita da especificação antes da implementação; formato DADO/QUANDO/ENTÃO | `SPECIFICATION.md`; Apêndice A; esta matriz | Requisitos FR-001..FR-033 e NFR-001..NFR-008 especificados | Concluído |
| OE2. Desenvolver em provas de conceito incrementais demonstráveis | Ciclo da Regra de Ouro (implementar → testar → demonstrar) | Seis cenas de teste; vídeo; `STATUS.md` | Etapas POC 1..6 entregues com suíte verde | Concluído |
| OE3. Implementar pipeline Blender → Godot (escala, nomes, colisão) | Convenções fixas + exportação por script + importação por linha de comando | GLB medido (342 nós/37 materiais/35 colisões) | Asset integrado e validado por testes da sala | Concluído |
| OE4. Integrar IA local com contrato validado, intents restritas e fallback | Adaptador FastAPI + Pydantic; sanitização dupla; timeouts 30 s/35 s | Testes do adaptador (16); CA-009/CA-010; captura do terminal | Diálogo funcional de ponta a ponta com degradação segura | Concluído (modelo-alvo pendente) |
| OE5. Implementar mundo reativo e geração procedural determinística | Máquina de estados serializável; 4 camadas de memória; gerador com seed + BFS | Testes POC 4 (21) e POC 5 (23); CA-011/CA-012 | Mundo reativo e ala procedural verificados (6 sementes) | Concluído |
| OE6. Construir suíte de validação e arnês de evidências; executar e registrar | Cenas headless + suíte Python + arnês de captura | 211 + 16 verificações; figuras; capturas | Validação funcional completa registrada | Concluído |
| OE7. Medir desempenho e latência na máquina de referência; declarar limitações | Execução da cena completa; três contextos de conversa | Tabelas 6.2/6.3; Figuras 6.1--6.3 | 60 FPS (vsync); 12,9--22,0 s; lacunas declaradas | Concluído (amostra pequena; lacunas registradas) |

## 2) Requisito → critério de aceitação → teste → evidência

| Requisito | CA | Teste | Evidência |
|---|---|---|---|
| FR-001..FR-008 (POC 1) | CA-001..CA-005 | `tests/poc1_test.gd` (77) | Suíte verde; ressalva manual (mouse/joystick físico) |
| FR-009..FR-015 (POC 2) | CA-006..CA-008 | `tests/poc2_test.gd` (34) | Suíte verde; capturas da sala e detalhes |
| FR-016..FR-021 (POC 3) | CA-009, CA-010 | `tests/poc3_test.gd` + `tests/test_aria_adapter.py` + `tests/poc3_live_test.tscn` | Suíte verde; captura do terminal; latências medidas |
| FR-022..FR-024 (POC 4) | CA-011 | `tests/poc4_test.gd` (21) | Suíte verde; figura da NPC; figura das camadas de memória |
| FR-025..FR-027 (POC 5) | CA-012 | `tests/poc5_test.gd` (23) | Suíte verde (6 sementes); figura do gerador |
| FR-028..FR-032 (POC 6) | CA-013 (parcial) | `tests/poc6_test.gd` (30) | Suíte verde; percurso humano pendente |
| FR-033 (empacotamento) | — | Exportação para Linux | **Aberto** (export templates ausentes no ambiente) |
| NFR-001 (desempenho) | — | Execução completa | 60 FPS (vsync) em 1280x720 na iGPU |
| NFR-002 (escala) | — | Inspeção do GLB + testes da sala | 1 u = 1 m (convenção verificada nos testes) |
| NFR-003 (LLM pequena) | — | Medições de latência | Validado com llama3.1:8b; alvo 3b pendente |
| NFR-004 (timeout) | CA-009 | Suíte do adaptador | Fallback dentro do limite |
| NFR-005 (input semântico) | — | Revisão de código + testes POC 1 | Nenhum índice cru no gameplay |
| NFR-006 (segurança da IA) | CA-010 | Testes de sanitização (duas camadas) | Intenção inválida → NONE |
| NFR-007 (assets neutros) | — | Convenções do pipeline | Cores/emissivos ajustáveis por pós-processamento |
| NFR-008 (determinismo) | CA-012 | `tests/poc5_test.gd` | Mesma semente → mesmo layout |

## 3) Questões de pesquisa → resposta → evidência

| Questão | Resposta (resumo) | Evidência |
|---|---|---|
| RQ1 | Arquitetura com processo separado + contrato validado + intents restritas + fallback preserva previsibilidade | Cap. 5.5; CA-009/CA-010; testes do adaptador |
| RQ2 | Viável: 60 FPS em GPU integrada; conversa em 12,9--22,0 s (por turnos) | Cap. 6.3/6.5; Tabelas 6.2/6.3 |
| RQ3 | Rastreável: especificação, critérios, suíte e evidências versionadas | Cap. 4; Apêndices A--D; este arquivo |
