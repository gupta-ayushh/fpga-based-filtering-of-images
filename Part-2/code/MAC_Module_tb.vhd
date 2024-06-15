library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.register_pkg1.all;

entity ComputeModule_tb is
end ComputeModule_tb;

architecture tb_architecture of ComputeModule_tb is
    signal enable_tb   : std_logic := '0';
    signal filter_tb   : register_array(8 downto 0);
    signal pixels_tb   : register_array(8 downto 0);
    signal result_tb   : std_logic_vector(20 downto 0);
    signal clock: std_logic:='0';
    constant clock_period:time:=10ns;
    component ComputeModule
        Port (
            clk: in std_logic;
            enable  : in std_logic; 
            filter  : in register_array(8 downto 0);
            pixels  : in register_array(8 downto 0);
            result  : out std_logic_vector(20 downto 0)
        );
    end component;
begin
uut: ComputeModule
        port map(
            clk => clock,
            enable  => enable_tb,
            filter  => filter_tb,
            pixels  => pixels_tb,
            result  => result_tb
        );
    c:process
    begin
        clock <= not clock;
        wait for clock_period/2;
    end process;
    stimulus: process
    begin
        -- Apply stimulus
        enable_tb <= '1';

        filter_tb <= (others => (others => '0')); -- Initialize to zero
        pixels_tb <= (others => (others => '0')); -- Initialize to zero

        wait for 1 ps;

        filter_tb(0) <= "00000001";  -- Example filter values
        filter_tb(1) <= "00000010";
        filter_tb(2) <= "00000011";
        -- Add more stimulus values as needed for your testing

        pixels_tb(0) <= "00000001";  -- Example pixel values
        pixels_tb(1) <= "00000010";
        pixels_tb(2) <= "00000011";
        -- Add more stimulus values as needed for your testing
        
        wait for 10 ns;
        enable_tb <='0';
        -- Add more test cases as needed

        wait;
    end process stimulus;

end tb_architecture;
