entity test2 is
	port (
		clk : in bit;
		en : in bit;
		rst : in bit;
		s : out bit
	);
end test2;

architecture rtl of test2 is

	signal s0 : bit;
	signal s1 : bit_vector(15 downto 0);

begin

	s <= clk;
	s0 <= s;

end architecture;

architecture behavioral of test2 is

	signal s0 : bit;

begin

	MUX : entity work.test(rtl)
	port map (
		clk => clk,
		en => en,
		rst => rst,
		s0 => s
	);

end architecture;

