entity test2 is 
    port ( 
        clk : in bit;
        en : in bit;
        rst : in bit;
        s : out bit
    );
end test2;

architecture rtl of test2 is

begin

    s <= clk;

end architecture;

architecture behavioral of test2 is

begin

    MUX : entity work.test(rtl)
    port map (
        clk => clk,
        en => en,
        rst => rst,
        s => s
    );

end architecture;

