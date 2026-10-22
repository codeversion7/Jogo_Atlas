# ATLAS — GODOT, GDSCRIPT E ARQUITETURA

# 1. TECNOLOGIA

Engine:

**Godot**

Linguagem:

**GDScript**

Dimensão inicial:

**2D**

Versão exata do Godot:

**A DEFINIR**

---

# 2. PRINCÍPIOS DE ARQUITETURA

## Modularidade

Cada script deve possuir responsabilidade clara.

## Simplicidade

O código do protótipo deve ser menor e mais fácil de compreender.

## Testabilidade

Sistemas devem poder ser testados isoladamente.

## Manutenção

Evitar scripts gigantes.

## Clareza

Nomes de variáveis, funções, cenas e nós devem ser claros.

---

# 3. POSSÍVEIS COMPONENTES

- Player;
- interação;
- itens;
- comida;
- inventário;
- conquistas;
- fragmentos;
- livro;
- progressão;
- GameState;
- evento de colapso;
- UI;
- multiplayer.

Nem todos precisam existir inicialmente.

---

# 4. ORDEM RECOMENDADA

1. criar projeto;
2. criar cena principal;
3. implementar personagem;
4. implementar movimentação;
5. implementar interação;
6. criar exploração básica;
7. criar comida;
8. criar conquistas;
9. criar fragmentos;
10. criar livro;
11. verificar livro completo;
12. criar evento de colapso;
13. testar o prólogo inteiro;
14. expandir somente depois.

---

# 5. RESPONSABILIDADE DO CÓDIGO

Quando a IA escrever GDScript para ATLAS, deve informar:

- em qual cena o script deve ficar;
- em qual Node ele deve ficar;
- dependências;
- função do script;
- como testar;
- eventuais limitações.

---

# 6. REGRA DE IMPLEMENTAÇÃO

Sempre preferir:

"menor sistema funcional"

em vez de:

"arquitetura definitiva prematura"

O projeto está em fase de prototipagem.
