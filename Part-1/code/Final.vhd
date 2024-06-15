library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Final is
  Port (
    clk: in std_logic;
    reset: in std_logic;
    HSYNC: out std_logic;
    VSYNC: out std_logic;
    vgaRed: out std_logic_vector(3 downto 0);
    vgaBlue: out std_logic_vector(3 downto 0);
    vgaGreen: out std_logic_vector(3 downto 0)
    );
end Final;

architecture Behavioral of Final is
--   Component Declaration
   component dist_mem_gen_0
       port(
       clk: in std_logic;
       a: in std_logic_vector(11 downto 0);
       spo: out std_logic_vector(7 downto 0) 
       );
   end component; 
   component filterROM
       port(
       clk: in std_logic;
       a: in std_logic_vector(3 downto 0);
       spo: out std_logic_vector(7 downto 0)
       );
    end component;
    component dist_mem_gen_1
        port(
        clk: in std_logic;
        d: in std_logic_vector(7 downto 0);
        a: in std_logic_vector(11 downto 0);
        spo: out std_logic_vector(7 downto 0);
        we: in std_logic
        );
   end component;
   component dist_mem_gen_4
   port(
        clk: in std_logic;
        d: in std_logic_vector(20 downto 0);
        a: in std_logic_vector(11 downto 0);
        spo: out std_logic_vector(20 downto 0);
        we: in std_logic
    );
   end component;
   component Compute_Unit 
   port(
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
   end component;
   -- RAM Variable Declarations
    signal ram_data_in: std_logic_vector(7 downto 0):=(others=>'0');
    signal ram_data_out: std_logic_vector(7 downto 0):=(others=>'0');
    signal ram_address: std_logic_vector(11 downto 0):=(others=>'0');
    signal ram_data_in1: std_logic_vector(20 downto 0):=(others=>'0');
    signal ram_data_out1: std_logic_vector(20 downto 0):=(others=>'0');
    signal ram_address1: std_logic_vector(11 downto 0):=(others=>'0');
    signal result: std_logic_vector(20 downto 0):=(others=>'0');
    signal filter_data:std_logic_vector(7 downto 0);
    signal filter_address: std_logic_vector(3 downto 0):= "0000";
    signal clock: std_logic:= '0';
    signal rom_data: std_logic_vector(7 downto 0); 
    signal rom_address: std_logic_vector(11 downto 0):=(others=>'0');
    constant clock_period: time:=40ns;
    signal write_enable: std_logic := '1';
    signal write_enable1: std_logic := '1';
    signal clk25: std_logic:='0';
    type rom is array(0 to 4095) of integer;
    signal rom_values:rom:=(others=>0);
    signal rom_filled:std_logic:='0';
    type arr is array(0 to 8) of integer;
    type ram1 is array(0 to 4095) of std_logic_vector(20 downto 0);
    signal fram: ram1:=(others=>"000000000000000000000");
    signal filter: arr:=(others =>0);
    signal ram1_is_done:std_logic:='0';
    type MACv is array(0 to 17) of std_logic_vector(7 downto 0);
    signal MAC: MACv:=(others=>(others=>'0'));
    signal MAC_enable:std_logic:='1';
    signal curmin: integer:=1048576;
    signal curmax: integer:=0;
    --MAC Values
    signal tl: integer:=0;
    signal tm:  integer:=0;
    signal tr: integer:=0;
    signal ml:  integer:=0;
    signal mm:  integer:=0;
    signal mr:  integer:=0;
    signal bl:  integer:=0;
    signal bm:  integer:=0;
    signal br:  integer:=0;
    signal q:   std_logic_vector(1 downto 0):="00";
    signal val: std_logic_vector(20 downto 0):=(others=>'0');
    signal t: std_logic:='0';
begin
--UUT Declarations -3
uut:dist_mem_gen_0 PORT MAP(
    clk=> clock,
    spo => rom_data,
    a => rom_address
);
 uut1: filterROM PORT MAP(
    a => filter_address,
    clk => clock,
    spo => filter_data
);
 uut2: dist_mem_gen_1 PORT MAP(
    clk => clock,
    a => ram_address,
    d => ram_data_in,
    spo => ram_data_out,
    we => write_enable
);
uut4: Compute_Unit PORT MAP(
    clk25 =>clock,
    X1 =>MAC(0),
    X2 =>MAC(1),
    X3 =>MAC(2),
    X4 =>MAC(3),
    X5 =>MAC(4),
    X6 =>MAC(5),
    X7 =>MAC(6),
    X8 =>MAC(7),
    X9 =>MAC(8),
    Y1 => MAC(9),
    Y2 =>MAC(10),
    Y3 =>MAC(11),
    Y4 =>MAC(12),
    Y5 =>MAC(13),
    Y6 =>MAC(14),
    Y7 => MAC(15),
    Y8 => MAC(16),
    Y9 =>MAC(17),
    enable=>MAC_enable,
    result => result
);

clock_process: process
begin
    while true loop
        clock <= not clock;
        wait for clock_period / 2;
    end loop;
end process;

filter_read:process(clock)
variable i: integer:=0;
variable v:std_logic:='0';
begin
    if (rising_edge(clock)) then
        if(i<9) and (v='0') then
           filter_address <= std_logic_vector(to_unsigned(i,4));
           v :='1';
        elsif(i<9) and (v='1')then
            filter(i) <= to_integer(signed(filter_data));
            MAC(i) <= (filter_data);
            v :='0';
            i:=i+1;
        end if;
    end if;
end process;

new_rom:process(clock)
variable v:std_logic:='0';
variable i: integer:=0;
--variable a: std_logic_vector(11 downto 0);
begin
    if rising_edge(clock) then
        if (rom_filled = '0') and(v='0') then
             rom_address <= std_logic_vector(to_unsigned(i,12));
             v:= '1';
        elsif(rom_filled='0') then
            rom_values(i) <= to_integer(unsigned(rom_data));
            i:=i+1;  
            v := '0';
            if(i=4096) then
                rom_filled <='1'; 
            end if;
        end if;
    end if;
end process;


clock_div: process(clock)
variable counter: integer:=0;
 begin
    if(rising_edge(clock)) then
        if(counter < 1) then
            counter := counter+1;
        elsif(counter=1) then
            counter := 0;
            clk25<=not clk25;
         end if;
    end if;
 end process;
 
 
 main_process:process(clock)
-- variable v:std_logic:='0';
 variable i: integer:=0;
 variable j: integer:=0;
 begin
    if rising_edge(clock) then
        if(MAC_enable='0') and(rom_filled='1') and (ram1_is_done='0') then
            MAC_enable <='1'; 
        elsif (rom_filled='1')and (ram1_is_done='0') and(write_enable1='1') then    
            if(i=0) then
                if(j=0) then
                    if(q ="00") then
                        tl <= 0;
                        tm <= 00000000;
                        tr <= 00000000;
                        ml <= 00000000;
                        mm <= rom_values(0);
                        mr <= rom_values(1);
                        bl<= 00000000;
                        bm <= rom_values(64);
                        br <= rom_values(65);
                        q <="01";
--                        ram_address1 <=std_logic_vector(to_unsigned(0,12));
                    elsif( q ="01") then
                        val <=std_logic_vector(to_signed(tl*filter(0)+tm*filter(1)+tr*filter(2)+ml*filter(3)+mm*filter(4)+mr*filter(5)+bl*filter(6)+bm*filter(7)+br*filter(8),21));
                        q <= "11";
                    else 
--                        ram_data_in1 <= val;
                        fram(0)<=val;
                        if(signed(val)< curmin) then
                            curmin <= to_integer(signed(val));
                        end if;
                        if(signed(val)> curmax) then
                            curmax <= to_integer(signed(val));
                        end if;
                        j:= j+1;
                        q <="00";
                    end if;
                elsif(j=63) then
                    if(q="00") then
                        tl  <= 00000000;
                        tm <= 00000000;
                        tr <=00000000;
                        ml <= rom_values(62);
                        mm <= (rom_values(63));
                        mr <= 00000000;
                        bl <= (rom_values(126));
                        bm <= (rom_values(127));
                        br <= 00000000;
                        q <="01"; 
--                        ram_address1 <=std_logic_vector(to_unsigned(j,12));
                    elsif( q ="01") then
                        val <=std_logic_vector(to_signed(tl*filter(0)+tm*filter(1)+tr*filter(2)+ml*filter(3)+mm*filter(4)+mr*filter(5)+bl*filter(6)+bm*filter(7)+br*filter(8),21));
                        q <= "11";
                    else            
--                        ram_data_in1 <= val;
                        fram(j)<=val;
                        if(signed(val)< curmin) then
                            curmin <= to_integer(signed(val));
                        end if;
                        if(signed(val)> curmax) then
                            curmax <= to_integer(signed(val));
                        end if;
                        j:=0;
                        i:=i+1;
                        q <="00";
                    end if;
                else
                    if(q="00") then
                        tl  <= 00000000;
                        tm <= 00000000;
                        tr <= 00000000;
                        ml <= rom_values(i*64+j-1);
                        mm <= rom_values(i*64+j);
                        mr <= rom_values(i*64+j+1);
                        bl <= rom_values((i+1)*64+j-1);
                        bm <= rom_values((i+1)*64+j);
                        br <= rom_values((i+1)*64+j+1);
--                        ram_address1 <=std_logic_vector(to_unsigned(j,12));
                        q <="01";
                    elsif(q ="01") then
                         val <=std_logic_vector(to_signed(tl*filter(0)+tm*filter(1)+tr*filter(2)+ml*filter(3)+mm*filter(4)+mr*filter(5)+bl*filter(6)+bm*filter(7)+br*filter(8),21));
                        q <="11";
                    else
                        if(signed(val)< curmin) then
                            curmin <= to_integer(signed(val));
                        end if;
                        if(signed(val)> curmax) then
                            curmax <= to_integer(signed(val));
                        end if;
--                        ram_data_in1 <= val;
                        fram(j)<=val;
                        j:=j+1;
                        q <="00";
                    end if;
                end if;
            elsif (i=63) then
                if(j=0) then
                    if(q="00") then
                        tl  <= 0;
                        tm <= (rom_values((i-1)*64+j));
                        tr <= (rom_values((i-1)*64+j+1));
                        ml <= 0;
                        mm <= (rom_values(i*64+j));
                        mr <= (rom_values(i*64+j+1));
                        bl <= 0;
                        bm <= 0;
                        br <= 0;
--                        ram_address1 <=std_logic_vector(to_unsigned(i*64+j,12));
                        q <="01";
                    elsif(q ="01") then
                     val <=std_logic_vector(to_signed(tl*filter(0)+tm*filter(1)+tr*filter(2)+ml*filter(3)+mm*filter(4)+mr*filter(5)+bl*filter(6)+bm*filter(7)+br*filter(8),21));
                       
                        q <="11";
                    else
                        if(signed(val)< curmin) then
                            curmin <= to_integer(signed(val));
                        end if;
                        if(signed(val)> curmax) then
                            curmax <= to_integer(signed(val));
                        end if;
--                        ram_data_in1 <= val;
                        fram(i*64+j)<=val;
                        j:= j+1;
                        q <="00";
                    end if;
                elsif(j=63) then
                    if(q="00") then
                        tl  <= (rom_values((i-1)*64+j-1));
                        tm <= (rom_values((i-1)*64+j));
                        tr <= 0;
                        ml <= (rom_values(i*64+j-1));
                        mm <= (rom_values(i*64+j));
                        mr <= 0;
                        bl <= 0;
                        bm <= 0;
                        br <= 0;
                        q <="01";
--                        ram_address1 <=std_logic_vector(to_unsigned(i*64+j,12));
                    elsif(q="01") then
                        q<="11";
                         val <=std_logic_vector(to_signed(tl*filter(0)+tm*filter(1)+tr*filter(2)+ml*filter(3)+mm*filter(4)+mr*filter(5)+bl*filter(6)+bm*filter(7)+br*filter(8),21));
                       
                    else      
                        if(signed(val)< curmin) then
                            curmin <= to_integer(signed(val));
                        end if;
                        if(signed(val)> curmax) then
                            curmax <= to_integer(signed(val));
                        end if;
--                        ram_data_in1  <= val;
                        fram(i*64+j)<=val;
                        write_enable1<='0';
                        ram1_is_done<='1';
--                        write_enable<='1';
                    end if;
                else
                    if(q="00") then
                        tl  <= (rom_values((i-1)*64+j-1));
                        tm <= (rom_values((i-1)*64+j));
                        tr <= (rom_values((i-1)*64+j+1));
                        ml <= (rom_values(i*64+j-1));
                        mm <= (rom_values(i*64+j));
                        mr <= (rom_values(i*64+j+1));
                        bl <= 0;
                        bm <= 0;
                        br <= 0;
                        q <="01";
--                        ram_address1 <=std_logic_vector(to_unsigned(i*64+j,12));
                    elsif(q="01") then
                        q<="11";
                         val <=std_logic_vector(to_signed(tl*filter(0)+tm*filter(1)+tr*filter(2)+ml*filter(3)+mm*filter(4)+mr*filter(5)+bl*filter(6)+bm*filter(7)+br*filter(8),21));
                    else
                        if(signed(val)< curmin) then
                            curmin <= to_integer(signed(val));
                        end if;
                        if(signed(val)> curmax) then
                            curmax <= to_integer(signed(val));
                        end if;
--                        ram_data_in1 <= val;
                        fram(i*64+j)<=val;
                        j:=j+1;
                        q <="00";
                    end if;
                end if;
            else
                if(j=0) then
                    if(q="00") then
                        tl  <= 0;
                        tm <= (rom_values((i-1)*64+j));
                        tr <= (rom_values((i-1)*64+j+1));
                        ml <= 0;
                        mm <= (rom_values(i*64+j));
                        mr <= (rom_values(i*64+j+1));
                        bl <= 0;
                        bm <= (rom_values((i+1)*64+j));
                        br <= (rom_values((i+1)*64+j+1));
                        q <="01";
--                        ram_address1 <=std_logic_vector(to_unsigned(i*64+j,12));
                    elsif(q="01") then
                        q<="11";
                         val <=std_logic_vector(to_signed(tl*filter(0)+tm*filter(1)+tr*filter(2)+ml*filter(3)+mm*filter(4)+mr*filter(5)+bl*filter(6)+bm*filter(7)+br*filter(8),21));
                    else
                        if(signed(val)< curmin) then
                            curmin <= to_integer(signed(val));
                        end if;
                        if(signed(val)> curmax) then
                            curmax <= to_integer(signed(val));
                        end if;       
--                        ram_data_in1 <= val;
                        fram(i*64+j)<=val;
                        j:= j+1;
                        q <="00";
                    end if;
                elsif(j=63) then
                    if(q="00") then
                        tl  <= (rom_values((i-1)*64+j-1));
                        tm <= (rom_values((i-1)*64+j));
                        tr <= 0;
                        ml <= (rom_values(i*64+j-1));
                        mm <= (rom_values(i*64+j));
                        mr <= 0;
                        bl <= (rom_values((i+1)*64+j-1));
                        bm <= (rom_values((i+1)*64+j));
                        br <= 0;
                        q <="01"; 
                    elsif(q="01") then
                        q<="11";
                         val <=std_logic_vector(to_signed(tl*filter(0)+tm*filter(1)+tr*filter(2)+ml*filter(3)+mm*filter(4)+mr*filter(5)+bl*filter(6)+bm*filter(7)+br*filter(8),21));
                       
                    else  
                        if(signed(val)< curmin) then
                            curmin <= to_integer(signed(val));
                        end if;
                        if(signed(val)> curmax) then
                            curmax <= to_integer(signed(val));
                        end if;   
--                        ram_data_in1  <= val;
                        fram(i*64+j)<=val;
                        j:=0;
                        i:=i+1;
                        q <="00";
                    end if;
                else
                    if(q="00") then
                        tl  <= (rom_values((i-1)*64+j-1));
                        tm <= (rom_values((i-1)*64+j));
                        tr <= (rom_values((i-1)*64+j+1));
                        ml <= (rom_values(i*64+j-1));
                        mm <= (rom_values(i*64+j));
                        mr <= (rom_values(i*64+j+1));
                        bl <= (rom_values((i+1)*64+j-1));
                        bm <= (rom_values((i+1)*64+j));
                        br <= (rom_values((i+1)*64+j+1));
                        q <="01";
--                        ram_address1 <=std_logic_vector(to_unsigned(i*64+j,12));
                    elsif(q="01") then
                        q<="11";
                        val <=std_logic_vector(to_signed(tl*filter(0)+tm*filter(1)+tr*filter(2)+ml*filter(3)+mm*filter(4)+mr*filter(5)+bl*filter(6)+bm*filter(7)+br*filter(8),21));
                    else            
                        if(signed(val)< curmin) then
                            curmin <= to_integer(signed(val));
                        end if;
                        if(signed(val)> curmax) then
                            curmax <= to_integer(signed(val));
                        end if;
--                        ram_data_in1 <= val;
                        fram(i*64+j)<=val;
                        j:=j+1;
                        q <="00";
                    end if;
                end if;
            end if;
        end if;
    end if;
 end process;
 
-- Normalize:process
-- variable nv: integer:=0;
-- begin
--    if(ram1_is_done = '1') then
--        for i in 0 to 4095 loop
--            wait for clock_period;
--            ram_address1 <=std_logic_vector(to_unsigned(i,12));
--            ram_address <= std_logic_vector(to_unsigned(i,12));
--            nv:= 255*(to_integer(signed(ram_data_out1))-curmin)/(curmax-curmin);
----            ram_data_in <= std_logic_vector(to_unsigned(nv,8));
            
--        end loop;
--    end if;
-- end process;
-- Normalize:process(clock)
-- variable i: integer:=0;
-- variable nv:integer:=0;
-- begin
--    if(rising_edge(clock)) then
--        if(write_enable ='0') and (write_enable='1') and (ram1_is_done='1') then 
--            if(t='0') then 
--                 nv:= 255*(to_integer(signed(ram_data_out1))-curmin)/(curmax-curmin);
--                 ram_data_in <= std_logic_vector(to_unsigned(nv,8));
--                 t <='1';
--            else
--                 ram_address <=std_logic_vector(to_unsigned(i,12));
--                 ram_address1 <=std_logic_vector(to_unsigned(i,12));
--                 i:=i+1;
--                 t <='0';
--                 if(i=4096) then 
--                        write_enable <='0';
--                 end if;
--            end if;
--        end if;
--    end if;
-- end process;
 normalize:process(clock)
 variable i: integer:=0;
 variable nv:integer:=0;

 begin
    if(rising_edge(clock)) then
        if(write_enable1='0' and write_enable='1') then
            if(t='0') then 
                 ram_address <=std_logic_vector(to_unsigned(i,12));
                 nv:= 255*(to_integer(signed(fram(i)))-curmin)/(curmax-curmin);
                 ram_data_in <= std_logic_vector(to_unsigned(nv,8));
                 t <='1';
            else
                 ram_address <=std_logic_vector(to_unsigned(i,12));
                 ram_address1 <=std_logic_vector(to_unsigned(i,12));
                 i:=i+1;
                 t <='0';
                 if(i=4096) then 
                        write_enable <='0';
                 end if;
            end if;
        end if;
    end if;
 end process;
 end Behavioral;