# Prompts para GitHub Copilot

## Regra

Peça implementação incremental. Não solicite "faça o jogo inteiro".

### POC 1 — Player
> Analise a arquitetura do Laboratório 404. Implemente o controller do player em Godot 4 usando Input Map sem hardcode de botões. Suporte teclado e joystick por ações semânticas. Não altere arquivos fora de scripts/player sem necessidade.

### POC 1 — Diagnóstico
> Crie uma cena InputTest que liste joysticks conectados e mostre eixos/botões em tempo real. O objetivo é descobrir como o adaptador USB de PS1 está enumerando seus controles.

### POC 2 — Interação
> Implemente Interactable como sistema desacoplado. O jogador deve detectar objetos por raycast e exibir prompt contextual.

### POC 3 — ARIA
> Implemente um cliente HTTP assíncrono para o adapter local de ARIA. Adicione timeout, tratamento de erro e fallback para mensagens pré-definidas.

### POC 4 — Estado
> Crie uma máquina de estados para equipamentos industriais. Os estados devem ser serializáveis e independentes da interface.

### POC 5 — Geração
> Implemente geração determinística de módulos de laboratório usando seed. Garanta que entradas e saídas compatíveis sejam conectadas.

### POC 6 — Polimento
> Faça uma auditoria do projeto buscando acoplamento excessivo, referências quebradas, assets ausentes, problemas de input e riscos de performance. Não faça mudanças automaticamente: produza primeiro um relatório.
