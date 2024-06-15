library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package register_pkg1 is
    type register_array is array(natural range<>)of std_logic_vector(7 downto 0);
    type INTEGER_ARRAY is array(integer range <>) of integer;
end package;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.register_pkg1.all;

entity ComputeModule is
  Port (
  clk: in std_logic;
  enable: in std_logic; 
  filter: in register_array(8 downto 0);
  pixels: in register_array(8 downto 0);
  result:out std_logic_vector(20 downto 0)
  );
end ComputeModule;

architecture Behavioral of ComputeModule is
signal o: std_logic_vector(20 downto 0):=(others=>'0'); 
begin

main:process(clk)
variable p:integer:=0;
begin
    if(rising_edge(clk)) then
        if(enable='1') then 
            p:=0;
            for i in 0 to 8 loop
                p:= p+ to_integer(signed(filter(i))*signed('0' & pixels(i)));
            end loop;
            result <= std_logic_vector(to_unsigned(p,21));
        end if;
    end if;    
end process;

end Behavioral;
