library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_arith;

entity Compute_Unit is
  Port (
  clk25: in std_logic;
  X1: in std_logic_vector(7 downto 0);
  X2: in std_logic_vector(7 downto 0);
  X3: in std_logic_vector(7 downto 0);
  X4: in std_logic_vector(7 downto 0);
  X5: in std_logic_vector(7 downto 0);
  X6: in std_logic_vector(7 downto 0);
  X7: in std_logic_vector(7 downto 0);
  X8: in std_logic_vector(7 downto 0);
  X9: in std_logic_vector(7 downto 0); 
  Y1: in std_logic_vector(7 downto 0);
  Y2: in std_logic_vector(7 downto 0); 
  Y3: in std_logic_vector(7 downto 0); 
  Y4: in std_logic_vector(7 downto 0); 
  Y5: in std_logic_vector(7 downto 0); 
  Y6: in std_logic_vector(7 downto 0); 
  Y7: in std_logic_vector(7 downto 0); 
  Y8: in std_logic_vector(7 downto 0); 
  Y9: in std_logic_vector(7 downto 0);
  enable: in std_logic;
  result: out std_logic_vector(20 downto 0)
  );
end Compute_Unit;

architecture Behavioral of Compute_Unit is
signal en: std_logic:='1';
signal data1: std_logic_vector(20 downto 0):=(others =>'0');
signal data2: std_logic_vector(20 downto 0):=(others =>'0');
signal data3: std_logic_vector(20 downto 0):=(others =>'0');
signal data4: std_logic_vector(20 downto 0):=(others =>'0');
signal data5: std_logic_vector(20 downto 0):=(others =>'0');
signal data6: std_logic_vector(20 downto 0):=(others =>'0');
signal data7: std_logic_vector(20 downto 0):=(others =>'0');
signal data8: std_logic_vector(20 downto 0):=(others =>'0');
signal data9: std_logic_vector(20 downto 0):=(others =>'0');
--signal clk25: std_logic:='0';
signal d1: std_logic_vector(7 downto 0):= X1;
signal d2: std_logic_vector(7 downto 0):=Y1;
signal d3: std_logic_vector(7 downto 0):=X2;
signal d4: std_logic_vector(7 downto 0):=Y2;
signal d5: std_logic_vector(7 downto 0):=X3;
signal d6: std_logic_vector(7 downto 0):=Y3;
signal d7: std_logic_vector(7 downto 0):=X4;
signal d8: std_logic_vector(7 downto 0):=Y4;
signal d9: std_logic_vector(7 downto 0):=X5;
signal d10: std_logic_vector(7 downto 0):=Y5;
signal d11: std_logic_vector(7 downto 0):=X6;
signal d12: std_logic_vector(7 downto 0):=Y6;
signal d13: std_logic_vector(7 downto 0):=X7;
signal d14: std_logic_vector(7 downto 0):=Y7;
signal d15: std_logic_vector(7 downto 0):=X8;
signal d16: std_logic_vector(7 downto 0):=Y8;
signal d17: std_logic_vector(7 downto 0):=X9;
signal d18: std_logic_vector(7 downto 0):=Y9;
signal accum: std_logic_vector(20 downto 0):=(others =>'0');
signal accumout1: std_logic_vector(20 downto 0):=(others =>'0');
signal accumout2: std_logic_vector(20 downto 0):=(others =>'0');
signal accumout3: std_logic_vector(20 downto 0):=(others =>'0');
signal accumout4: std_logic_vector(20 downto 0):=(others =>'0');
signal accumout5: std_logic_vector(20 downto 0):=(others =>'0');
signal accumout6: std_logic_vector(20 downto 0):=(others =>'0');
signal accumout7: std_logic_vector(20 downto 0):=(others =>'0');
signal accumout8: std_logic_vector(20 downto 0):=(others =>'0');
signal accumout9: std_logic_vector(20 downto 0):=(others =>'0');
signal ctrl: std_logic:='1'; 
signal rst: std_logic:='0';
--constant clock_period:time :=40ns;  

component MAC_Unit
port(
    clock: in std_logic;
    reset: in std_logic;
    enable : in STD_LOGIC;
    ctrl_signal : in STD_LOGIC:='1';
    data_in1 : in STD_LOGIC_VECTOR(7 downto 0);
    data_in2 : in STD_LOGIC_VECTOR(7 downto 0);
    accum_in : in STD_LOGIC_VECTOR(20 downto 0);
    accum_out : out STD_LOGIC_VECTOR(20 downto 0);
    data_out : out STD_LOGIC_VECTOR(20 downto 0)
);
end component;

begin
uut6: MAC_Unit PORT MAP(
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

uut7: MAC_Unit PORT MAP(
    clock =>clk25,
    reset =>rst,
    enable =>en,
    ctrl_signal =>ctrl,
    data_in1 =>d3,
    data_in2 =>d4,
    accum_in =>accum,
    accum_out => accumout2,
    data_out => data2
);
uut8: MAC_Unit PORT MAP(
    clock =>clk25,
    reset =>rst,
    enable =>en,
    ctrl_signal =>ctrl,
    data_in1 =>d5,
    data_in2 =>d6,
    accum_in =>accum,
    accum_out => accumout3,
    data_out => data3
);
uut9: MAC_Unit PORT MAP(
    clock =>clk25,
    reset =>rst,
    enable =>en,
    ctrl_signal =>ctrl,
    data_in1 =>d7,
    data_in2 =>d8,
    accum_in =>accum,
    accum_out => accumout4,
    data_out => data4
);
uut10: MAC_Unit PORT MAP(
    clock =>clk25,
    reset =>rst,
    enable =>en,
    ctrl_signal =>ctrl,
    data_in1 =>d9,
    data_in2 =>d10,
    accum_in =>accum,
    accum_out => accumout5,
    data_out => data5
);
uut11: MAC_Unit PORT MAP(
    clock =>clk25,
    reset =>rst,
    enable =>en,
    ctrl_signal =>ctrl,
    data_in1 =>d11,
    data_in2 =>d12,
    accum_in =>accum,
    accum_out => accumout6,
    data_out => data6
);
uut12: MAC_Unit PORT MAP(
    clock =>clk25,
    reset =>rst,
    enable =>en,
    ctrl_signal =>ctrl,
    data_in1 =>d13,
    data_in2 =>d14,
    accum_in =>accum,
    accum_out => accumout7,
    data_out => data7
);
uut13: MAC_Unit PORT MAP(
    clock =>clk25,
    reset =>rst,
    enable =>en,
    ctrl_signal =>ctrl,
    data_in1 =>d15,
    data_in2 =>d16,
    accum_in =>accum,
    accum_out => accumout8,
    data_out => data8
);
uut14: MAC_Unit PORT MAP(
    clock =>clk25,
    reset =>rst,
    enable =>en,
    ctrl_signal =>ctrl,
    data_in1 =>d17,
    data_in2 =>d18,
    accum_in =>accum,
    accum_out => accumout9,
    data_out => data9
);

main: process(clk25)
begin
  if rising_edge(clk25) then
     if(enable='1') then
--        result <= data1;
        result <= data1+data2+data3+data4+data5+data6+data7+data8+data9;
     else
        result<= "000000000000000000000";
     end if;
  end if;
end process;
end Behavioral;
