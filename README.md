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

- [x] Checker si un doublon en nommage est détecté (port, signal confondu)
- [x] Faire la visite des déclarations dans l'architecture
- [x] Faire le deparsing pour le mot signal si pas encore fait
- [x] Faire le deparsing pour le mot bit_vector si pas encore fait 
- [x] renommer type en data_type pour toutes les SignalDeclarations
- [x] Permettre l'assignation d'un port(out) à un port(out)
- [x] Permettre l'assignation d'un signal à un port
- [x] Permettre l'assignation d'un signal à un signal
- [x] Permette l'association d'un signal dans un portmap

- [x] Ajout les mots signal, xor, and, or, nor, nand, not au projet (nécessite d'ajouter de nouveaux types comme des opérations, des signaux, etc)
- [x] Ajouter un Deparser pour passer d'un AST décoré à un VHDL. 
  - [x] signal
  - [x] xor
  - [x] and
  - [x] or
  - [x] not
  - [x] nand
  - [x] nor
  - [x] bit_vector
- [ ] Voir pour la lib IEEE (std_logic_1164)