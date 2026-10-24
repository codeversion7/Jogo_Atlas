# Fase 01 — baseline, mídia e NPC

Aplique `INICIAR.md`; não execute outras fases dentro desta.

## Entrega

Confirme estado Git/arquivos e preserve alterações anteriores com backup. Leia `MODULO_2_MAPA_MUNDO.md`, auditoria relevante e `docs/arte/npc/README.md` somente nos trechos atuais. Não refaça o módulo 2 nem a arte já preparada.

Inspecione fontes em `NPC_Personagem/`, recursos `assets/npcs/companheiro/`, `companion_visual.gd`, `scripts/world/companion.gd`, cena e laboratório. Confirme grade, pivô, transparência, escala, camadas e callbacks antes de integrar. Espera/caminhada já estão ligadas ao jogo: preservar e corrigir só falhas comprovadas. Preparar integração de corrida/dano/escudo com um único corpo e FX separados, sem ligar mecânicas antes da fase correspondente.

Inventarie os oito arquivos de `SONS/` com caminho, formato detectado, duração se verificável, evento candidato e pendência. Extensão `.mpeg` e cabeçalhos não comprovam importação; não converter/rebatizar originais por palpite. Referências visuais de jogos declaradas no plano são dados do usuário, não assets licenciados para copiar.

## Aceite

- Fontes originais preservadas, dependências conhecidas e backup verificável.
- Visual do NPC funciona no acompanhante real, sem clones, cortes, pivô saltando ou interferência na navegação/pausa.
- Clipes de escudo de 1,12 s reconhecidos como apresentação atual, não proteção de 5 s pronta.
- Execute verificação visual do NPC e regressão próxima de acompanhamento/UI se disponíveis; registre inspeção humana pendente sem fingir aprovação artística.
- Estado da fase salvo; nenhum áudio desconhecido, proteção ou sobrevivência declarados funcionais apenas por terem arquivos.
