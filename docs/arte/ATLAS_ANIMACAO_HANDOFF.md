# ATLAS — corrigir, verificar e integrar as animações

## Objetivo e estado atual

Preparar as animações de espera e caminhada do protagonista para o Godot, corrigindo as folhas antes da integração. O visual do personagem pequeno foi aprovado pelos responsáveis pelo projeto. As folhas de animação são rascunhos e ainda não foram aprovadas em movimento nem verificadas tecnicamente.

Este documento registra a revisão visual realizada na conversa. Não houve reprodução em loop, medição dos quadros, inspeção do canal alfa ou teste no Godot. Não declarar essas verificações como concluídas.

## Arquivos de referência

Os seguintes arquivos estão junto deste documento na pasta GODOT-ATLAS. Disponibilizá-los ao Codex junto com o projeto; os nomes abaixo não implicam que já estejam no repositório local.

- `Atlas em pixel art, quatro direções.png`: referência visual aprovada do personagem pequeno.
- `Spritesheet de respiração do protagonista.png`: rascunho da animação de espera.
- `Spritesheet de caminhada do Atlas.png`: rascunho da caminhada.
- `Pacote_continuidade_projeto_ATLAS.zip`: documentação de continuidade; consultar para conferir detalhes do traje e do projeto.

Preservar as imagens originais. Se algum arquivo não estiver disponível no ambiente do Codex, informar exatamente qual está faltando e continuar as tarefas independentes.

## Identidade aprovada

- Homem adulto, acima de 25 anos, pele média.
- Cabelo castanho-escuro comprido, preso em rabo de cavalo baixo.
- Barba curta definida e traços marcantes.
- Cabeça levemente ampliada e corpo simplificado.
- Roupas danificadas que usava na nave.
- Cachecol longo preto com traços vermelho-escuros.
- Pixel art simples, câmera de cima com vista oblíqua.
- Movimento cauteloso; observa e age apesar do medo.

Consultar o documento inicial para confirmar o traje. Seu corte e suas cores foram propostos provisoriamente na elaboração do conceito.

## Inspeção visual já realizada

- A caminhada apresenta poses muito semelhantes e passagem dos pés pouco clara, especialmente nas vistas laterais. Verificar a alternância dos apoios em movimento.
- Há aparentes diferenças de posição e escala entre quadros e entre as folhas. Medir após o recorte para separar deslocamento involuntário do balanço intencional.
- Na espera, conferir se as pequenas mudanças representam respiração ou apenas deslocamento do desenho.
- A transparência da folha de espera precisa de confirmação: a visualização apresentou fundo escurecido, o que não comprova o estado do canal alfa.
- Conferir a continuidade entre o último e o primeiro quadro e a estabilidade da cabeça, barba, cachecol e marcas do traje.

## Execução no Codex

1. Ler as instruções do repositório e identificar a versão do Godot, a cena do jogador e a estrutura atual das animações.
2. Inspecionar dimensões reais, canal alfa, espaçamento da grade e limites de cada sprite. Trabalhar em cópias das artes originais.
3. Definir a resolução nativa com base no personagem dentro do cenário. **32 × 48 pixels por quadro é uma proposta inicial, não uma dimensão já verificada nas imagens geradas.** Considerar espaço para cabelo e cachecol. Evitar suavização ao redimensionar pixel art.
4. Padronizar escala, recortes e pivô na base dos pés. Manter cabelo e cachecol inteiros dentro de cada célula. Não tratar diferenças de enquadramento como respiração.
5. Corrigir a caminhada nas quatro direções: contato esquerdo → apoio esquerdo → passagem direita → contato direito → apoio direito → passagem esquerda. Conferir alternância dos pés, braços e apoio do corpo. Não simular passos apenas deslocando o sprite inteiro.
6. Corrigir a espera: respiração discreta, pés estáveis e pequeno movimento secundário de cabelo e cachecol. Não confundir tremor de enquadramento com respiração.
7. Se faltarem desenhos necessários, registrar quais quadros precisam ser redesenhados. Não apresentar uma sequência incompleta como animação final.
8. Gerar prévias animadas por direção, em velocidade normal e lenta. Revisar quadro a quadro e observar os ciclos em repetição.
9. Integrar na estrutura de animação existente do projeto, com filtragem apropriada para pixel art. Conferir início, parada, troca de direção, manutenção da última direção ao parar e relação entre passos e velocidade de deslocamento.

## Organização e tempos iniciais

Ordem pretendida das linhas: baixo, esquerda, direita, cima. Conferir a ordem nas imagens reais antes de recortar. As folhas foram solicitadas com quatro quadros por direção na espera e seis na caminhada; verificar suas grades reais.

| Animação | Nomes sugeridos | Quadros propostos | Velocidade inicial |
| --- | --- | --- | --- |
| Espera | `idle_down`, `idle_left`, `idle_right`, `idle_up` | 4 por direção | 4 FPS |
| Caminhada | `walk_down`, `walk_left`, `walk_right`, `walk_up` | 6 por direção | 8 FPS |

Esses tempos são pontos de partida: 1 segundo por ciclo de espera e 0,75 segundo por ciclo de caminhada. Ajustar pela leitura do movimento e pela velocidade real do jogador. Não são parâmetros aprovados em teste.

## Verificação obrigatória

- Alternância clara dos apoios e passagem legível dos pés.
- Ausência de tremor e deslizamento involuntário.
- Escala, volume e identidade consistentes.
- Fechamento suave do último para o primeiro quadro.
- Transição estável entre espera e caminhada.
- Transparência e ausência de bordas residuais.
- Nenhum corte de cabelo, mãos, botas ou cachecol.
- Leitura no tamanho real dentro do cenário.

## Entrega

Entregar PNGs transparentes com grade uniforme, prévias em GIF ou APNG, recursos e alterações necessários ao Godot e README com dimensões, direções, tempos e resultados das verificações. Distinguir testes realizados de pendências. Caso a execução do Godot não esteja disponível, declarar essa limitação.

Preservar as mecânicas e a narrativa existentes. No prólogo, manter a busca pelas cinco páginas perdidas (0/5 a 5/5); depois de reuni-las, o livro passa rapidamente as páginas, surge uma torre de luz e o livro desaparece com uma animação, seguindo a continuidade já aprovada.
