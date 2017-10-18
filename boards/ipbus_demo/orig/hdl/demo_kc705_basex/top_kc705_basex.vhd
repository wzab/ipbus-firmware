-- Top-level design for ipbus demo
--
-- You must edit this file to set the IP and MAC addresses
--
-- Dave Newbold, 16/7/12

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.ipbus.ALL;

entity top is port(
		gt_clk_p, gt_clk_n: in std_logic;
		gt_tx_p, gt_tx_n: out std_logic;
		gt_rx_p, gt_rx_n: in std_logic;
		sfp_los: in std_logic;
		leds: out STD_LOGIC_VECTOR(3 downto 0)
	);

end top;

architecture rtl of top is

	signal clk_ipb, rst_ipb, nuke, soft_rst, userled: std_logic;
	signal mac_addr: std_logic_vector(47 downto 0);
	signal ip_addr: std_logic_vector(31 downto 0);
	signal ipb_out: ipb_wbus;
	signal ipb_in: ipb_rbus;

begin

-- Infrastructure

	infra: entity work.kc705_basex_infra
		port map(
			gt_clk_p => gt_clk_p,
			gt_clk_n => gt_clk_n,
			gt_rx_p => gt_rx_p,
			gt_rx_n => gt_rx_n,
			gt_tx_p => gt_tx_p,
			gt_tx_n => gt_tx_n,
			sfp_los => sfp_los,			
			clk_ipb_o => clk_ipb,
			rst_ipb_o => rst_ipb,
			nuke => nuke,
			soft_rst => soft_rst,
			leds => leds(1 downto 0),
			mac_addr => mac_addr,
			ip_addr => ip_addr,
			ipb_in => ipb_in,
			ipb_out => ipb_out
		);
		
	leds(3 downto 2) <= '0' & userled;
		
	mac_addr <= X"020ddba115" & X"0" & X"0"; -- Careful here, arbitrary addresses do not always work
	ip_addr <= X"c0a8c8" & X"0" & X"0"; -- 192.168.200.X

-- ipbus slaves live in the entity below, and can expose top-level ports
-- The ipbus fabric is instantiated within.

	slaves: entity work.ipbus_example
		port map(
			ipb_clk => clk_ipb,
			ipb_rst => rst_ipb,
			ipb_in => ipb_out,
			ipb_out => ipb_in,
			nuke => nuke,
			soft_rst => soft_rst,
			userled => userled
		);

end rtl;