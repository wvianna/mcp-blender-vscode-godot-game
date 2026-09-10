# Roteiro de desenvolvimento — POC 1 → POC 6

## POC 1 — Fundação jogável

### Entrega
Uma sala cinza com um personagem 3D que anda, gira a câmera e interage com uma área de teste.

### Implementar
1. Projeto Godot 4.x.
2. Cena `Main`.
3. `CharacterBody3D`.
4. Câmera terceira pessoa ou primeira pessoa simples.
5. Gravidade e colisão.
6. Input Map.
7. Teclado.
8. Joystick USB PS1.
9. Menu de pausa.
10. HUD mínimo.

### Critério de aceite
- WASD/setas movimentam.
- Analógico esquerdo movimenta.
- Analógico direito controla a câmera, quando o adaptador expõe os eixos.
- Botão de ação funciona.
- ESC/Start pausa.
- O personagem não atravessa paredes.
- O projeto executa sem assets externos obrigatórios.

---

## POC 2 — Laboratório funcional

### Entrega
Uma sala 3D construída no Blender com portas, painel elétrico, tanque, bomba, sensor e itens.

### Sistemas
- interação por proximidade;
- retícula;
- inventário;
- portas;
- coleta;
- estados dos equipamentos;
- missão;
- feedback visual/sonoro.

### Missão
`RESTAURAR_COMUNICACAO`

1. Encontrar fusível.
2. Encontrar módulo RS-404.
3. Instalar os dois.
4. Reiniciar CLP.
5. Diagnosticar bomba.
6. Abrir porta do corredor.

---

## POC 3 — ARIA + Ollama

### Entrega
Terminal de ARIA funcionando com LLM local.

### Arquitetura

Godot → HTTP local → adaptador Python → Ollama

O adaptador evita acoplar o jogo diretamente à API do modelo.

### Regras
- A LLM não controla diretamente física.
- A LLM não executa comandos arbitrários.
- A LLM apenas retorna texto e intenções estruturadas.
- O jogo valida todas as ações.

### Exemplo de intenção
```json
{
  "intent": "HINT",
  "target": "PLC_404",
  "confidence": 0.91
}
```

---

## POC 4 — Mundo inteligente

### Entrega
O estado do laboratório muda e NPCs respondem a ele.

### Exemplos
- técnico de manutenção comenta sobre a bomba;
- ARIA muda seu tom após o jogador ignorar um alerta;
- luzes piscam conforme energia disponível;
- portas dependem de permissões;
- equipamentos têm estados `OFF`, `FAULT`, `READY`, `RUNNING`.

### Memória
Separar:
- memória de sessão;
- estado persistente do jogo;
- conhecimento narrativo;
- histórico conversacional.

---

## POC 5 — Cenários modulares/procedurais

### Entrega
O laboratório deixa de ser uma sala fixa.

Criar módulos:
- corredor;
- sala de controle;
- sala de bombas;
- sala de baterias;
- laboratório de sensores;
- arquivo;
- câmara de contenção.

Cada módulo possui:
- entradas;
- saídas;
- pontos de interesse;
- iluminação;
- sockets para props.

A geração pode ser determinística usando uma seed.

---

## POC 6 — Vertical slice

### Entrega
Uma experiência de 10–20 minutos com começo, meio e fim.

### Sequência
1. Chegada.
2. Tutorial de controles.
3. Primeiro diagnóstico.
4. Conversa com ARIA.
5. Exploração.
6. Recuperação de componentes.
7. Falha inesperada.
8. Redirecionamento de energia.
9. Descoberta narrativa.
10. Reinicialização.
11. Porta final.
12. Epílogo.

### Critério de aceite
Uma pessoa que nunca viu o projeto deve conseguir jogar sem intervenção do desenvolvedor.
