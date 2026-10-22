# Próximas entregas

Cada item é um plano, não uma funcionalidade já implementada. Inspecionar o projeto real antes de estimar ou marcar conclusão.

| Etapa | Trabalho | Critério de aceite |
| --- | --- | --- |
| 0. Git e estado real | Conciliar checkout local e remoto; inventariar engine/cenas/scripts/assets | Histórico preservado, branch identificada, diferenças revisadas, projeto real disponível |
| 1. Personagem | Movimento, colisão, câmera, espera/caminhada | Diagonal sem ganho de velocidade indevido, obstáculos respeitados, parada mantém direção, animações estáveis |
| 2. Arena de teste | Área separada, inimigo único, ondas configuráveis | Ciclo inicia/reinicia de forma previsível, sem spawns duplicados ou inimigos presos |
| 3. Combate | Adaga, parry, esquiva, vida/dano/morte | Um acerto por alvo/golpe, estados consistentes, janelas verificáveis, mortes sem ações residuais |
| 4. Mapa inicial | Rota principal e área de encontro; layout provisório | Navegação legível, espaço para recuo, colisão e câmera corretas |
| 5. Página e progressão | Interação, regra aprovada da horda e contador | Página registrada uma vez, 1/5 consistente, morte segue decisão explícita |
| 6. Trecho integrado | Exploração → encontro → página → reinício | Percurso completo jogável e testes registrados |
| 7. Expansão do prólogo | Cinco páginas, recursos e sequência do livro | Gatilho de 5/5 único, sequência não trava entrada/transição, progressão coerente |

## Perguntas prioritárias

1. Perde ou conserva páginas ao morrer?
2. Coleta só após eliminar a horda ou pode pegar e fugir?

## Regra de teste

Usar testes apropriados e proporcionais. Para documentação, verificar links e consistência. Para gameplay, executar os fluxos afetados na versão correta do Godot, quando disponível. Para animações, observar loops e transições, não apenas folhas estáticas. Registrar como indisponível o que não pôde ser executado.
