# ARIA com Ollama

## Arquitetura segura

O jogo não deve confiar na LLM para lógica crítica.

```text
Godot
  │
  │ JSON
  ↓
API Adapter
  │
  ├── valida entrada
  ├── injeta contexto
  ├── chama Ollama
  └── valida saída
       │
       ↓
     Ollama
       │
       ↓
  resposta estruturada
```

## Contrato

Entrada:

```json
{
  "message": "A bomba não liga.",
  "game_state": {
    "pump": "FAULT",
    "power": 62
  }
}
```

Saída ideal:

```json
{
  "text": "A bomba está em falha.",
  "intent": "DIAGNOSE",
  "target": "PUMP_404",
  "confidence": 0.94
}
```

O jogo deve aceitar apenas intenções previamente cadastradas.

## Personalidade de ARIA

- calma;
- precisa;
- econômica;
- nunca usa gírias;
- não revela tudo imediatamente;
- admite incerteza;
- não inventa sensores inexistentes.

A personalidade deve ficar em um arquivo de configuração/versionamento, não espalhada pelos scripts.
