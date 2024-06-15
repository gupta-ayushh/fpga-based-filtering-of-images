
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity MAC_tb is
end MAC_tb;

architecture Behavioral of MAC_tb is
signal ctrl: std_logic:='1'; 
signal rst: std_logic:='0';
signal clk25: std_logic:='1';
signal d1: std_logic_vector(7 downto 0):=(others=>'1');
signal d2: std_logic_vector(7 downto 0):= (others =>'1');
signal en: std_logic:='1';
signal accum: std_logic_vector(20 downto 0):=(others =>'0');
signal accumout1: std_logic_vector(20 downto 0):=(others =>'0');
signal data1: std_logic_vector(20 downto 0);
constant clock_period:time:= 40ns;

component MAC_Unit
port(
    clock: in std_logic;
    reset: in std_logic:='0';
    enable : in STD_LOGIC:='1';
    ctrl_signal : in STD_LOGIC:='0';
    data_in1 : in STD_LOGIC_VECTOR(7 downto 0);
    data_in2 : in STD_LOGIC_VECTOR(7 downto 0);
    accum_in : in STD_LOGIC_VECTOR(20 downto 0);
    accum_out : out STD_LOGIC_VECTOR(20 downto 0);
    data_out : out STD_LOGIC_VECTOR(20 downto 0)
);
end component;


begin

clock_process: process
begin
    while true loop
        clk25 <= not clk25;
        wait for clock_period / 2;
    end loop;
end process;

uut1: MAC_Unit PORT MAP(
    clock =>clk25,
    reset =>rst,
    enable =>en,
    ctrl_signal =>ctrl,
    data_in1 =>d1,
    data_in2 =>d2,
    accum_in =>accum,
    accum_out => accumout1,
    data_out => data1
);

tb: process(clk25)
variable i:integer:=0;
begin
    if(rising_edge(clk25)) then
        d1 <= std_logic_vector(to_unsigned(i,8));
        d2 <= std_logic_vector(to_unsigned(i+128,8));
        i:=i+1;
    end if;
end process;

end Behavioral;
