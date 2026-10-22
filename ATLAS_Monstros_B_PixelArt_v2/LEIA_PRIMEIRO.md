# ATLAS — monstros B em pixel art, revisão 2

Conjunto: B1 Fenda, B2 Carcaça, B3 Esporo e B4 Escavador compacto.
As referências escolhidas foram reinterpretadas com contornos em degraus,
blocos de cor maiores e menos textura. As versões anteriores foram preservadas.

Cada PNG RGBA contém quatro vistas paradas em uma grade 2 × 2:
- Superior esquerda: baixo/frente.
- Superior direita: esquerda.
- Inferior esquerda: direita.
- Inferior direita: cima/costas.

Extraia a pasta assets na raiz do projeto Godot, ao lado de project.godot.
As imagens ficam em assets/monstros/<nome>/pixel_v2/.
Estes PNGs são fontes ampliadas, não arquivos nativos de 32 × 32 ou 48 × 48.
As dimensões reais e os recortes de cada célula constam em MANIFESTO.json.
A largura de uma das folhas é ímpar; use as coordenadas registradas em vez
 de presumir quatro células de dimensões perfeitamente iguais.

Para o Codex: confira a versão do Godot, importe como referência visual,
use filtragem Nearest e ajuste o tamanho de exibição junto ao protagonista.
Confira pivô e escala entre direções antes de animar. Se forem necessários
sprites nativos com grade/paleta estrita, essa exportação e limpeza ainda
precisam ser feitas: não alegue que os PNGs ampliados já atendem a uma grade
nativa perfeita ou ao limite exato de cores pedido ao gerador.

As vistas foram inspecionadas visualmente. Verificações automáticas:
PNG legível, canal alfa, existência de conteúdo em cada célula, dimensões,
hashes e integridade do ZIP. No Esporo, o alfa máximo registrado é 254;
se a pipeline exigir opacidade binária, normalize e confira as bordas.
Não houve teste no Godot: o engine não está disponível nesta sessão.

O pacote contém bases estáticas. Caminhada, ataque, dano, morte e os estados
subterrâneos do Escavador ainda precisam de quadros e validação em movimento.
Não inclui a linha A nem altera o protagonista; esta revisão trata dos
quatro monstros da direção B escolhida na conversa.

As imagens foram criadas com image_gen integrado. PROMPTS.json registra
os prompts de geração e a correção adicional de acabamento do Esporo.
