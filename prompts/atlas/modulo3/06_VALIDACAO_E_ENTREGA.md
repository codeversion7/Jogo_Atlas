# Fase 06 — regressão, desempenho e entrega

Aplique `INICIAR.md`; não iniciar funcionalidades novas para completar checklist.

## Validação dirigida

Revise diffs/novos arquivos, imports, referências/UID, configurações, origem dos assets e consumidores. Execute testes locais suportados após conferir efeitos/hook; não há motivo para API paga ou publicação externa além do push autorizado. Faça primeiro os testes alterados de áudio/configuração, fome/drops/fogueira, vida do NPC, proteção/parry/livro, UI/mapa; depois regressões dos módulos 1/2 e fluxo completo.

Fluxo: menu → configurações reais → novo jogo → movimento/sons → combate/drops → fogueira/assar → comer/dividir → pontos/Tab/Q/F → NPC ferido/caído/reanimado → proteção → cinco áreas/páginas → livro apenas com amigo vivo → fim → menu/nova partida. Adicione morte/retorno do jogador, pausa durante ações e persistência só das configurações. Fixtures determinísticas cobrem drop/ramos raros; teste de partida real usa regras normais e não finge que RNG raro precisa ocorrer sempre.

Não reduzir asserções ou aumentar vida/dano para passar. Ajuste robô à sobrevivência real e interações, sem desativar fome, dano do NPC, gate final ou ataques. Relate separadamente fixture isolada e percurso normal. Diferencie erro introduzido, preexistente comprovado, ambiente e origem incerta.

## Desempenho e entrega local

Investigue a discrepância de física registrada no módulo 2 antes de declarar lag resolvido; compare carga/resolução/cache e duração semelhantes. Não somar monitores de etapas distintas ou usar headless com FPS fixo como medição gráfica. Limitar processamento/vozes/consultas com base em evidência, sem perder precisão da lâmina ou navegação. Registre métricas e limites, inclusive quando diagnóstico não for conclusivo.

Confira preset Windows e templates reais. `export_presets.cfg` tem mudanças anteriores locais: não sobrescrever ou publicar credenciais/alterações alheias. Se templates/ferramentas já disponíveis, faça build local Windows e teste separado do editor, inclusive assets, settings e áudio. Ausentes, preserve fonte e deixe bloqueio; não instalar/download por iniciativa nem chamar fonte de EXE. Build local não autoriza release pública.

Atualize `MODULO_3_STATUS.md`, documentação de uso/controles, decisões/histórico e checklist de limitações com resultados reais. Inclua pasta de fontes/artefato exportado somente se existir. Validar no destino/cópia limpa quando viável, sem repetir todas as suítes após aprovação sem mudança nova. Escuta humana, qualidade artística e teste humano longo ficam explícitos se não executados.

Execute backup/checkpoint/commit/push conforme `INICIAR.md`, confirme destino e registre SHA; não fazer merge/force. Caso alcance emergência antes desta fase, use apenas o protocolo mínimo de preservação, não esta regressão completa. Termine com entrega concluída ou parcial honesta e próxima ação reproduzível.
