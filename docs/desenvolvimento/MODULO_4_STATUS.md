# Módulo 4 — execução por fatias

Baseline confirmado: `4462421`, módulo3 encerrado nesta sessão e publicação registrada. Godot4.7.2, F5/playable, viewport640×360; arquivos posteriores e alterações alheias preservados. Backup inicial SHA256: `backups/modulo4/inicial`, 2415 arquivos, exclui caches/Git/segredos/backups/exports (inclusive Jogo_Godot2, somente executáveis). Não cobre memória não salva do editor. Consulta inicial:66% primária/95% semanal; após fase01:61%/94%, conta compartilhada, não previsão de consumo.

| Fase | Estado | Evidência / próximo passo |
|---|---|---|
|01 Contato/onda|validada|Falha reproduzida antes;134 casos novos e1384 da lâmina sem falhas; captura real17_contact_wave. Config34/46px e meia abertura0,85rad provisórias; base sem onda/gratuidade.|
|02 Árvore/HUD|validada|Cena própria instanciada,16 casos novos,UI24/habilidades24/módulo2 45/combate54 sem falhas; capturas640/1920; seguir03.|
|03 Reativação|em andamento|Fase corrente.|
|04 Comida/vingança|pendente|Não iniciada.|
|05 Altar/final|pendente|Não iniciada.|
|06 Revisão/preservação|pendente|Testes afetados/checkpoints; regressão integrada no fechamento.|

## 01 — diagnóstico e implementação

Reprodução antes: alvo vivo na lâmina final,0,001s ativos e delta1/30; `advance_action` mudava para recuperação antes da verificação, vida50→50. Registro17_contact_before.json. Correção mantém intervalo ativo e fração de movimento até a transição; verifica poses intermediárias e trajetórias relativas alvo/metal, sem dano da preparação/recuperação. `strike_targets` direto permanece contato instantâneo. Alvos removidos não ficam retidos no histórico. Geometria da onda compartilhada entre desenho/dano, só níveis1/2; cada alvo recebe um dano por golpe mesmo com metal+onda. Parede/pausa/morte/feedback/adaga ausente bloqueiam. Testes oito direções/deltas1/120,1/60,1/30,0,1s, tangência/fora/costas, alvo móvel, parede/cancelamento; captura é fixture/debug, não arte final. Tolerância numérica de0,0001px na tangência da onda, sem inflar hurtbox dos monstros.

## 02 — catálogo, cena e HUD

Ramos throw/reach/parry. reach.first/second substituem tracking.unlock/stride; sem rastreio, F, consultas ou bônus de dash. Arquivo de tracker legado neutralizado preservando path/UID. Dash30,4px/0,16s permanece. Compras guardam custo real; retirada de IDs legados apaga bônus e reembolsa apenas ledger comprovado, uma vez (sem save de campanha/migração fictícia). Onda34/46px do recurso da fase01 é lida pelo atributo comprado.

`scenes/ui/skill_tree.tscn` é a única cena da árvore; mesmo personagem/coordenador. Nó selecionável mostra detalhes/requisito/custo; compra separada e estado textual. Atributos em seção própria. Vida/fome no canto inferior esquerdo, barras6/5px, labels separados; corrigido tamanho mínimo de tema detectado na inspeção. Capturas640×360/1920×1080 mantêmviewport640. Recursos/valores reais, apenas pontos de fixture para comprar; avaliação humana da legibilidade pendente.
