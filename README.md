# Hyle 

This project is a VHDL subset parser. It aims to give an AST which can be used in many different other projects.

For the moment, the VHDL subset "parsable" with this tool includes :

- Entity declaration 
  - ~~generic declaration~~
  - port declaration
- Architecture **body** declaration (no signal nor component declaration)
  - component instanciation (with **explicit **associations)
    - port map
    - ~~generic map~~
  - Entity port assignment (without operations)  

## ToDo 

- [ ] Ajout les mots signal, xor, and, or, nor, nand, not au projet (nécessite d'ajouter de nouveaux types comme des opérations, des signaux, etc)
- [x] Ajouter un Deparser pour passer d'un AST décoré à un VHDL. 
  - [x] signal
  - [ ] xor
  - [ ] and
  - [ ] or
  - [ ] not
  - [ ] nand
  - [ ] nor
  - [ ] bit_vector
- [ ] Voir pour la lib IEEE (std_logic_1164)