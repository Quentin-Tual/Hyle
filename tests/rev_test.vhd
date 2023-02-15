entity test is
	port (
		clk : in bit;
		en : in bit;
		rst : in bit;
		s : out bit
	);
end test;

architecture rtl of test is

	signal s0 : bit;
	signal s1 : bit_vector(15 downto 0);

begin

	s <= clk;

end architecture;

architecture behavioral of test is

begin

end architecture;

