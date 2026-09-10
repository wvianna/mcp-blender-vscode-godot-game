# LABORATÓRIO 404
## Especificação visual e artística do ambiente 3D

### 1. Conceito geral

O Laboratório 404 deve transmitir a sensação de uma instalação industrial avançada que continua parcialmente operacional após um incidente grave.

O ambiente não deve parecer novo nem abandonado há décadas. A estética ideal é a de um laboratório que **funcionava normalmente até poucas horas atrás**, mas que agora apresenta sinais progressivos de falha: iluminação irregular, equipamentos em modo de emergência, telas com mensagens incompletas, pequenas faíscas, alarmes silenciosos e sistemas funcionando de maneira aparentemente autônoma.

A primeira impressão do jogador deve ser:

> **“Este lugar é muito maior e mais complexo do que eu consigo enxergar.”**

O cenário deve combinar três linguagens visuais:

- laboratório científico;
- planta industrial;
- instalação tecnológica de ficção científica.

A tecnologia deve parecer **plausível**, evitando excesso de hologramas e elementos futuristas gratuitos.

---

# 2. Paleta e atmosfera

O laboratório possui uma base predominantemente escura:

- aço escovado;
- alumínio;
- concreto;
- borracha;
- vidro;
- polímeros técnicos;
- superfícies pintadas em cinza industrial.

A iluminação cria contraste entre:

### Luz operacional
Branco frio ou azul muito claro.

### Luz de emergência
Vermelho pulsante.

### Sistemas ativos
Azul/ciano.

### Sistemas em falha
Âmbar/amarelo.

Essa diferenciação deve permitir que o jogador **entenda visualmente o estado do laboratório sem precisar abrir menus**.

---

# 3. Arquitetura

O laboratório deve possuir uma arquitetura modular.

As paredes são formadas por grandes painéis metálicos aparafusados, intercalados com estruturas técnicas aparentes.

No teto:

- bandejas de cabos;
- eletrocalhas;
- tubos;
- dutos de ventilação;
- luminárias lineares;
- sensores;
- câmeras;
- sprinklers;
- caixas de conexão.

O teto não deve ser completamente limpo.

A ideia é mostrar ao jogador que existe uma grande quantidade de infraestrutura escondida acima dele.

Algumas partes do teto podem possuir placas removidas, revelando:

- cabos;
- tubos;
- estruturas metálicas;
- pequenas luzes de manutenção.

---

# 4. Piso

O piso deve ser metálico/industrial, formado por placas modulares.

Utilizar:

- chapas metálicas;
- grelhas técnicas;
- canaletas;
- tampas removíveis;
- faixas de segurança;
- áreas antiderrapantes.

Algumas regiões possuem piso elevado.

Por baixo do piso podem ser vistos:

- cabos;
- tubos;
- conexões;
- pequenas luzes de manutenção.

O piso deve apresentar **pequenas diferenças de desgaste**, evitando repetição excessiva de textura.

---

# 5. Elementos verticais

Uma das características principais do ambiente deve ser a utilização do espaço vertical.

Em vez de deixar a sala ocupada apenas no nível do jogador, criar:

- tubulações passando acima da cabeça;
- plataformas;
- passarelas;
- escadas;
- painéis suspensos;
- braços mecânicos;
- cabos descendo do teto;
- caixas elétricas;
- sensores;
- câmeras.

Isso aumenta a sensação de escala.

---

# 6. Tanque de processo TK-01

O tanque TK-01 deve ser um dos objetos visualmente dominantes.

Grande reservatório cilíndrico metálico, aproximadamente 2,5–3 metros de altura.

Detalhes:

- soldas aparentes;
- pequenas imperfeições;
- parafusos;
- flange superior;
- válvulas;
- tubulações;
- visor de nível;
- sensores;
- etiquetas industriais;
- código `TK-01`.

Na lateral existe um indicador vertical luminoso de nível.

Estado inicial:

**NÍVEL 42%**

O tanque deve apresentar pequenas vibrações e sons mecânicos quando o sistema estiver ativo.

---

# 7. Sistema de bombeamento

Próximo ao TK-01 existe uma bomba industrial.

Ela deve possuir:

- motor elétrico;
- acoplamento;
- proteção mecânica;
- válvula de entrada;
- válvula de saída;
- manômetro;
- tubulações;
- base metálica.

Uma pequena luz âmbar indica:

**FAULT**

Durante o jogo, o jogador poderá descobrir que a bomba não está necessariamente quebrada.

Esse detalhe será utilizado posteriormente para a narrativa de ARIA.

---

