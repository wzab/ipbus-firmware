-- ipbus_dpram
--
-- generic 32b wide dual-port memory with ipbus access on one port
--
-- Should lead to an inferred block RAM in Xilinx parts with modern tools
--
-- Note the wait state on ipbus access - full speed access is not possible
--
-- Dave Newbold, July 2013

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.ipbus.all;

entity ipbus_dpram is
	generic(
		ADDR_WIDTH: natural
	);
	port(
		clk: in std_logic;
		rst: in std_logic;
		ipb_in: in ipb_wbus;
		ipb_out: out ipb_rbus;
		rclk: in std_logic;
		we: in std_logic;
		d: in std_logic_vector(31 downto 0);
		q: out std_logic_vector(31 downto 0);
		addr: in std_logic_vector(ADDR_WIDTH downto 0)
	);
	
end ipbus_dpram;

architecture rtl of ipbus_dpram is

	type ram_array is array(2 ** ADDR_WIDTH - 1 downto 0) of std_logic_vector(31 downto 0);
	shared variable ram: ram_array;
	signal sel, rsel: integer;
	signal ack: std_logic;

begin

	sel <= to_integer(unsigned(ipbus_in.ipb_addr(addr_width-1 downto 0)));

	process(clk)
	begin
		if rising_edge(clk) then
			if ipbus_in.ipb_strobe='1' and ipbus_in.ipb_write='1' then
				ram(sel) <= ipbus_in.ipb_wdata;
			end if;
			ipbus_out.ipb_rdata <= ram(sel);
			ack <= ipbus_in.ipb_strobe and not ack;
		end if;
	end process;
	
	ipbus_out.ipb_ack <= ack;
	ipbus_out.ipb_err <= '0';
	
	rsel <= to_integer(unsigned(addr));
	
	process(rclk)
	begin
		if rising_edge(rclk) then
			if we = '1' then
				ram(rsel) <= d;
			end if;
			q <= ram(rsel);
		end if;
	end process;

end rtl;