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
