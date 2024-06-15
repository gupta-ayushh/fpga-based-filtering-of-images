library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity MAC_Unit is
  Port (
    clock: in std_logic;
    reset : in STD_LOGIC;
    enable : in STD_LOGIC;
    ctrl_signal : in STD_LOGIC;
    data_in1 : in STD_LOGIC_VECTOR(7 downto 0);
    data_in2 : in STD_LOGIC_VECTOR(7 downto 0);
    accum_in : in STD_LOGIC_VECTOR(20 downto 0);
    accum_out : out STD_LOGIC_VECTOR(20 downto 0);
    data_out : out STD_LOGIC_VECTOR(20 downto 0)
  );
end MAC_Unit;

architecture Behavioral of MAC_Unit is
begin
  process (clock, reset)
  variable p:integer:=0;
  variable d2: std_logic_vector(8 downto 0):=(others=>'0');
  
  begin
    if rising_edge(clock) then
        if reset = '0' then
            if enable = '1' then
                if ctrl_signal = '1' then
                    d2(7 downto 0):= data_in2(7 downto 0);
                    d2(8) :='0';
                    p := to_integer(signed(data_in1)*signed(d2));
--                    p := to_integer(signed(accum_in));
                    data_out <= std_logic_vector(to_unsigned(p,21));
                    accum_out <= std_logic_vector(to_unsigned(p,21));
                end if;
            else
                accum_out <="000000000000000000000";
                data_out <= "000000000000000000000";
            end if;
        end if;
    end if;
  end process;
end Behavioral;
