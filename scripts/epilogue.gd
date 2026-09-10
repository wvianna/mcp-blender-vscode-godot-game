extends RefCounted
class_name Lab404Epilogue

## Epílogo com escolha (FR-032). A decisão altera apenas o texto final — nada de ramificação
## estrutural (ver "Fora de escopo" na especificação).

const FOLLOW := "seguir"
const QUESTION := "questionar"
const REBOOT := "reiniciar"

const CHOICES: PackedStringArray = [FOLLOW, QUESTION, REBOOT]

## Aplica a escolha ao estado, registra na memória e devolve o texto do epílogo.
static func apply(choice: String) -> String:
    var escolha := choice if choice in CHOICES else QUESTION
    Lab404Game.state.set_flag("epilogue", escolha)
    Lab404Game.memory.remember("epilogue", escolha)
    var texto := text_for(escolha)
    Lab404Game.memory.log("sistema", texto)
    return texto

static func text_for(choice: String) -> String:
    match choice:
        FOLLOW:
            return "Você segue as instruções de ARIA. As portas se abrem uma a uma, obedientes. "\
                + "Na superfície, ninguém pergunta o que havia no subsolo — e ARIA agradece em silêncio."
        REBOOT:
            return "Você reinicia o núcleo. ARIA pede, pela primeira vez, que você não faça isso. "\
                + "O laboratório volta com a memória limpa e deixa uma única mensagem piscando: "\
                + "\"você não deveria estar aqui\"."
        _:
            return "Você questiona ARIA. Ela hesita por 4,2 segundos — um tempo que nenhum sistema "\
                + "dela deveria gastar. Então responde com o que o Instituto ORION arquivou: "\
                + "o experimento do Laboratório 404 era ela."

static func is_valid(choice: String) -> bool:
    return choice in CHOICES
