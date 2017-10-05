----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.08.2017 13:42:38
-- Design Name: 
-- Module Name: ipbus_ctrl_generic_ram_simtb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


use work.ipbus.ALL;
use work.ipbus_trans_decl.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ipbus_generic_ram_if_simtb is
--  Port ( );
end ipbus_generic_ram_if_simtb;

architecture Behavioral of ipbus_generic_ram_if_simtb is

  signal ipb_clk: std_logic := '0';

  signal rst_ipb: std_logic := '1';
  signal rst_pcie: std_logic := '1';
  signal nuke: std_logic := '0';

  signal ram_rx_addr : std_logic_vector(8 downto 0);
  signal ram_rx_data : std_logic_vector(31 downto 0);
  signal ram_rx_payload_send : std_logic := '0';
  signal ram_rx_payload_we : std_logic := '0';
  signal ram_tx_addr : std_logic_vector(8 downto 0) := (Others => '0');
  signal ram_tx_busy : std_logic := '0';

  signal ram_tx_data : std_logic_vector(31 downto 0);
  signal ram_tx_req_send : std_logic;
   
  signal trans_in : ipbus_trans_in;
  signal trans_out : ipbus_trans_out;

begin

  ipb_clk <= not ipb_clk after 16 ns;

  STIMULUS: process
  begin
    rst_ipb <= '1';
    rst_pcie <= '1';
    wait for 128 ns;
    rst_ipb <= '0';
    rst_pcie <= '0';
    wait for 256 ns;
    --- IPBUS INPUT PACKET: HEADERS ---
    ram_rx_payload_we <= '1';
    ram_rx_addr <= '0' & X"00";
    ram_rx_data <= X"00010002"; -- header length, payload length
    wait for 32 ns;
    ram_rx_addr <= '0' & X"01";
    ram_rx_data <= X"200001F0"; -- IPbus packet header
    -- IPBUS INPUT PACKET: READ TRANSACTION --
    wait for 32 ns;
    ram_rx_addr <= '0' & X"02";
    ram_rx_data <= X"2001010F";
    wait for 32 ns;
    ram_rx_addr <= '0' & X"03";
    ram_rx_data <= X"00000001";
    -- END OF INPUT PACKET --
    wait for 32 ns;
    ram_rx_payload_we <= '0';
    wait for 32 ns;
    ram_rx_payload_send <= '1';
    wait for 32 ns;
    ram_rx_payload_send <= '0';
    wait;
  end process;
  
  TX_BUF_STIMULUS : process
  begin
    ram_tx_addr <= '0' & X"00";
    wait for 1440ns;
--    if rising_edge(ram_tx_req_send) then
      ram_tx_addr <= '0' & X"00";
      wait for 32 ns;
      ram_tx_addr <= '0' & X"01";
      wait for 32 ns;
      ram_tx_addr <= '0' & X"02";
      wait for 32 ns;
      ram_tx_addr <= '0' & X"03";
      wait for 32 ns;
      ram_tx_addr <= '0' & X"04";
      wait for 32 ns;
      ram_tx_addr <= '0' & X"05";
      wait;
--    end if;
  end process;

  ipbus_if : entity work.ipbus_generic_ram_if
    port map (
      pcie_clk => ipb_clk,
      rst_pcieclk => rst_ipb,
      ipb_clk => ipb_clk,
      rst_ipb => rst_ipb,

      ram_rx_addr => ram_rx_addr,
      ram_rx_data => ram_rx_data,
      ram_rx_reset => rst_pcie,
      ram_rx_payload_send => ram_rx_payload_send,
      ram_rx_payload_we => ram_rx_payload_we,
      ram_tx_addr => ram_tx_addr,
      ram_tx_busy => ram_tx_busy,
      ram_tx_data => ram_tx_data,
      ram_tx_req_send => ram_tx_req_send,
    
      pkt_done => trans_out.pkt_done,
      raddr => trans_out.raddr,
      waddr => trans_out.waddr,
      wdata => trans_out.wdata,
      we => trans_out.we,
    
      --pkt => open,
      --pkt_oob => open,

      pkt_ready => trans_in.pkt_rdy,
      rdata => trans_in.rdata

--      oob_in <= (others => ('0', X"00000000"));
--      oob_out: out ipbus_trans_out_array(N_OOB - 1 downto 0)
    );


    trans: entity work.dummytransactor
    port map(
      ipb_clk => ipb_clk,
      rst_ipb => rst_ipb,

      rdata => trans_in.rdata,
      pkt_rdy => trans_in.pkt_rdy,
      pkt_done => trans_out.pkt_done,
      raddr => trans_out.raddr,
      we => trans_out.we,
      waddr => trans_out.waddr,
      wdata => trans_out.wdata

      --ipb_out => ipb_out,
      --ipb_in => ipb_in,
      --ipb_req => open,
      --ipb_grant => ipb_grant,
      --trans_in => trans_in,
      --trans_out => trans_out,
      --cfg_vector_in => (Others => '0'),
      --cfg_vector_out => open
    );

  --slaves: entity work.ipbus_example
  --  port map (
  --    ipb_clk => ipb_clk,
  --    ipb_rst => rst_ipb,
  --    ipb_in => ipb_out,
  --    ipb_out => ipb_in,
  --    nuke => nuke,
  --    soft_rst => open,
  --    userled => open
  --  );

end Behavioral;
