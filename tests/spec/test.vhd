entity test is 
    port ( 
        clk : in bit;
        en : in bit;
        s : out bit
    );
end test;

architecture rtl of test is

begin

    s <= clk;

end architecture;

architecture behavioral of test is

begin

end architecture;