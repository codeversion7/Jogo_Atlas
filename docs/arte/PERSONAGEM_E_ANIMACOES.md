# Personagem e animações

## Identidade aprovada

Homem adulto acima de 25 anos; pele média; barba curta bem definida; cabelo castanho-escuro comprido preso em rabo de cavalo baixo. Cabeça levemente ampliada e corpo simplificado. Roupas danificadas da nave e cachecol longo preto com traços vermelho-escuros. Observa com cautela e age apesar do medo.

Direção emocional: aventura/coragem, medo/desconforto e encanto/curiosidade. Leitura do cabelo, ombros e cachecol deve funcionar na câmera de cima.

## Evolução visual

1. Conceito 2D com contornos e pintura, vistas e expressões.
2. Conversão para pixel art ainda detalhada.
3. Redução de detalhes e proporções mais compactas nas quatro direções: versão aprovada pelos responsáveis.
4. Folhas de espera/respiração e caminhada: rascunhos, com revisão técnica pendente.

## Inventário de referências entregues

| Arquivo esperado em `referencias/personagem/` | Papel | Estado |
| --- | --- | --- |
| `Atlas em pixel art, quatro direções.png` | Referência visual principal | Aprovada |
| `Spritesheet de respiração do protagonista.png` | Base da espera | Rascunho |
| `Spritesheet de caminhada do Atlas.png` | Base da caminhada | Rascunho |
| `ATLAS_ANIMACAO_HANDOFF.md` | Revisão e instruções | Cópia textual em docs/arte |
| `Pacote_continuidade_projeto_ATLAS.zip` | Origem documental | Textos preservados no arquivo histórico |

Este inventário descreve o pacote entregue, não comprova que os PNGs estejam no GitHub. Importar as referências reais pelo ambiente local; não usar imagens fictícias para preencher os caminhos.

## Revisão original e trabalho posterior

As folhas geradas apresentaram poses semelhantes, apoios pouco legíveis, possível variação de enquadramento e necessidade de verificar transparência. Não foram assistidas em loop naquela sessão. Posteriormente os responsáveis relataram uma base de animação do Codex; verificar essa versão local antes de refazer.

32 × 48 pixels foi uma proposta de tamanho nativo, não medição dos arquivos. As folhas são ampliadas. Conferir resolução, grade, alfa, escala e pivô; não apenas importar a imagem inteira como animação final.

Ordem pretendida: baixo, esquerda, direita, cima. Espera proposta: quatro quadros a 4 FPS. Caminhada proposta: seis quadros a 8 FPS. Confirmar quadros e tempos reais.

## Aceite

- Silhueta consistente e legível no tamanho do jogo.
- Pivô e escala estáveis entre direções e ações.
- Alternância dos pés e fechamento do laço sem saltos.
- Pés estáveis na espera; movimento secundário discreto do cabelo/cachecol.
- Transparência efetiva e ausência de cortes nos acessórios.
- Prévia em loop e teste na cena real.

Ataque, parry, esquiva, dano e morte ainda demandam planejamento de quadros e verificação de assets existentes. Não foram produzidos neste registro. Consulte o [handoff original](ATLAS_ANIMACAO_HANDOFF.md).