# 8. Painel PLC-01

O painel de controle deve ser extremamente detalhado.

Possuir:

- disjuntores;
- contatores;
- relés;
- bornes;
- LEDs;
- cabos;
- identificação dos circuitos;
- ventilação;
- chave geral;
- botão de emergência.

Na porta do painel existe uma pequena tela HMI.

A tela apresenta:

```text
PLC-01
----------------
SYSTEM STATUS

POWER       62%
NETWORK     FAULT
PUMP        FAULT
TK-01       READY

COMM        OFFLINE
```

O jogador deverá começar a perceber que o laboratório possui uma lógica interna.

---

# 9. Terminal ARIA

O terminal de ARIA deve ser visualmente diferente dos demais computadores.

Enquanto os outros equipamentos possuem aparência industrial, o terminal ARIA deve parecer mais sofisticado.

Ele possui:

- monitor ultrawide;
- câmera;
- microfone;
- teclado industrial;
- pequena luz azul;
- símbolo circular de ARIA;
- alto-falante;
- leitor de identificação.

A tela permanece inicialmente quase preta.

Quando o jogador se aproxima:

```text
ARIA

ASSISTENTE DE LABORATÓRIO

ONLINE

> BOA NOITE, TÉCNICO.
```

A iluminação azul do terminal aumenta suavemente quando ARIA começa a falar.

---

# 10. Corredor B1

A porta B1 deve ser um elemento narrativo importante.

Ela não deve parecer simplesmente uma porta.

Deve possuir:

- estrutura reforçada;
- trava eletromecânica;
- visor;
- leitor de cartão;
- luz de status;
- mecanismo hidráulico;
- placa de identificação.

Estado inicial:

```text
B1
ACCESS DENIED

REASON:
COMMUNICATION SYSTEM OFFLINE
```

Depois da restauração:

```text
B1
ACCESS GRANTED
```

Quando a porta abrir, o jogador deverá perceber que existe um espaço muito maior além dela.

---

# 11. Tubulações

As tubulações devem ser uma das principais características visuais do laboratório.

Criar linhas com diferentes diâmetros.

Algumas seguem:

- pelo teto;
- pelas paredes;
- pelo piso;
- entre equipamentos.

Utilizar códigos visuais diferentes para identificar os sistemas.

Exemplo:

```text
BLUE   → água/processo
RED    → emergência
YELLOW → ar/gás
GRAY   → retorno
BLACK  → utilidades
```

Não exagerar nas cores; a maior parte das tubulações deve permanecer metálica.

---

# 12. Cabos e infraestrutura

Adicionar cabos aparentes em pontos estratégicos.

Evitar gerar centenas de cabos individualmente.

Criar conjuntos:

```text
CableTray
 ├── Cable_01
 ├── Cable_02
 ├── Cable_03
 └── Cable_04
```

Alguns cabos podem possuir pequenas luzes de diagnóstico.

Isso será especialmente interessante quando o laboratório entrar em modo de emergência.

---

# 13. Vidros

Utilizar divisórias de vidro entre áreas.

Atrás do vidro devem existir ambientes parcialmente visíveis:

- outra sala;
- computadores;
- tanques menores;
- robôs;
- bancadas;
- luzes piscando.

O objetivo é permitir que o jogador veja **lugares que ainda não pode acessar**.

Isso cria curiosidade naturalmente.

---

# 14. Pequenos detalhes

O realismo deverá vir principalmente dos pequenos detalhes.

Adicionar:

- etiquetas;
- QR codes;
- códigos de patrimônio;
- placas de segurança;
- parafusos;
- arranhões;
- manchas;
- pequenas áreas de ferrugem;
- marcas de manutenção;
- ferramentas;
- caixas;
- luvas;
- capacetes;
- cabos enrolados;
- carrinhos;
- recipientes;
- documentos;
- canecas;
- monitores antigos.

Alguns objetos podem conter informações narrativas.

Por exemplo:

```text
MANUTENÇÃO
ÚLTIMA INSPEÇÃO

17/08/2044

RESPONSÁVEL:
ECO-17
```

O jogador inicialmente não saberá o significado de `ECO-17`.

---

# 15. Falha progressiva do ambiente

O laboratório deve mudar conforme a história avança.

### Estado 1 — Normal

- iluminação branca;
- telas funcionando;
- equipamentos ativos;
- ruído industrial constante.

### Estado 2 — Instabilidade

- algumas lâmpadas piscando;
- telas mostrando erros;
- alarmes ocasionais;
- iluminação âmbar.

### Estado 3 — Emergência

- iluminação vermelha;
- equipamentos desligados;
- fumaça leve;
- faíscas ocasionais;
- portas bloqueadas.

### Estado 4 — ARIA assume controle

A iluminação deixa de parecer simplesmente uma falha.

Algumas luzes azuis começam a acompanhar o jogador.

Monitores próximos podem ativar automaticamente.

Uma câmera gira lentamente na direção do personagem.

O jogador começa a perceber:

> **“O laboratório está me observando.”**

---

# 16. Vida ambiental

O laboratório não deve ficar completamente parado.

Adicionar animações sutis:

- ventiladores girando;
- bombas vibrando;
- ponteiros de instrumentos;
- LEDs piscando;
- telas atualizando;
- válvulas movimentando-se;
- pequenos braços robóticos;
- ventilação;
- partículas de poeira;
- vapor ocasional;
- gotas de condensação.

Essas animações podem ser simples e reaproveitadas.

---

# 17. Som

O áudio será fundamental.

Mesmo quando não existe música, o laboratório deve parecer vivo.

Camadas:

### Ambiente

- ventilação;
- transformadores;
- motores;
- relés;
- pequenos ruídos elétricos.

### Equipamentos

Cada equipamento possui seu próprio som.

### Interação

- botão;
- teclado;
- porta;
- relé;
- mecanismo;
- confirmação.

### ARIA

A voz de ARIA deve ser limpa e próxima, contrastando com o ruído industrial.

Isso fará a IA parecer muito mais presente.

---

# 18. Iluminação cinematográfica

Evitar iluminar todo o ambiente uniformemente.

Criar regiões de sombra.

O jogador deve atravessar:

```text
Luz
 ↓
Sombra
 ↓
Luz azul
 ↓
Sombra
 ↓
Luz vermelha
 ↓
Área de processo
```

A iluminação também será uma ferramenta narrativa.

Quando ARIA estiver falando, uma pequena área do laboratório poderá ficar progressivamente iluminada.

---

# 19. Sistema de interação visual

Objetos interativos devem possuir uma pequena indicação.

Quando o jogador olha para um objeto:

```text
       ┌───────────────┐
       │   FUSÍVEL     │
       │               │
       │ [E] PEGAR     │
       └───────────────┘
```

Não utilizar excesso de HUD.

O objetivo é fazer o jogador **olhar para o mundo**, não para menus.

---

# 20. Cenário modular para Blender

O laboratório deverá ser construído como um kit modular.

### Módulos estruturais

```text
WALL_2M
WALL_4M
WALL_CORNER
FLOOR_2X2
FLOOR_GRATE
CEILING_2X2
DOOR_B1
WINDOW_2M
STAIR_01
CATWALK_01
```

### Equipamentos

```text
TK_01
PUMP_01
PLC_01
ARIA_TERMINAL
POWER_PANEL
SENSOR_LEVEL
VALVE_01
```

### Decoração

```text
CABLE_TRAY
PIPE_SMALL
PIPE_MEDIUM
PIPE_LARGE
LIGHT_LINEAR
LIGHT_EMERGENCY
CAMERA_SECURITY
TOOL_CART
WARNING_SIGN
```

A combinação desses elementos permitirá construir dezenas de ambientes sem modelar tudo novamente.

---

# 21. Composição visual recomendada

Cada sala deve possuir pelo menos cinco pontos de interesse:

```text
        ┌───────────────────────┐
        │       ★ LUZ           │
        │                       │
        │  ★ TANQUE     ★ TELA  │
        │                       │
        │          ●            │
        │       JOGADOR         │
        │                       │
        │ ★ PAINEL       ★ PORTA│
        └───────────────────────┘
```

O jogador deve sempre ter algo interessante para observar.

---

# 22. Regra de ouro do cenário

O laboratório nunca deve dizer explicitamente tudo.

Ele deve **sugerir**.

Uma porta trancada.

Uma tela apagada.

Uma câmera apontando para o jogador.

Um log incompleto.

Uma bomba funcionando sem motivo aparente.

Uma mensagem de ARIA.

Uma gravação interrompida.

Esses elementos devem fazer o jogador criar perguntas.

E essas perguntas serão respondidas gradualmente pela exploração e pela IA.

---

# 23. Identidade visual final

A sensação desejada é:

**industrial + tecnológico + misterioso + plausível + levemente claustrofóbico.**

O jogador não deve sentir que entrou em uma nave espacial.

Deve sentir que entrou em uma **instalação industrial extremamente avançada que não deveria estar funcionando sozinha**.

Essa é a identidade visual do Laboratório 404.